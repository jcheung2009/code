function [spk_vol_corr case_name dattable] = RA_correlate_gapvol(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,plotcasecondition,shuff,mode,ifr,gap_or_syll,predictors)
%correlate premotor spikes with current and subsequent syllable volume 
%seqlen = length of syllable sequence (use even # for gap and odd for syll)
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y+su' (...single units)
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity
%greater than thresh and multi unit), or 'ysu' (for activity greater than thresh and single units)
%spk_vol_corr = [corrcoef pval alignment firingrate width mn(pct_error)...
%numtrials, corrcoefdur1 pval corrcoefdur2 pval durmotorwin]
%alignby=1 or 2 (off1 vs on1: gap; on1 vs prevoff: syll)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%ifr = 1 use mean instantaneous FR or 0 use spike count
%gap_or_syll = 'gap' or 'syll'
%predictors = {'dur','volume1','volume2'}

%parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
fs= 32000;%sampling rate

spk_vol_corr = [];case_name = {};
dattable = table([],[],[],[],[],[],[],[],'VariableNames',{'dur','spikes',...
    'volume1','volume2','birdid','unitid','seqid','activity'});
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
            anchor = seqoffs(:,seqlen/2);
        elseif strcmp(gap_or_syll,'syll')
            anchor = seqons(:,ceil(seqlen/2));
        end
        seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-anchor));%end border 
        [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
        
        %compute PSTH when aligned to secondary target element
        if strcmp(gap_or_syll,'gap')
            anchor2 = seqons(:,seqlen/2);
        elseif strcmp(gap_or_syll,'syll')
            anchor2 = seqoffs(:,ceil(seqlen/2)-1);
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
            offset = durseq(:,seqlen/2);
            offset = [offset+motorwin, offset];
        elseif strcmp(gap_or_syll,'syll')
            offset = gapseq(:,ceil(seqlen/2)-1);
            offset = [offset+motorwin, offset];
        end

        %target vol for correlation 
        vol1 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
            seqons(:,ceil(seqlen/2)),seqoffs(:,ceil(seqlen/2)),'un',1);
        vol2 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
            seqons(:,ceil(seqlen/2)+1),seqoffs(:,ceil(seqlen/2)+1),'un',1);
        
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
                
                %normalize predictors
                vol1 = (vol1-mean(vol1))./std(vol1);
                vol2 = (vol2-mean(vol2))./std(vol2);
                dur_id = (dur_id-mean(dur_id))./std(dur_id);

                predmat = [];
                if ~isempty(find(strcmp(predictors,'volume1')))
                    predmat = [predmat vol1];
                end
                if ~isempty(find(strcmp(predictors,'volume2')))
                    predmat = [predmat vol2];
                end
                if ~isempty(find(strcmp(predictors,'dur')))
                    predmat = [predmat dur_id];
                end
                
                %shuffle analysis
                if ~isempty(strfind(shuff,'y'))
                    shufftrials = 1000;
                    if pkactivity < activitythresh
                        continue
                    end
                    [r p] = shuffle(npks_burst,predmat,shufftrials,predictors);
                    spk_vol_corr = [spk_vol_corr r p];
                else
                    
                   % mdl = fitlm(dur_id,npks_burst,'Varnames',{'dur','IFR'});
                    mdl = fitlm(predmat,npks_burst,'VarNames',...
                        [predictors,{'IFR'}]);
                    if ~isempty(find(strcmp(predictors,'volume1')))
                        vol1beta = mdl.Coefficients{'volume1',{'Estimate','pValue'}};
                    else
                        vol1beta = [NaN NaN];
                    end
                    if ~isempty(find(strcmp(predictors,'volume2')))
                        vol2beta = mdl.Coefficients{'volume2',{'Estimate','pValue'}};
                    else
                        vol2beta = [NaN NaN];
                    end
                    if ~isempty(find(strcmp(predictors,'dur')))
                        durbeta = mdl.Coefficients{'dur',{'Estimate','pValue'}};
                    else
                        durbeta = [NaN NaN];
                    end
                    
                    %save measurements and variables
                    spk_vol_corr = [spk_vol_corr; vol1beta vol2beta durbeta alignby pkactivity...
                        wth mean(pct_error) sum(~isnan(npks_burst)) max([varburst1 varburst2])];
                    case_name = [case_name,{ff(i).name,gapids{n}}];
                    T = maketable(ff(i).name,gapids(n),vol1,vol2,dur_id,npks_burst,pkactivity);
                    dattable=[dattable;T];
                end
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
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/secondactive

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
    thr1 = quantile(dur_id,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id <= thr1);
    thr2 = quantile(dur_id,0.75);%threshold for large gaps
    largegaps_id = find(dur_id >= thr2);
end
    
function [r p] = shuffle(npks_burst,predmat,shufftrials,predictors);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    r = NaN(shufftrials,size(predmat,2)); p = NaN(shufftrials,size(predmat,2));
    for n = 1:shufftrials
        mdl = fitlm(predmat,npks_burst_shuff(n,:),'VarNames',[predictors,{'IFR'}]);
        r(n,:) = mdl.Coefficients{predictors,{'Estimate'}}';
        p(n,:) = mdl.Coefficients{predictors,{'pValue'}}';
    end

function T = maketable(name,seqid,volume1,volume2,dur_id,npks_burst,pkactivity);
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    birdid = repmat({unitid(1:regexp(unitid,'_')-1)},length(dur_id),1);
    unitid = repmat({unitid},length(dur_id),1);
    seqid = repmat(seqid,length(dur_id),1);
    pkactivity = repmat(pkactivity,length(dur_id),1);
    T = table(dur_id,npks_burst,volume1,volume2,birdid,unitid,seqid,pkactivity,'VariableNames',...
        {'dur','spikes','volume1','volume2','birdid','unitid','seqid','activity'});
    