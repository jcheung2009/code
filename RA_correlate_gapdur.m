function [spk_gapdur_corr case_name dattable] = RA_correlate_gapdur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,targetactivity,targetdur,plotcasecondition,shuff,mode,ifr,gap_or_syll)
%correlate premotor spikes with gapdur 
%seqlen = length of syllable sequence (use even # for gap and odd for syll)
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
% targetactivity = 0;%-1:previous, 0:current, 1:next
% targetdur = 0;%-1:previous, 0:current, 1:next
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y+su' (...single units)
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity
%greater than thresh and multi unit), or 'ysu' (for activity greater than thresh and single units)
%spk_gapdur_corr = [corrcoef pval alignment firingrate width mn(pct_error)...
%numtrials, corrcoefdur1 pval corrcoefdur2 pval durmotorwin]
%alignby=1 or 2 (off1 vs on1: gap; on1 vs prevoff: syll)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%ifr = 1 use mean instantaneous FR or 0 use spike count
%gap_or_syll = 'gap' or 'syll'

%parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y+')
    plotcasecondition = ['p(2)<=0.05 & pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y++')
    plotcasecondition = ['p(2)<=0.05 & abs(r(2)) >= 0.3 & pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y+su')
     plotcasecondition = ['p(2)<=0.05 & mean(pct_error)<=0.01 & pkactivity >=',num2str(activitythresh)];
end

spk_gapdur_corr = [];case_name = {};
dattable = table([],[],[],[],[],[],[],[],'VariableNames',{'dur','spikes',...
    'unittype','activity','birdid','unitid','seqid','corrpval'});
