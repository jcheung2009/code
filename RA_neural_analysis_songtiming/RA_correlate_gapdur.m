function [corrtable rawdatatable corrtrial] = RA_correlate_gapdur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,targetactivity,targetdur,...
    plotcasecondition,mode,ifr,winsize,gap_or_syll,varargin)
%detect bursting activity in premotor window of target song element and
%perform multiple linear regression for element duration and firing rate 

%parameters
%seqlen = length of syllable sequence in which target element is embedded
%(use even # for gap and odd for syll, ie: seqlen = 6 for gap between syllable 3 and 4)
%minsampsize = minimum number of trials 
%activitythresh = threshold for mean activity in target window in Hz
%motorwin = -40 (40 ms premotor window)
%targetactivity = 0 (-1:previous, 0:current, 1:next) for using
%activity at the prev, current, or next element
%targetdur = 0 (-1:previous, 0:current, 1:next) for using the target
% element at the prev, current, or next position
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y-' (non-significant cases)
%alignby=1 or 2 (gap: offset of prev syllable VS onset of prev syllable; 
%syll: on1 or onset of target syll VS offset of previous syll)
%mode = 'burst' for restricting analysis to bursts and detecting burst borders,'spikes' for counting
%any spikes in a fixed 40 ms window
%ifr = 1 or 0 (instantaneous FR or spike count)
%gap_or_syll = 'gap' or 'syll'
%winsize = length of gaussian window for convolution
%varargin = string variables for controlling in multiple regression (ie.
%'volume','duration', 'duration' refers to for neighboring sylls)
%output
%corrtable: summary table for each case 
%rawdatatable: the FR and other behavior characteristics for each case
%corrtrial: results for trial-lag correlation 1x3 matrix [lag-corr, lag, shuffled-lag-corr] 

%% parameters
win = gausswin(winsize);%for smoothing spike trains, 10-20 ms
win = win./sum(win);
shufftrials = 1000;%number of trials for shuffle
fs= 32000;%sampling rate
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y+')
    plotcasecondition = ['rpval<=0.05 & pkFR >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y++')
    plotcasecondition = ['rpval<=0.05 & abs(r(2)) >= 0.3 & pkFR >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y-')
    plotcasecondition = ['rpval>0.05 & pkFR >=',num2str(activitythresh)];
end

%% 
corrtrial = {};

corrtable = table([],[],[],[],[],[],[],[],[],[],[],[],[],[],'VariableNames',...
                    {'birdid','unitid','seqid','burstid','alignby',...
                    'pkFR','pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'latency','corrs','shuffle'});

rawdatatable = table([],[],[],[],[],[],[],[],[],[],[],[],[],[],'VariableNames',{'dur','spikes',...
    'pct_error','burstvar','pkFR','activity','birdid','unitid','seqid','burstid','vol1','vol2','dur1','dur2'});

%iterate through each unit summary "combined data" file 
ff = load_batchf(batchfile);
for i = 1:length(ff)
    disp(ff(i).name);
    [~,stid] = regexp(ff(i).name,'data_');
    enid = regexp(ff(i).name,'_TH');
    unitid = ff(i).name(stid+1:enid-1);
    birdid = unitid(1:regexp(unitid,'_')-1);
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %unique sequences of a given length that greater than min # of trials
    gapids = find_uniquelbls(labels,seqlen,minsampsize);
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    durs_all = offsets-onsets;
    
    %iterate through each unique sequence found
    for n = 1:length(gapids)
       
        %remove trials that are outliers where target element duration > 3
        %STD
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));% absolute time 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        if strcmp(gap_or_syll,'gap')
            dur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);
        elseif strcmp(gap_or_syll,'syll')
            dur_id = jc_removeoutliers(durs_all(idx+ceil(seqlen/2)-1),3);
        end
        dur_id = jc_removeoutliers(dur_id,3);
        id = find(isnan(dur_id));dur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        %remove trials where sequence length > 1 sec
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);
            seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
        end
        if length(dur_id)<minsampsize
            continue
        end
        
        %order trials by target element duration
        if nargout < 3
            [~,ix] = sort(dur_id,'descend');
            dur_id = dur_id(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);
        end

        %offsets for alignment
        durseq = seqoffs-seqons;
        gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
        if strcmp(gap_or_syll,'gap')
            offset = durseq(:,seqlen/2+targetactivity);
            offset = [mean(offset)+motorwin, mean(offset)];
        elseif strcmp(gap_or_syll,'syll')
            offset = gapseq(:,ceil(seqlen/2)-1+targetactivity);
            offset = [mean(offset)+motorwin, mean(offset)];
        end
        
        %target dur for correlation 
        if targetdur ~= 0
            if strcmp(gap_or_syll,'gap')
                dur_id_corr = gapseq(:,seqlen/2+targetdur);
            elseif strcmp(gap_or_syll,'syll')
                dur_id_corr = durseq(:,ceil(seqlen/2)+targetdur);
            end
        else
            dur_id_corr = dur_id;    
        end
        
        %first anchor for alignment (gap: prev syll offset,
        %syll: onset) 
        pt = [motorwin 0];
        if strcmp(gap_or_syll,'gap')
            anchor = seqoffs(:,seqlen/2+targetactivity);
        elseif strcmp(gap_or_syll,'syll')
            anchor = seqons(:,ceil(seqlen/2)+targetactivity);
        end
        seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to alignment point 
        seqend = ceil(max(seqoffs(:,end)-anchor));%end border 
        
        %secondary anchor (gap: prev syll onset,
        %syll: prev syll's offset) 
        pt2 = offset;
        if strcmp(gap_or_syll,'gap')
            anchor2 = seqons(:,seqlen/2+targetactivity);
        elseif strcmp(gap_or_syll,'syll')
            anchor2 = seqoffs(:,ceil(seqlen/2)+targetactivity-1);
        end
        seqst2 = ceil(max(anchor2-seqons(:,1)));
        seqend2 = ceil(max(seqoffs(:,end)-anchor2));
        
        %average pairwise correlation of spike trains 
        varfr = trialbytrialcorr_spiketrain(spiketimes,seqst,seqend,anchor,pt,win);
        varfr2 = trialbytrialcorr_spiketrain(spiketimes,seqst2,seqend2,anchor2,pt2,win);

        %decide to align by target or secondary anchor
        if varfr<varfr2
            alignby=2;anchor= anchor2;seqst=seqst2;seqend=seqend2;
            pt=pt2;varfr=varfr2;
        else
            alignby=1;
        end
        
        %compute PSTH from spike trains for specific alignment
        [PSTH_mn tb smooth_spiketrains spktms spkpost] = smoothtrain(...
            spiketimes,spikeposterior,seqst,seqend,anchor,win,ifr);
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,ifr);
        
        if strcmp(mode,'burst')
            
            %find peaks/bursts in PSTH in premotor window
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',20,'MinPeakWidth',10,...
                'MinPeakDistance',15,'MinPeakHeight',mean(PSTH_mn_rand)+20,...
                'Annotate','extents','WidthReference','halfheight');
            pkid = find(tb(locs)>=pt(1) & tb(locs)<=pt(2));
            wc = round(wc);
            if isempty(pkid)
                continue
            end
            
            %iterate thru each burst found, correlate with target dur
            %(usually won't find more than one burst for a specific
            %unit-sequence)
            burstid = 0;lastburstst=NaN;lastburstend=NaN;
            for ixx = 1:length(pkid)
                
                %define peak borders and other peak characteristics
                [burstst burstend] = peakborder2(locs(pkid(ixx)),...
                    tb,PSTH_mn,mean(PSTH_mn_rand));
                if tb(burstend)>pt(2)+20 | tb(burstst)< pt(1)-20 | ...
                        tb(burstend)-tb(burstst)<10 | ...
                        mean(PSTH_mn(burstst:burstend)) < activitythresh | ...
                        (burstst==lastburstst & burstend==lastburstend)
                    continue
                end
                wth = tb(burstend)-tb(burstst);
                gaplatency = ((tb(burstst)+tb(burstend))/2)-pt(2);
                pkFR = mean(PSTH_mn(burstst:burstend));
                pkactivity = (pkFR-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;  
                lastburstst = burstst;lastburstend = burstend;
                
                %extract volume for syllables adjacent to target dur and
                %correlate with target burst
                vol1 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                    seqons(:,ceil(seqlen/2)),seqoffs(:,ceil(seqlen/2)),'un',1);
                vol2 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                    seqons(:,ceil(seqlen/2)+1),seqoffs(:,ceil(seqlen/2)+1),'un',1);
                
                %correlation with target and adjacent elements (border
                %syllables  or gaps) 
                if strcmp(gap_or_syll,'gap')
                    dur1_id = seqoffs(:,seqlen/2+targetdur)-...
                        seqons(:,seqlen/2+targetdur);%previous syll
                    dur2_id = seqoffs(:,seqlen/2+targetdur+1)-...
                        seqons(:,seqlen/2+targetdur+1);%next syll
                elseif strcmp(gap_or_syll,'syll')
                    dur1_id = seqons(:,ceil(seqlen/2)+targetdur)-...
                        seqoffs(:,ceil(seqlen/2)+targetdur-1);%previous gap
                    dur2_id = seqons(:,ceil(seqlen/2)+targetdur+1)-...
                        seqoffs(:,ceil(seqlen/2)+targetdur);%next gap
                end
   
                %normalize predictors and fit multiple regression and
                %partial corrs
                dur_id_corrn = (dur_id_corr-mean(dur_id_corr))/std(dur_id_corr);
                vol1n = (vol1-mean(vol1))/std(vol1);
                vol2n = (vol2-mean(vol2))/std(vol2);
                dur1_idn = (dur1_id-mean(dur1_id))/std(dur1_id);
                dur2_idn = (dur2_id-mean(dur2_id))/std(dur2_id);
                controlvars = [];
                if isempty(varargin)
                    mdl = fitlm(dur_id_corrn,npks_burst);
                    [rho rpval] = corrcoef(dur_id_corrn,npks_burst);
                    rho = rho(2); rpval = rpval(2);
                else
                    if find(strcmp(varargin,'volume'))
                        controlvars = [controlvars vol1n vol2n];
                    end
                    if find(strcmp(varargin,'duration'))
                        controlvars = [controlvars dur1_idn dur2_idn];
                    end
                    mdl = fitlm([dur_id_corrn controlvars],npks_burst);
                    [rho rpval] = partialcorr(dur_id_corrn,npks_burst,controlvars);
                end
                betas = mdl.Coefficients.Estimate(2:end);
                pVals = mdl.Coefficients.pValue(2:end);
                
                
                %n-trial lag correlation 
                if nargout > 2
                    [r p] = corrcoef(npks_burst,dur_id_corr);
                    if p(2)<=0.05
                        [trcorr lag] = xcov(npks_burst,dur_id_corr,'coeff');
                        [shuffcorrtrial lag] = shuffletrialcorr(npks_burst,dur_id_corr,shufftrials);
                        corrtrial = [corrtrial; [trcorr lag' shuffcorrtrial]];
                    end
                end

                %shuffle test for proportion of cases with significant
                %correlations
                [shuffbetas shuffpVals shuffr shuffp] = shuffle_multipleregress...
                    (npks_burst,[dur_id_corrn controlvars],shufftrials);

                %save measurements and variables
                burstid = burstid+1;
                corrtable = [corrtable; table({birdid},{unitid},gapids(n),burstid,alignby,...
                    pkFR,pkactivity,wth,mean(pct_error),length(dur_id_corr),varfr,...
                    gaplatency,{betas pVals rho rpval},...
                    {shuffbetas shuffpVals shuffr shuffp},'VariableNames',...
                    {'birdid','unitid','seqid','burstid','alignby',...
                    'pkFR','pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'latency','corrs','shuffle'})];

                 rawdatatable = [rawdatatable; table(dur_id_corr,npks_burst,...
                    repmat(mean(pct_error),length(npks_burst),1),...
                    repmat(varfr,length(npks_burst),1),...
                    repmat(pkFR,length(npks_burst),1),...
                    repmat(pkactivity,length(npks_burst),1),...
                    repmat({birdid},length(npks_burst),1),...
                    repmat({unitid},length(npks_burst),1),...
                    repmat(gapids(n),length(npks_burst),1),...
                    repmat(burstid,length(npks_burst),1),...
                    vol1,vol2,dur1_id,dur2_id,...
                    'VariableNames',{'dur','spikes','pct_error','burstvar','pkFR','activity',...
                    'birdid','unitid','seqid','burstid','vol1','vol2','dur1','dur2'})];
                
                %plot significant cases
                if eval(plotcasecondition)
                    figure;subplot(3,1,1);hold on
                    plotraster(dur_id_corr,spktms,tb(burstst),tb(burstend),...
                        seqons,seqoffs,seqst,seqend,anchor,ff(i).name,...
                        (pct_error),gapids{n},rho);
                    
                    subplot(3,1,2);hold on;
                    plotPSTH(seqst,seqend,smooth_spiketrains,dur_id_corr,...
                        tb(burstst),tb(burstend));

                    subplot(3,1,3);hold on;
                    plotCORR(npks_burst,dur_id_corr,ifr);
                    
                    if exist('song') & length_song == length(song)
                        figure;subplot(2,1,1);hold on;
                        if strcmp(gap_or_syll,'gap')
                            anch = seqoffs(:,ceil(seqlen/2)+targetactivity);
                        elseif strcmp(gap_or_syll,'syll')
                            anch = seqons(:,ceil(seqlen/2)+targetactivity);
                        end
                        plotampenv(dur_id_corr,song,seqons,seqoffs,anch,fs);
                        subplot(2,1,2);hold on;
                        plotampenv_norm(dur_id_corr,song,seqons,seqoffs,anch,fs);
                    end
                end
            end
            
        elseif strcmp(mode,'spikes')
            
            tbid = find(tb>=pt(1) & tb <=pt(2));
            pkFR = mean(PSTH_mn(tbid));
            if pkFR < activitythresh
                continue
            end
            pkactivity = (max(PSTH_mn(tbid))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
            npks_burst = mean(smooth_spiketrains(:,tbid(1):tbid(end)),2).*1000; 

            %extract volume for syllables adjacent to target dur and
            %correlate with target burst
            vol1 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                seqons(:,ceil(seqlen/2)),seqoffs(:,ceil(seqlen/2)),'un',1);
            vol2 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                seqons(:,ceil(seqlen/2)+1),seqoffs(:,ceil(seqlen/2)+1),'un',1);

            %correlation with target and adjacent elements (border
            %syllables  or gaps) 
            if strcmp(gap_or_syll,'gap')
                dur1_id = seqoffs(:,seqlen/2+targetdur)-...
                    seqons(:,seqlen/2+targetdur);%previous syll
                dur2_id = seqoffs(:,seqlen/2+targetdur+1)-...
                    seqons(:,seqlen/2+targetdur+1);%next syll
            elseif strcmp(gap_or_syll,'syll')
                dur1_id = seqons(:,ceil(seqlen/2)+targetdur)-...
                    seqoffs(:,ceil(seqlen/2)+targetdur-1);
                dur2_id = seqons(:,ceil(seqlen/2)+targetdur+1)-...
                    seqoffs(:,ceil(seqlen/2)+targetdur);
            end

            dur_id_corrn = (dur_id_corr-mean(dur_id_corr))/std(dur_id_corr);
            vol1n = (vol1-mean(vol1))/std(vol1);
            vol2n = (vol2-mean(vol2))/std(vol2);
            dur1_idn = (dur1_id-mean(dur1_id))/std(dur1_id);
            dur2_idn = (dur2_id-mean(dur2_id))/std(dur2_id);
            mdl = fitlm([dur_id_corrn vol1n vol2n],npks_burst);
            betas = mdl.Coefficients.Estimate(2:end);
            pVals = mdl.Coefficients.pValue(2:end);
            [rho rpval] = partialcorr(dur_id_corrn,npks_burst,[vol1n vol2n]);
            [shuffbetas shuffpVals shuffr shuffp] = shuffle_multipleregress...
                (npks_burst,[dur_id_corrn vol1n vol2n],shufftrials);
            
            %save measurements and variables
            gaplatency=NaN;burstid=NaN;wth=NaN;
            corrtable = [corrtable; table({birdid},{unitid},gapids(n),burstid,alignby,...
                    pkFR,pkactivity,wth,mean(pct_error),length(dur_id_corr),varfr,...
                    gaplatency,{betas pVals rho rpval},...
                    {shuffbetas shuffpVals shuffr shuffp},'VariableNames',...
                    {'birdid','unitid','seqid','burstid','alignby',...
                    'pkFR','pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'latency','corrs','shuffle'})];

             rawdatatable = [rawdatatable; table(dur_id_corr,npks_burst,...
                repmat(mean(pct_error),length(npks_burst),1),...
                repmat(varfr,length(npks_burst),1),...
                repmat(pkFR,length(npks_burst),1),...
                repmat(pkactivity,length(npks_burst),1),...
                repmat({birdid},length(npks_burst),1),...
                repmat({unitid},length(npks_burst),1),...
                repmat(gapids(n),length(npks_burst),1),...
                repmat(burstid,length(npks_burst),1),...
                vol1,vol2,dur1_id,dur2_id,...
                'VariableNames',{'dur','spikes','pct_error','burstvar','pkFR','activity',...
                'birdid','unitid','seqid','burstid','vol1','vol2','dur1','dur2'})];
            
            %plot significant cases
            if eval(plotcasecondition)
                figure;subplot(3,1,1);hold on
                plotraster(dur_id_corr,spktms,tb(tbid(1)),tb(tbid(end)),...
                    seqons,seqoffs,seqst,seqend,anchor,ff(i).name,(pct_error),...
                    gapids{n},rho);
  
                subplot(3,1,2);hold on;
                plotPSTH(seqst,seqend,smooth_spiketrains,dur_id_corr,...
                    tb(tbid(1)),tb(tbid(end)));

                subplot(3,1,3);hold on;
                plotCORR(npks_burst,dur_id_corr,ifr);

                if exist('song')
                    figure;hold on;
                    plotampenv(dur_id_corr,seqons,seqoffs,anchor,fs);
                end
            end  
        end
    end
end

function [PSTH_mn tb smooth_spiketrains spktms spkpost] = smoothtrain...
        (spiketimes,spikeposterior,seqst,seqend,anchor,win,ifr);
    %tb, PSTH_mn = timebase, average firing pattern across all trials, 
    %smooth_spiketrains = spike trains for each trial after convolution, 
    %spktms = time of each spike relative to anchor point in each trial
    %spkpost = posterior probability of spike to be in classified cluster
    spktms = cell(size(anchor,1),1);
    if ~isempty(spikeposterior)
        spkpost = cell(size(anchor,1),1);
    end
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        if ~isempty(spikeposterior)
            spkpost{m} = spikeposterior(find(spiketimes>=(anchor(m)-seqst) & ...
                spiketimes<=(anchor(m)+seqend)),end);
        end
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        if ifr == 1
            temp = instantfr(spktms{m},-seqst:seqend);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-seqst:seqend];
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/second

function [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,ifr);
        %same as smoothtrain but spike trains are shuffled
    spktms = cell(size(anchor,1),1);
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        if ifr == 1
            temp = instantfr(spktms{m},-seqst:seqend);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = temp;
    end
    tb = [-seqst:seqend];
    smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
    smooth_spiketrains_rand = conv2(1,win,smooth_spiketrains_rand,'same');
    PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
        
function r = trialbytrialcorr_spiketrain(spiketimes,seqst,seqend,anchor,pt,win);
 %pairwise trial correlation based on smoothed spike trains when computed by spikes, not ifr
    [~,tb,smooth_spiketrains] = smoothtrain(spiketimes,'',seqst,seqend,anchor,win,0);
    tbid = find(tb>=pt(1) & tb<=pt(2));
    r = xcov(smooth_spiketrains(:,tbid)',0,'coeff');
    r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
    r = r(find(triu(r,1)));
    r = nanmean(r);
    
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
    
function [id cnts] = find_uniquelbls(stringvect,seqlen,mincnt);
%given string vector, find unique sequences of length seqlen and minimum
%occurence (mincnt), eliminates full repeats and sequences containing
%non-alpha characters
    N = length(stringvect);
    [id, ~, nn] = unique(stringvect(bsxfun(@plus,1:seqlen,(0:N-seqlen)')),'rows');
    cnts = sum(bsxfun(@(x,y)x==y,1:size(id,1),nn))';
    removeind = [];
    for ii = 1:size(id,1)
        if length(unique(id(ii,:)))==1 | sum(~isletter(id(ii,:))) > 0 %remove repeats and sequences with non-alpha
            removeind = [removeind;ii];
        end
    end
    cnts(removeind) = [];id(removeind,:) = [];
    ind = find(cnts >= mincnt);%only sequences that occur more than 25 times 
    id = id(ind,:);cnts = cnts(ind);
    id = mat2cell(id,repmat(1,size(id,1),1))';

function [burstst burstend] = peakborder2(id,tb,PSTH,activitythresh);
 %peak borders based on when activity falls back below activity threshold   
    FRbelow = find(PSTH<=activitythresh);
    if FRbelow(1) ~= 1
        FRbelow = [1 FRbelow];
    elseif FRbelow(end) ~= length(tb)
        FRbelow = [FRbelow length(tb)];
    end
    burstst = FRbelow(find(diff(id-FRbelow>0)<0));
    burstend = FRbelow(find(diff(id-FRbelow<0)==1)+1);
    
function burstspkposterior = burstposterior(spktms,spkpost,tm1,tm2);
    id = cellfun(@(x) (find(x>=tm1 & x<tm2)),spktms,'un',0);
    burstspkposterior = cell2mat(cellfun(@(x,y) x(y),spkpost,id,'un',0));
    
function npks = countspks(spktms,tm1,tm2);
    if length(tm1) == 1
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    else
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    end
    npks = 1000*(npks./(tm2-tm1));
    
function [r p] = shuffle(npks_burst,dur_id_corr,shufftrials);
    %shuffle trial identity between neural activity and behavior, and then
    %compute regression (shufftrials = number of times to perform shuffle)
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);  

function [betas pVals r p] = shuffle_multipleregress(npks_burst,vars,shufftrials);
    %shuffle trial identity between neural activity and behavior, and then
    %compute multiple regression (shufftrials = number of times to perform shuffle)
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    betas = NaN(shufftrials,size(vars,2));pVals = NaN(shufftrials,size(vars,2));
    r = NaN(shufftrials,1);p = NaN(shufftrials,1);
    parfor n = 1:size(npks_burst_shuff,1);
        mdl = fitlm(vars,npks_burst_shuff(n,:));
        betas(n,:) = mdl.Coefficients.Estimate(2:end);
        pVals(n,:) = mdl.Coefficients.pValue(2:end);
        if size(vars,2) == 1
            [rho rpval] = corrcoef(npks_burst_shuff(n,:)',vars);
            r(n) = rho(2);
            p(n) = rpval(2);
        else
            [r(n) p(n)] = partialcorr(npks_burst_shuff(n,:)',vars(:,1),vars(:,2:end));
        end
    end

function [r l] = shuffletrialcorr(npks_burst,dur_id_corr,shufftrials);
    %shuffle trials before performing trial-lag correlation 
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r l] = xcov([npks_burst_shuff',dur_id_corr],'coeff');
    r =r(:,shufftrials+1:shufftrials+1:end-shufftrials+1);
                 
function plotraster(dur_id,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,corrval)
%raster plot for all trials of a case, ordered by target el duration
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
    singleunit = mean(pct_error)<=0.02;
    title([unitid,' ',seqid,' r=',num2str(corrval),' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    plot(-seqst,min(smallgaps_id),'r>','markersize',4,'linewidth',2);hold on;
    plot(-seqst,max(largegaps_id),'b>','markersize',4,'linewidth',2);hold on;
        
function plotPSTH(seqst,seqend,smooth_spiketrains,dur_id,tm1,tm2);
    %plot average PSTH, as well as average PSTH in the upper and lower
    %quartiles
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
    %scatter plot with least squares line 
    scatter(npks_burst,dur_id_corr,'k.');hold on;
    xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    if ifr == 0
        xlabel('FR');
    else
        xlabel('IFR');
    end
    ylabel('gap duration (ms)');
    set(gca,'fontweight','bold');

function plotampenv(dur_id_corr,song,seqons,seqoffs,anchor,fs);
    %plot smooth, rectifed amplitude envelop of target sequence aligned by
    %target element anchor
    sm = arrayfun(@(x,y) song(floor(x*1e-3*fs):ceil(y*1e-3*fs)),seqons(:,1),seqoffs(:,end),'un',0);
    tb = arrayfun(@(x,y,z) [floor(x*1e-3*fs):ceil(y*1e-3*fs)]-floor(z*1e-3*fs),seqons(:,1),seqoffs(:,end),anchor,'un',0);
    thr1 = quantile(dur_id_corr,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id_corr <= thr1);
    thr2 = quantile(dur_id_corr,0.75);%threshold for large gaps
    largegaps_id = find(dur_id_corr >= thr2);
    minst = min(cellfun(@(x) x(1),tb));
    maxed = max(cellfun(@(x) x(end),tb));
    smallgaps_ampenv = cell2mat(cellfun(@(x,y) [NaN(1,x(1)-minst) log(y) NaN(1,maxed-x(end))],tb(smallgaps_id),sm(smallgaps_id),'un',0));
    largegaps_ampenv = cell2mat(cellfun(@(x,y) [NaN(1,x(1)-minst) log(y) NaN(1,maxed-x(end))],tb(largegaps_id),sm(largegaps_id),'un',0));
    timebase = minst:maxed;
    notnan = ~isnan(nanmean(smallgaps_ampenv,1));
    patch([timebase(notnan) fliplr(timebase(notnan))]./fs,[nanmean(smallgaps_ampenv(:,notnan),1)-...
        nanstderr(smallgaps_ampenv(:,notnan),1) fliplr(nanmean(smallgaps_ampenv(:,notnan),1)+...
        nanstderr(smallgaps_ampenv(:,notnan),1))],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
    notnan = ~isnan(nanmean(largegaps_ampenv,1));
    patch([timebase(notnan) fliplr(timebase(notnan))]./fs,[nanmean(largegaps_ampenv(:,notnan),1)+...
        nanstderr(largegaps_ampenv(:,notnan),1) fliplr(nanmean(largegaps_ampenv(:,notnan),1)-...
        nanstderr(largegaps_ampenv(:,notnan),1))],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
    xlim([-0.3 0.3]);
    ylabel('amplitude');xlabel('seconds');legend({'short','long'});
    
 function plotampenv_norm(dur_id_corr,song,seqons,seqoffs,anchor,fs);
     %same as plotampenv, normalized
    sm = arrayfun(@(x,y) song(floor(x*1e-3*fs):ceil(y*1e-3*fs)),seqons(:,1),seqoffs(:,end),'un',0);
    tb = arrayfun(@(x,y,z) [floor(x*1e-3*fs):ceil(y*1e-3*fs)]-floor(z*1e-3*fs),seqons(:,1),seqoffs(:,end),anchor,'un',0);
    thr1 = quantile(dur_id_corr,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id_corr <= thr1);
    thr2 = quantile(dur_id_corr,0.75);%threshold for large gaps
    largegaps_id = find(dur_id_corr >= thr2);
    minst = min(cellfun(@(x) x(1),tb));
    maxed = max(cellfun(@(x) x(end),tb));
    smallgaps_ampenv = cell2mat(cellfun(@(x,y) [NaN(1,x(1)-minst) log(y) NaN(1,maxed-x(end))],tb(smallgaps_id),sm(smallgaps_id),'un',0));
    largegaps_ampenv = cell2mat(cellfun(@(x,y) [NaN(1,x(1)-minst) log(y) NaN(1,maxed-x(end))],tb(largegaps_id),sm(largegaps_id),'un',0));
    timebase = minst:maxed;
    smallgaps_ampenv = (smallgaps_ampenv-min(smallgaps_ampenv,[],2))./max(smallgaps_ampenv,[],2);
    largegaps_ampenv = (largegaps_ampenv-min(largegaps_ampenv,[],2))./max(largegaps_ampenv,[],2);
    notnan = ~isnan(nanmean(smallgaps_ampenv,1));
    patch([timebase(notnan) fliplr(timebase(notnan))]./fs,[nanmean(smallgaps_ampenv(:,notnan),1)-...
    nanstderr(smallgaps_ampenv(:,notnan),1) fliplr(nanmean(smallgaps_ampenv(:,notnan),1)+...
    nanstderr(smallgaps_ampenv(:,notnan),1))],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
    notnan = ~isnan(nanmean(largegaps_ampenv,1));
    patch([timebase(notnan) fliplr(timebase(notnan))]./fs,[nanmean(largegaps_ampenv(:,notnan),1)+...
        nanstderr(largegaps_ampenv(:,notnan),1) fliplr(nanmean(largegaps_ampenv(:,notnan),1)-...
        nanstderr(largegaps_ampenv(:,notnan),1))],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
    xlim([-0.3 0.3]);
    ylabel('amplitude');xlabel('seconds');legend({'short','long'});
