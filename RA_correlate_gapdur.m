function [spk_gapdur_corr case_name dattable] = RA_correlate_gapdur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,targetgapactivity,targetgapdur,plotcasecondition,shuff,mode,ifr)
%correlate premotor spikes with gapdur 
%seqlen = length of syllable sequence (use 6)
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
% targetgapactivity = 0;%-1:previous, 0:current, 1:next
% targetgapdur = 0;%-1:previous, 0:current, 1:next
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y+su' (...single units)
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity
%greater than thresh and multi unit), or 'ysu' (for activity greater than thresh and single units)
%spk_gapdur_corr = [corrcoef pval alignment firingrate width mn(pct_error)...
%numtrials, corrcoefdur1 pval corrcoefdur2 pval durmotorwin]
%alignby=1 or 2 (off1 or on2)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%ifr = 1 use mean instantaneous FR or 0 use spike count, outputs NaN on
%trials with only one spike in analysis window

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
    for n = 1:length(gapids)
        
        %remove outliers 
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        gapdur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);%remove trials with outliers in gap length
        gapdur_id = jc_removeoutliers(gapdur_id,3);
        id = find(isnan(gapdur_id));gapdur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);%remove trials where sequence length > 1 sec
            seqons(id,:) = [];seqoffs(id,:) = [];gapdur_id(id) = [];
        end
        if length(gapdur_id)<25
            continue
        end

        %compute PSTH from spike trains aligned to onset of target element
        anchor = seqoffs(:,seqlen/2+targetgapactivity);
        seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-anchor));%end border 
        [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win);
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
        PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
        
        %order trials by gapdur
        [~,ix] = sort(gapdur_id,'descend');
        gapdur_id = gapdur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);smooth_spiketrains=smooth_spiketrains(ix,:);
        if targetgapdur ~= 0
            gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
            gapdur_id_corr = gapseq(:,seqlen/2+targetgapdur);%gapdur for correlation with activity
        else
            gapdur_id_corr = gapdur_id;    
        end
        if targetgapactivity ~= 0
            gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
            gapoffset = gapseq(:,seqlen/2+targetgapactivity);
        else
            gapoffset = gapdur_id;
        end
        
        if strcmp(mode,'burst')
            %find peaks/bursts in PSTH in premotor window
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,...
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

                %compute PSTH when aligned to secondary target element
                anchor = seqons(:,seqlen/2+targetgapactivity+1);
                seqst2 = ceil(max(anchor-seqons(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
                seqend2 = ceil(max(seqoffs(:,end)-anchor));
                [PSTH_mn_on2 tb2 smooth_spiketrains_on2 spktms_on2] = smoothtrain(spiketimes,seqst2,seqend2,anchor,win);

                %find peak aligned to secondary anchor that corresponds to
                %target burst
                [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_on2,'MinPeakProminence',...
                    10,'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
                if ~isempty(locs2)
                    wc2 = round(wc2);
                    ix = find(tb2(locs2)>=motorwin-mean(gapoffset) & tb2(locs2)<=-mean(gapoffset));
                    if isempty(ix)
                         alignby=1;%off1
                         wth = w(pkid(ixx));anchor = seqoffs(:,seqlen/2+targetgapactivity);
                         pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                         npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                    else
                        [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor-seqoffs(:,seqlen/2+targetgapactivity)))));
                        [burstst2 burstend2] = peakborder(wc2,ix,locs2,tb2);

                        %use average pairwise correlation comparison to choose
                        %alignment
                        r = xcorr(smooth_spiketrains_on2(:,burstst2:burstend2)',0,'coeff');
                        r = reshape(r,[size(smooth_spiketrains_on2,1) size(smooth_spiketrains_on2,1)]);
                        r = r(find(triu(r,1)));
                        varburst2 = nanmean(r);

                        if varburst1 < varburst2
                            alignby=2;%on2
                            wth = w2(ix);anchor = seqons(:,seqlen/2+targetgapactivity+1);
                            pkactivity = (pks2(ix)-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                            npks_burst = countspks(spktms_on2,tb2(burstst2),tb2(burstend2),ifr);%extract nspks in each trial
                        else
                            alignby=1;%off1
                            wth = w(pkid(ixx));anchor = seqoffs(:,seqlen/2+targetgapactivity);
                            pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                            npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);%extract nspks in each trial
                        end
                    end
                else
                     alignby=1;%off1
                     wth = w(pkid(ixx));anchor = seqoffs(:,seqlen/2+targetgapactivity);
                     pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                     npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);%extract nspks in each trial
                end
                
                if sum(~isnan(npks_burst)) < 25
                    continue
                end
                
                %shuffle analysis
                if ~isempty(strfind(shuff,'y'))
                    shufftrials = 1000;
                    if isempty(strfind(shuff,'su')) %for multi unit shuff
                        if pkactivity >= activitythresh & mean(pct_error)>0.01
                              [r p] = shuffle(npks_burst,gapdur_id_corr,shufftrials);
                              spk_gapdur_corr = [spk_gapdur_corr r p];
                        else
                            continue
                        end
                    else %for single unit shuff
                        if mean(pct_error)<=0.01 & pkactivity >= activitythresh
                            [r p] = shuffle(npks_burst,gapdur_id_corr,shufftrials);
                            spk_gapdur_corr = [spk_gapdur_corr r p];
                        else
                            continue
                        end
                    end
                else
                    [r p] = corrcoef(npks_burst,gapdur_id_corr,'rows','complete');
                    dur1_id = seqoffs(:,seqlen/2+targetgapdur)-seqons(:,seqlen/2+targetgapdur);
                    dur2_id = seqoffs(:,seqlen/2+targetgapdur+1)-seqons(:,seqlen/2+targetgapdur+1);
                    [r1 p1] = corrcoef(npks_burst,dur1_id);
                    [r2 p2] = corrcoef(npks_burst,dur2_id);

                    %measure latency between burst and next syllable onset 
                    if targetgapactivity == 0 & targetgapdur == 0
                        if alignby==1
                            durmotorwin = tb(locs(pkid(ixx)))-mean(seqons(:,seqlen/2+1)-seqoffs(:,seqlen/2));
                        elseif alignby == 2
                            durmotorwin = tb2(locs2(ix));
                        end
                    else
                        durmotorwin = NaN;
                    end

                    spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2) alignby pkactivity...
                        wth mean(pct_error) sum(~isnan(npks_burst)) r1(2) p1(2) r2(2) p2(2) durmotorwin];

                    %variables for multilevel regression table
                    T = maketable(ff(i).name,gapids(n),gapdur_id_corr,npks_burst,pct_error,pkactivity,p(2));
                    dattable=[dattable;T];
                    case_name = [case_name,{T.unitid{1},T.seqid{1}}];
                end

                if eval(plotcasecondition)
                    figure;subplot(3,1,1);hold on
                    if alignby==1
                        plotraster(gapdur_id,spktms,tb,burstst,burstend,seqons,seqoffs,...
                            seqst,seqend,anchor,ff(i).name,pct_error,gapids{n},r(2));
                    elseif alignby==2
                        plotraster(gapdur_id,spktms_on2,tb2,burstst2,burstend2,seqons,seqoffs,...
                            seqst2,seqend2,anchor,ff(i).name,pct_error,gapids{n},r(2));
                    end

                    subplot(3,1,2);hold on;
                    if alignby==1
                        plotPSTH(seqst,seqend,smooth_spiketrains,gapdur_id,tb,burstst,burstend);
                    elseif alignby==2
                        plotPSTH(seqst2,seqend2,smooth_spiketrains_on2,gapdur_id,tb2,burstst2,burstend2);
                    end

                    subplot(3,1,3);hold on;
                    plotCORR(npks_burst,gapdur_id_corr);
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
                
                %compute PSTH when aligned to secondary target element
                anchor = seqons(:,seqlen/2+targetgapactivity+1);
                seqst2 = ceil(max(anchor-seqons(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
                seqend2 = ceil(max(seqoffs(:,end)-anchor));
                [PSTH_mn_on2 tb2 smooth_spiketrains_on2 spktms_on2] = smoothtrain(spiketimes,seqst2,seqend2,anchor,win);
                
                %average pairwise correlation of spike trains 
                tb2id = find(tb2>=motorwin-mean(gapoffset) & tb2 <=-mean(gapoffset));
                r = xcorr(smooth_spiketrains_on2(:,tb2id)',0,'coeff');
                r = reshape(r,[size(smooth_spiketrains_on2,1) size(smooth_spiketrains_on2,1)]);
                r = r(find(triu(r,1)));
                varfr2 = nanmean(r);
                
                if varfr < varfr2
                    alignby=2;%on2
                    anchor = seqons(:,seqlen/2+targetgapactivity+1);
                    pkactivity = (max(PSTH_mn_on2(tb2id))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    npks_burst = countspks(spktms_on2,tb2(tb2id(1)),tb2(tb2id(end)),ifr);%extract nspks in each trial
                else
                    alignby=1;%off1
                    anchor = seqoffs(:,seqlen/2+targetgapactivity);
                    pkactivity = (max(PSTH_mn(tbid))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    npks_burst = countspks(spktms,tb(tbid(1)),tb(tbid(end)),ifr);%extract nspks in each trial
                end
               
                if sum(~isnan(npks_burst)) < 25
                    continue
                end
                
                %shuffle analysis
                if ~isempty(strfind(shuff,'y'))
                    shufftrials = 1000;
                    if isempty(strfind(shuff,'su')) %for multi unit shuff
                        if mean(pct_error)>0.01 & pkactivity >= activitythresh
                              [r p] = shuffle(npks_burst,gapdur_id_corr,shufftrials);
                              spk_gapdur_corr = [spk_gapdur_corr r p];
                        else
                            continue
                        end
                    else %for single unit shuff
                        if mean(pct_error)<=0.01 & pkactivity >= activitythresh
                            [r p] = shuffle(npks_burst,gapdur_id_corr,shufftrials);
                            spk_gapdur_corr = [spk_gapdur_corr r p];
                        else
                            continue
                        end
                    end
                else
                    [r p] = corrcoef(npks_burst,gapdur_id_corr);
                    dur1_id = seqoffs(:,seqlen/2+targetgapdur)-seqons(:,seqlen/2+targetgapdur);
                    dur2_id = seqoffs(:,seqlen/2+targetgapdur+1)-seqons(:,seqlen/2+targetgapdur+1);
                    [r1 p1] = corrcoef(npks_burst,dur1_id);
                    [r2 p2] = corrcoef(npks_burst,dur2_id);

                    spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2) alignby pkactivity...
                        NaN mean(pct_error) sum(~isnan(npks_burst)) r1(2) p1(2) r2(2) p2(2) NaN];
                    
                    %variables for multilevel regression table
                    T = maketable(ff(i).name,gapids(n),gapdur_id_corr,npks_burst,pct_error,pkactivity,p(2));
                    dattable=[dattable;T];
                    case_name = [case_name,{T.unitid{1},T.seqid{1}}];
                end
                
                if eval(plotcasecondition)
                    figure;subplot(3,1,1);hold on
                    if alignby==1
                        plotraster(gapdur_id,spktms,tb,tbid(1),tbid(end),seqons,seqoffs,...
                            seqst,seqend,anchor,ff(i).name,pct_error,gapids{n},r(2));
                    elseif alignby==2
                        plotraster(gapdur_id,spktms_on2,tb2,tb2id(1),tb2id(end),seqons,seqoffs,...
                            seqst2,seqend2,anchor,ff(i).name,pct_error,gapids{n},r(2));
                    end

                    subplot(3,1,2);hold on;
                    if alignby==1
                        plotPSTH(seqst,seqend,smooth_spiketrains,gapdur_id,tb,tbid(1),tbid(end));
                    elseif alignby==2
                        plotPSTH(seqst2,seqend2,smooth_spiketrains_on2,gapdur_id,tb2,tb2id(1),tb2id(end));
                    end

                    subplot(3,1,3);hold on;
                    plotCORR(npks_burst,gapdur_id_corr);
                end    
            else
                continue
            end
        end
    end
end

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        temp(spktimes) = 1;
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
    if ifr == 0
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    elseif ifr == 1
        npks = cellfun(@(x) mean(diff(x(x>=tm1 & x<tm2))),spktms);%average ifr in each trial
        npks = 1000*(1./npks);
    end
    
function [r p] = shuffle(npks_burst,gapdur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',gapdur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);  
    
    
function T = maketable(name,seqid,gapdur_id_corr,npks_burst,pct_error,pkactivity,corrpval);
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    birdid = repmat({unitid(1:regexp(unitid,'_')-1)},length(gapdur_id_corr),1);
    unitid = repmat({unitid},length(gapdur_id_corr),1);
    seqid = repmat(seqid,length(gapdur_id_corr),1);
    gapdur_id_corrn = (gapdur_id_corr-nanmean(gapdur_id_corr))/nanstd(gapdur_id_corr);
    npks_burstn = (npks_burst-mean(npks_burst))/std(npks_burst);
    unittype = repmat(mean(pct_error),length(gapdur_id_corr),1);
    activitylevel = repmat(pkactivity,length(gapdur_id_corr),1);
    corrpval = repmat(corrpval,length(gapdur_id_corr),1);
    T = table(gapdur_id_corrn,npks_burstn,unittype,activitylevel,birdid,unitid,seqid,corrpval,'VariableNames',...
        {'dur','spikes','unittype','activity','birdid','unitid','seqid','corrpval'});
                 
function plotraster(gapdur_id,spktms,tb,burstst,burstend,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,corrval)
    thr1 = quantile(gapdur_id,0.25);%threshold for small gaps
    smallgaps_id = find(gapdur_id <= thr1);
    thr2 = quantile(gapdur_id,0.75);%threshold for large gaps
    largegaps_id = find(gapdur_id >= thr2);
    spktms_inburst = cellfun(@(x) x(find(x>=tb(burstst)&x<tb(burstend))),spktms,'un',0);
    cnt=0;
    for m = 1:length(gapdur_id)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
        end
        if ~isempty(spktms_inburst{m})
            plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'g');hold on;
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
        
function plotPSTH(seqst,seqend,smooth_spiketrains,gapdur_id,tb,burstst,burstend);
    thr1 = quantile(gapdur_id,0.25);%threshold for small gaps
    smallgaps_id = find(gapdur_id <= thr1);
    thr2 = quantile(gapdur_id,0.75);%threshold for large gaps
    largegaps_id = find(gapdur_id >= thr2);
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
    plot(repmat([tb(burstst) tb(burstend)],2,1),yl,'g','linewidth',2);hold on;
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');

function plotCORR(npks_burst,gapdur_id_corr);
    scatter(npks_burst,gapdur_id_corr,'k.');hold on;
    xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    xlabel('number of spikes');ylabel('gap duration (ms)');
    set(gca,'fontweight','bold');

    
        