ff = load_batchf(batchfile);
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %unique gap id
    gapids = find_uniquelbls(labels,seqlen,minsampsize);
    
    %for each unique sequence found  
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    durs_all = offsets-onsets;
    for n = 1:length(gapids)
        
        %remove outliers 
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        if strcmp(gap_or_syll,'gap')
            dur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);%remove trials with outliers in gap length
        elseif strcmp(gap_or_syll,'syll')
            dur_id = jc_removeoutliers(durs_all(idx+ceil(seqlen/2)-1),3);
        end
        dur_id = jc_removeoutliers(dur_id,3);
        id = find(isnan(dur_id));dur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);%remove trials where sequence length > 1 sec
            seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
        end
        if length(dur_id)<minsampsize
            continue
        end
        %order trials by gapdur
        [~,ix] = sort(dur_id,'descend');
        dur_id = dur_id(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);

        %compute PSTH from spike trains aligned to onset of target element
        if strcmp(gap_or_syll,'gap')
            anchor = seqoffs(:,seqlen/2+targetactivity);
        elseif strcmp(gap_or_syll,'syll')
            anchor = seqons(:,ceil(seqlen/2)+targetactivity);
        end
        seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-anchor));%end border 
        [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
        
        %compute PSTH when aligned to secondary target element
        if strcmp(gap_or_syll,'gap')
            anchor2 = seqons(:,seqlen/2+targetactivity);
        elseif strcmp(gap_or_syll,'syll')
            anchor2 = seqoffs(:,ceil(seqlen/2)+targetactivity-1);
        end
        seqst2 = ceil(max(anchor2-seqons(:,1)));%boundaries for sequence activity relative to on1
        seqend2 = ceil(max(seqoffs(:,end)-anchor2));
        [PSTH_mn_on2 tb2 smooth_spiketrains_on2 spktms_on2] = smoothtrain(spiketimes,seqst2,seqend2,anchor2,win,ifr);
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
        PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;

        %offsets for alignment
        durseq = seqoffs-seqons;
        gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
        if strcmp(gap_or_syll,'gap')
            offset = durseq(:,seqlen/2+targetactivity);
            offset = [offset+motorwin, offset];
        elseif strcmp(gap_or_syll,'syll')
            offset = gapseq(:,ceil(seqlen/2)-1+targetactivity);
            offset = [offset+motorwin, offset];
        end

        %target dur for correlation 
        if targetdur ~= 0
            if strcmp(gap_or_syll,'gap')
                dur_id_corr = gapseq(:,seqlen/2+targetdur);%gapdur for correlation with activity
            elseif strcmp(gap_or_syll,'syll')
                dur_id_corr = durseq(:,ceil(seqlen/2)+targetdur);
            end
        else
            dur_id_corr = dur_id;    
        end
        
        if strcmp(mode,'burst')
            %find peaks/bursts in PSTH in premotor window
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',5,...
                'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
            pkid = find(tb(locs)>=motorwin & tb(locs)<=0);
            wc = round(wc);
            if isempty(pkid)
                continue
            end

            %for each burst found, test alignment and correlate with gapdur
            for ixx = 1:length(pkid)
                %define peak borders
                [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);

                %average pairwise correlation of spike trains 
                r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
                r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
                r = r(find(triu(r,1)));
                varburst1 = nanmean(r);

                %find peak aligned to secondary anchor that corresponds to
                %target burst
                [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_on2,'MinPeakProminence',...
                    5,'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
                if ~isempty(locs2)
                    wc2 = round(wc2);
                    ix = find(tb2(locs2)>=mean(offset(:,1)) & tb2(locs2)<=mean(offset(:,2)));
                    if isempty(ix)
                         alignby=1;%off1 for gap, on1 for syll
                         wth = tb(burstend)-tb(burstst);gaplatency = (tb(burstst)+tb(burstend))/2;
                         pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                         if ifr == 1
                            npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;
                         else
                            npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                         end
                    else
                        [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor2-anchor))));
                        [burstst2 burstend2] = peakborder(wc2,ix,locs2,tb2);

                        %use average pairwise correlation comparison to choose
                        %alignment
                        r = xcorr(smooth_spiketrains_on2(:,burstst2:burstend2)',0,'coeff');
                        r = reshape(r,[size(smooth_spiketrains_on2,1) size(smooth_spiketrains_on2,1)]);
                        r = r(find(triu(r,1)));
                        varburst2 = nanmean(r);

                        if varburst1 < varburst2
                            alignby=2;%on1 for gap, prevoff for syll
                            wth = tb2(burstend2)-tb2(burstst2);gaplatency = ((tb2(burstst2)+tb2(burstend2))/2)-mean(offset(:,2));
                            pkactivity = (pks2(ix)-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                            if ifr == 1
                                npks_burst = mean(smooth_spiketrains_on2(:,burstst2:burstend2),2).*1000;
                            else
                                npks_burst = countspks(spktms_on2,tb2(burstst2),tb2(burstend2),ifr);%extract nspks in each trial
                            end
                        else
                            alignby=1;%off1 for gap, on1 for syll1
                            wth = tb(burstend)-tb(burstst);gaplatency = (tb(burstst)+tb(burstend))/2;
                            pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                            if ifr == 1
                                npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;
                            else
                                npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                            end
                        end
                    end
                else
                     alignby=1;%off1 for gap, on1 for syll1
                     wth = tb(burstend)-tb(burstst);gaplatency = (tb(burstst)+tb(burstend))/2;
                     pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                     if ifr == 1
                         npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;
                     else
                        npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                     end
                end
                
                if sum(~isnan(npks_burst)) < minsampsize
                    continue
                else
                    keepid = find(~isnan(npks_burst));%remove trials where no spikes occurred in burst window (in IFR mode) 
                    npks_burst = npks_burst(keepid);
                end
                
                %shuffle analysis
                if ~isempty(strfind(shuff,'y'))
                    shufftrials = 1000;
                    if isempty(strfind(shuff,'su')) %for multi unit shuff
                        if mean(pct_error)<=0.01 | pkactivity < activitythresh
                            continue
                        end
                    else
                        if mean(pct_error) > 0.01 | pkactivity < activitythresh
                            continue
                        end
                    end
                    [r p] = shuffle(npks_burst,dur_id_corr(keepid),shufftrials);
                    spk_gapdur_corr = [spk_gapdur_corr r p];
                else
                    %correlation with target and adjacent elements
                    [r p] = corrcoef(npks_burst,dur_id_corr(keepid));
                    if strcmp(gap_or_syll,'gap')
                        dur1_id = seqoffs(keepid,seqlen/2+targetdur)-seqons(keepid,seqlen/2+targetdur);%previous syll
                        dur2_id = seqoffs(keepid,seqlen/2+targetdur+1)-seqons(keepid,seqlen/2+targetdur+1);%next syll
                    elseif strcmp(gap_or_syll,'syll')
                        dur1_id = seqons(keepid,ceil(seqlen/2)+targetdur)-seqoffs(keepid,ceil(seqlen/2)+targetdur-1);
                        dur2_id = seqons(keepid,ceil(seqlen/2)+targetdur+1)-seqoffs(keepid,ceil(seqlen/2)+targetdur);
                    end
                    [r1 p1] = corrcoef(npks_burst,dur1_id);
                    [r2 p2] = corrcoef(npks_burst,dur2_id);

                    %measure latency between burst and next syllable/gap onset 
                    if targetactivity == 0 & targetdur == 0
                        if alignby==1
                            if strcmp(gap_or_syll,'gap')
                                durmotorwin = tb(locs(pkid(ixx)))-mean(gapseq(keepid,seqlen/2));
                            else
                                durmotorwin = tb(locs(pkid(ixx)))-mean(durseq(keepid,ceil(seqlen/2)));
                            end
                        elseif alignby == 2
                            if strcmp(gap_or_syll,'gap')
                                durmotorwin = tb2(locs2(ix))-mean(durseq(keepid,seqlen/2))-mean(gapseq(keepid,seqlen/2));
                            elseif strcmp(gap_or_syll,'syll')
                                durmotorwin = tb2(locs2(ix))-mean(gapseq(keepid,ceil(seqlen/2)-1))-...
                                    mean(durseq(keepid,ceil(seqlen/2)));
                            end
                        end
                    else
                        durmotorwin = NaN;
                    end
                    
                    %save measurements and variables
                    spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2) alignby pkactivity...
                        wth mean(pct_error) sum(~isnan(npks_burst)) r1(2) p1(2) r2(2) p2(2) durmotorwin gaplatency];
                    T = maketable(ff(i).name,gapids(n),dur_id_corr(keepid),npks_burst,pct_error,pkactivity,p(2));
                    dattable=[dattable;T];
                    case_name = [case_name,{T.unitid{1},T.seqid{1}}];
                end

                if eval(plotcasecondition)
                    figure;subplot(3,1,1);hold on
                    if alignby==1
                        plotraster(dur_id_corr(keepid),spktms(keepid),tb(burstst),tb(burstend),seqons(keepid,:),seqoffs(keepid,:),...
                            seqst,seqend,anchor(keepid),ff(i).name,pct_error,gapids{n},r(2));
                    elseif alignby==2
                        plotraster(dur_id_corr(keepid),spktms_on2(keepid),tb2(burstst2),tb2(burstend2),seqons(keepid,:),seqoffs(keepid,:),...
                            seqst2,seqend2,anchor2(keepid),ff(i).name,pct_error,gapids{n},r(2));
                    end
                    
                    subplot(3,1,2);hold on;
                    if alignby==1
                        plotPSTH(seqst,seqend,smooth_spiketrains(keepid,:),dur_id_corr(keepid),tb(burstst),tb(burstend));
                    elseif alignby==2
                        plotPSTH(seqst2,seqend2,smooth_spiketrains_on2(keepid,:),dur_id_corr(keepid),tb2(burstst2),tb2(burstend2));
                    end

                    subplot(3,1,3);hold on;
                    plotCORR(npks_burst,dur_id_corr(keepid),ifr);
                end
            end
        elseif strcmp(mode,'spikes')
            %average FR in motor window 
            tbid = find(tb>=motorwin & tb <=0);
            mnfr = mean(PSTH_mn(tbid));
            if mnfr >= 25
                %average pairwise correlation of spike trains 
                r = xcorr(smooth_spiketrains(:,tbid)',0,'coeff');
                r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
                r = r(find(triu(r,1)));
                varfr = nanmean(r);
    
                %average pairwise correlation of spike trains 
                tb2id = find(tb2 >= mean(offset(:,1)) & tb2 < mean(offset(:,2)));
                r = xcorr(smooth_spiketrains(:,tb2id)',0,'coeff');
                r = reshape(r,[size(smooth_spiketrains_on2,1) size(smooth_spiketrains_on2,1)]);
                r = r(find(triu(r,1)));
                varfr2 = nanmean(r);
                
                if varfr < varfr2
                    alignby=2;%on1 for gap, prevoff for syll
                    anchor = anchor2;
                    pkactivity = (max(PSTH_mn_on2(tb2id))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    
                    %indices in each trial for target window 
                    [row col] = find(tb2 >= offset(:,1) & tb2 < offset(:,2));
                    [~,ix] = sort(row);
                    row=row(ix);col=col(ix);
                    [~,ix1] = unique(row);
                    st = num2cell(tb2(col(ix1)))';
                    [~,ix2] = unique(row,'last');
                    ed = num2cell(tb2(col(ix2)))';
                    if ifr == 1
                        npks_burst = mean(smooth_spiketrains_on2(:,col(ix1):col(ix2)),2).*1000;
                    else
                        npks_burst = countspks(spktms_on2,st,ed,ifr);
                    end
                else
                    alignby=1;%off1 for gap, on1 for syll1
                    pkactivity = (max(PSTH_mn(tbid))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    if ifr == 1
                        npks_burst = mean(smooth_spiketrains(:,tbid(1):tbid(end)),2).*1000;
                    else
                        npks_burst = countspks(spktms,tb(tbid(1)),tb(tbid(end)),ifr);
                    end
                end
                
                if sum(~isnan(npks_burst)) < minsampsize
                    continue
                else
                    keepid = find(~isnan(npks_burst));
                    npks_burst = npks_burst(keepid);
                end
                
                if ~isempty(strfind(shuff,'y'))%shuffle analysis
                    if isempty(strfind(shuff,'su')) %for multi unit shuff
                        if mean(pct_error)<=0.01 | pkactivity < activitythresh
                            continue
                        end
                    else
                        if mean(pct_error) > 0.01 | pkactivity < activitythresh
                            continue
                        end
                    end
                    shufftrials = 1000;
                    [r p] = shuffle(npks_burst,dur_id_corr(keepid),shufftrials);
                    spk_gapdur_corr = [spk_gapdur_corr r p];
                else
                    %correlation with target and adjacent elements
                    [r p] = corrcoef(npks_burst,dur_id_corr(keepid),'rows','complete');
                    if strcmp(gap_or_syll,'gap')
                        dur1_id = seqoffs(keepid,seqlen/2+targetdur)-seqons(keepid,seqlen/2+targetdur);%previous syll
                        dur2_id = seqoffs(keepid,seqlen/2+targetdur+1)-seqons(keepid,seqlen/2+targetdur+1);%next syll
                    elseif strcmp(gap_or_syll,'syll')
                        dur1_id = seqons(keepid,ceil(seqlen/2)+targetdur)-seqoffs(keepid,ceil(seqlen/2)+targetdur-1);
                        dur2_id = seqons(keepid,ceil(seqlen/2)+targetdur+1)-seqoffs(keepid,ceil(seqlen/2)+targetdur);
                    end
                    [r1 p1] = corrcoef(npks_burst,dur1_id,'rows','complete');
                    [r2 p2] = corrcoef(npks_burst,dur2_id,'rows','complete');
                    
                    %save measurements and variables
                    spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2) alignby pkactivity...
                        NaN mean(pct_error) length(npks_burst) r1(2) p1(2) r2(2) p2(2) NaN NaN];
                    T = maketable(ff(i).name,gapids(n),dur_id_corr(keepid),npks_burst,pct_error,pkactivity,p(2));
                    dattable=[dattable;T];
                    case_name = [case_name,{T.unitid{1},T.seqid{1}}];
                end
                
                if eval(plotcasecondition)
                    figure;subplot(3,1,1);hold on
                    if alignby==1
                        plotraster(dur_id_corr(keepid),spktms(keepid),tb(tbid(1)),tb(tbid(end)),seqons(keepid,:),seqoffs(keepid,:),...
                            seqst,seqend,anchor(keepid),ff(i).name,pct_error,gapids{n},r(2));
                    elseif alignby==2
                        plotraster(dur_id_corr(keepid),spktms_on2(keepid),st,ed,seqons(keepid,:),seqoffs(keepid,:),...
                            seqst2,seqend2,anchor(keepid),ff(i).name,pct_error,gapids{n},r(2));
                    end

                    subplot(3,1,2);hold on;
                    if alignby==1
                        plotPSTH(seqst,seqend,smooth_spiketrains(keepid,:),dur_id_corr(keepid),tb(tbid(1)),tb(tbid(end)));
                    elseif alignby==2
                        plotPSTH(seqst2,seqend2,smooth_spiketrains_on2(keepid,:),dur_id_corr(keepid),tb2(tb2id(1)),tb2(tb2id(end)));
                    end

                    subplot(3,1,3);hold on;
                    plotCORR(npks_burst,dur_id_corr(keepid),ifr);
                end    
            else
                continue
            end
        end
    end
end

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        if ifr == 1
            temp(spktimes(1:end-1)) = 1./diff(x);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-seqst:seqend];
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/second

function [burstst burstend] = peakborder(wc,id,locs,tb);
    burstend = wc(id,2)+(wc(id,2)-locs(id));
    burstst = wc(id,1)-(locs(id)-(wc(id,1)));
    if id<size(wc,1)
        if burstend > wc(id+1,1)
            burstend = ceil((wc(id,2)+wc(id+1,1))/2);
        end
    end
    if id ~= 1
        if burstst < wc(id-1,2)
            burstst = floor((wc(id,1)+wc(id-1,2))/2);
        end
    end
    if burstst <= 0
        burstst = 1;
    end
    if burstend > length(tb)
        burstend = length(tb);
    end
    
function npks = countspks(spktms,tm1,tm2,ifr);
if length(tm1) == 1
    if ifr == 0
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x) find(x(1:end-1)>=tm1&x(1:end-1)<tm2),spktms,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) median(x(y)),spktms_diff,id);%average ifr in each trial
        npks = 1000*(1./npks);
    end
else
    if ifr == 0
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x,y,z) find(x(1:end-1)>=y & x(1:end-1)< z),spktms,tm1,tm2,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) median(x(y)),spktms_diff,id);
        npks = 1000*(1./npks);
    end
end
    
function [r p] = shuffle(npks_burst,dur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);  
    
    
function T = maketable(name,seqid,dur_id_corr,npks_burst,pct_error,pkactivity,corrpval);
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    birdid = repmat({unitid(1:regexp(unitid,'_')-1)},length(dur_id_corr),1);
    unitid = repmat({unitid},length(dur_id_corr),1);
    seqid = repmat(seqid,length(dur_id_corr),1);
    dur_id_corrn = (dur_id_corr-nanmean(dur_id_corr))/nanstd(dur_id_corr);
    npks_burstn = (npks_burst-mean(npks_burst))/std(npks_burst);
    unittype = repmat(mean(pct_error),length(dur_id_corr),1);
    activitylevel = repmat(pkactivity,length(dur_id_corr),1);
    corrpval = repmat(corrpval,length(dur_id_corr),1);
    T = table(dur_id_corrn,npks_burstn,unittype,activitylevel,birdid,unitid,seqid,corrpval,'VariableNames',...
        {'dur','spikes','unittype','activity','birdid','unitid','seqid','corrpval'});
                 
function plotraster(dur_id,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,corrval)
    thr1 = quantile(dur_id,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id <= thr1);
    thr2 = quantile(dur_id,0.75);%threshold for large gaps
    largegaps_id = find(dur_id >= thr2);
    if length(tm1) == 1
        spktms_inburst = cellfun(@(x) x(find(x>=tm1&x<tm2)),spktms,'un',0);
    else
        spktms_inburst = cellfun(@(x,y,z) x(find(x>=y&x<z)),spktms,tm1,tm2,'un',0);
    end
    cnt=0;
    for m = 1:length(dur_id)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
        end
        if ~isempty(spktms_inburst{m})
            plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'b');hold on;
        end
        for syll=1:size(seqons,2)
            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-anchor(m),...
                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
        end
        cnt=cnt+1;
    end
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    singleunit = mean(pct_error)<=0.01;
    title([unitid,' ',seqid,' r=',num2str(corrval),' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    plot(-seqst,min(smallgaps_id),'r>','markersize',4,'linewidth',2);hold on;
    plot(-seqst,max(largegaps_id),'b>','markersize',4,'linewidth',2);hold on;
        
function plotPSTH(seqst,seqend,smooth_spiketrains,dur_id,tm1,tm2);
    thr1 = quantile(dur_id,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id <= thr1);
    thr2 = quantile(dur_id,0.75);%threshold for large gaps
    largegaps_id = find(dur_id >= thr2);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(smallgaps_id,:),1)-...
        stderr(smooth_spiketrains(smallgaps_id,:),1)...
        fliplr(mean(smooth_spiketrains(smallgaps_id,:),1)+...
        stderr(smooth_spiketrains(smallgaps_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(largegaps_id,:),1)-...
        stderr(smooth_spiketrains(largegaps_id,:),1)...
        fliplr(mean(smooth_spiketrains(largegaps_id,:),1)+...
        stderr(smooth_spiketrains(largegaps_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    plot(repmat([tm1 tm2],2,1),yl,'g','linewidth',2);hold on;
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');

function plotCORR(npks_burst,dur_id_corr,ifr);
    scatter(npks_burst,dur_id_corr,'k.');hold on;
    xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    if ifr == 0
        xlabel('number of spikes');
    else
        xlabel('IFR');
    end
    ylabel('gap duration (ms)');
    set(gca,'fontweight','bold');

    
        
