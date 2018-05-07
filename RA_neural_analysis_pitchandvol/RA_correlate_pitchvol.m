function [corrtable rawdatatable corrtrial_pitch corrtrial_mnvol corrtrial_amp] = ...
    RA_correlate_pitchvol(batchfile,seqlen, minsampsize,activitythresh,...
    motorwin,targetactivity,plotcasecondition,mode,ifr,winsize)
%correlate premotor spikes with pitch/volume 
%seqlen = length of syllable sequence, use 3 or 5
%minsampsize = minimum number of trials 
%activitythresh = threshold for mean activity in target window in Hz
%motorwin = -40 (40 ms premotor window)
% targetactivity = 0;%-1:previous, 0:current, 1:next
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases), 'y-'
%(plot everything)
%alignby=1 or 2 (on1 vs prevoff: syll)
%mode = 'burst' for restricting analysis to bursts and detecting burst borders,'spikes' for counting
%any spikes in a fixed 40 ms window
%ifr = 1 use mean instantaneous FR or 0 use spike count
%winsize = length of gaussian window for convolution

%% parameters
config; 
win = gausswin(winsize);%for smoothing spike trains, 20 ms
win = win./sum(win);
shufftrials = 1000;%number of trials for shuffle
fs= 32000;%sampling rate
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y+')
    plotcasecondition = ['(p_pitch<=0.05 | p_mnvol <=0.05 |',...
        ' p_amp <= 0.05) & pkFR >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y-')
    plotcasecondition = ['(p_pitch>0.05 & p_mnvol > 0.05 &',...
        ' p_amp > 0.05) & pkFR >=',num2str(activitythresh)];
end

%% 
corrtrial_pitch = {};corrtrial_mnvol = {};corrtrial_amp = {};

corrtable = table([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],...
                    'VariableNames',...
                    {'birdid','unitid','seqid','burstid','alignby',...
                    'pkFR','pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'latency','mnvol_corr','amp_corr','pitch_corr','shuffle_mnvol',...
                    'shuffle_amp','shuffle_pitch'});

rawdatatable = table([],[],[],[],[],[],[],[],[],[],[],[],[],'VariableNames',...
    {'meanvol','amp','pitch','sylldur','spikes','pct_error','burstvar','pkFR','activity',...
                    'birdid','unitid','seqid','burstid'});

ff = load_batchf(batchfile);
for i = 1:length(ff)
    disp(ff(i).name);
    [~,stid] = regexp(ff(i).name,'data_');enid = regexp(ff(i).name,'_TH');
    unitid = ff(i).name(stid+1:enid-1);
    birdid = unitid(1:regexp(unitid,'_')-1);
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %unique seq id
    seqids = find_uniquelbls(labels,seqlen,minsampsize);
    
    %for each unique sequence found  
    for n = 1:length(seqids)
%         disp(seqids{n});

        %get the onsets and offsets of syllables within sequence
        idx = strfind(labels,seqids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        
        %get amplitude and pitch vals of target syllable
        pitch = peak_pinterp_labelvec(idx+floor(seqlen/2))';
        pitch(pitch==0) = NaN;
        amplitude_pitchquant = amplitude_at_pitchquant(idx+floor(seqlen/2))';
        amplitude_pitchquant(amplitude_pitchquant==0) = NaN;
        amplitude_pitchquant = log10(amplitude_pitchquant);
        meanvol = arrayfun(@(x,y) mean(log10(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                    seqons(:,ceil(seqlen/2)),seqoffs(:,ceil(seqlen/2)),'un',1);
        sylldur = seqoffs(:,ceil(seqlen/2))-seqons(:,ceil(seqlen/2)); 
        
        %remove outliers in spectral measures
        pitch = jc_removeoutliers(pitch,3);
        amplitude_pitchquant = jc_removeoutliers(amplitude_pitchquant,3);
        meanvol = jc_removeoutliers(meanvol,3);
                
        %exclude trials where sequence length > 1 sec        
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);%remove trials where sequence length > 1 sec
            seqons(id,:) = [];seqoffs(id,:) = [];pitch(id) = [];
            amplitude_pitchquant(id) = []; meanvol(id) = [];sylldur(id) = [];
        end
        
        %exclude if number of trials is less than minimum sample size
        if length(pitch)<minsampsize
            continue
        end
        
        if seqlen > 1
            %offsets for secondary alignment
            gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
            offset = gapseq(:,ceil(seqlen/2)-1+targetactivity);
            offset = [mean(offset)+motorwin, mean(offset)];

            %anchors for aligning by target element
            pt = [motorwin 0];
            anchor = seqons(:,ceil(seqlen/2)+targetactivity);
            seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to target syll onset
            seqend = ceil(max(seqoffs(:,end)-anchor));%end border 

            %anchors for aligning by secondary element
            pt2 = offset;
            anchor2 = seqoffs(:,ceil(seqlen/2)+targetactivity-1);
            seqst2 = ceil(max(anchor2-seqons(:,1)));%boundaries for sequence activity relative to onset of prev gap
            seqend2 = ceil(max(seqoffs(:,end)-anchor2));

            %average pairwise correlation of spike trains 
            varfr = trialbytrialcorr_spiketrain(spiketimes,seqst,seqend,anchor,pt,win);

            %average pairwise trial by trial correlation
            varfr2 = trialbytrialcorr_spiketrain(spiketimes,seqst2,seqend2,anchor2,pt2,win);

            %decide to align by target or secondary 
            if varfr<varfr2
                alignby=2;anchor= anchor2;seqst=seqst2;seqend=seqend2;
                pt=pt2;varfr=varfr2;
            else
                alignby=1;
            end
        elseif seqlen == 1
            alignby = 1;
            pt = [motorwin 0];
            anchor = seqons;
            seqst = 500;%buffer by 500 ms
            seqend = 500;%
            varfr = NaN;
        end
        
        %compute PSTH from spike trains for specific alignment
        [PSTH_mn tb smooth_spiketrains spktms spkpost] = smoothtrain(...
            spiketimes,spikeposterior,seqst,seqend,anchor,win,ifr);
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,ifr);
        
        if strcmp(mode,'burst')
            
            %find peaks/bursts in PSTH in premotor window aligned to target
            %element
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',20,'MinPeakWidth',10,...
                'MinPeakDistance',15,'MinPeakHeight',mean(PSTH_mn_rand)+20,...
                'Annotate','extents','WidthReference','halfheight');
            pkid = find(tb(locs)>=pt(1) & tb(locs)<=pt(2));
            wc = round(wc);
            if isempty(pkid)
                continue
            end
            %for each burst found, correlate with target dur
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
                latency = ((tb(burstst)+tb(burstend))/2)-pt(2);
                pkFR = mean(PSTH_mn(burstst:burstend));
                pkactivity = (pkFR-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;  
                lastburstst = burstst;lastburstend = burstend;
                
                %n-trial lag correlation with pitch and volume
                if nargout >=3
                    [r p] = corrcoef(npks_burst,pitch,'rows','complete');
                    if p(2)<=0.05
                        [trcorr lag] = xcov(npks_burst,pitch,'coeff');
                        [shuffcorrtrial lag] = shuffletrialcorr(npks_burst,pitch,shufftrials);
                        corrtrial_pitch = [corrtrial_pitch; [trcorr lag' shuffcorrtrial]];
                    end
                    
                    [r p] = corrcoef(npks_burst,meanvol);
                    if p(2)<=0.05
                        [trcorr lag] = xcov(npks_burst,meanvol,'coeff');
                        [shuffcorrtrial lag] = shuffletrialcorr(npks_burst,meanvol,shufftrials);
                        corrtrial_mnvol = [corrtrial_mnvol; [trcorr lag' shuffcorrtrial]];
                    end
                    
                    [r p] = corrcoef(npks_burst,amplitude_pitchquant);
                    if p(2)<=0.05
                        [trcorr lag] = xcov(npks_burst,amplitude_pitchquant,'coeff');
                        [shuffcorrtrial lag] = shuffletrialcorr(npks_burst,amplitude_pitchquant,shufftrials);
                        corrtrial_amp = [corrtrial_amp; [trcorr lag' shuffcorrtrial]];
                    end
                    
                    continue
                end

                %correlate FR with mean vol, amp, pitch and shuffle test
                %for proportion significant
                [r_mnvol p_mnvol] = partialcorr(npks_burst,meanvol,sylldur,'rows','complete');
                [shuffr1 shuffp1] = shuffle_multipleregress(npks_burst,[meanvol sylldur],shufftrials);
                try
                    [r_amp p_amp] = partialcorr(npks_burst,amplitude_pitchquant,pitch,'rows','complete');
                    [shuffr2 shuffp2] = shuffle_multipleregress(npks_burst,[amplitude_pitchquant pitch],shufftrials);
                catch
                    r_amp = NaN; p_amp = NaN;shuffr2 = NaN(shufftrials,1);shuffp2 = NaN(shufftrials,1);
                end
                try
                    [r_pitch p_pitch] = partialcorr(npks_burst,pitch,amplitude_pitchquant,'rows','complete');
                    [shuffr3 shuffp3] = shuffle_multipleregress(npks_burst,[pitch amplitude_pitchquant],shufftrials);
                catch
                    r_pitch = NaN; p_pitch = NaN;shuffr3 = NaN(shufftrials,1);shuffp3 = NaN(shufftrials,1);
                end
%                 [r_amp p_amp] = corrcoef(npks_burst,amplitude_pitchquant,'rows','complete');
%                 [r_pitch p_pitch] = corrcoef(npks_burst,pitch,'rows','complete');
%                 r_amp = r_amp(2); p_amp = p_amp(2);
%                 r_pitch = r_pitch(2); p_pitch = p_pitch(2);
  
                %save measurements and variables
                burstid = burstid+1;
                corrtable = [corrtable; table({birdid},{unitid},seqids(n),burstid,alignby,...
                    pkFR,pkactivity,wth,mean(pct_error),length(npks_burst),varfr,...
                    latency,{r_mnvol p_mnvol},{r_amp p_amp},{r_pitch p_pitch},...
                    {shuffr1 shuffp1},{shuffr2 shuffp2},{shuffr3 shuffp3},'VariableNames',...
                    {'birdid','unitid','seqid','burstid','alignby',...
                    'pkFR','pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'latency','mnvol_corr','amp_corr','pitch_corr','shuffle_mnvol',...
                    'shuffle_amp','shuffle_pitch'})];

                 rawdatatable = [rawdatatable; table(meanvol,amplitude_pitchquant,pitch,sylldur,npks_burst,...
                    repmat(mean(pct_error),length(npks_burst),1),...
                    repmat(varfr,length(npks_burst),1),...
                    repmat(pkFR,length(npks_burst),1),...
                    repmat(pkactivity,length(npks_burst),1),...
                    repmat({birdid},length(npks_burst),1),...
                    repmat({unitid},length(npks_burst),1),...
                    repmat(seqids(n),length(npks_burst),1),...
                    repmat(burstid,length(npks_burst),1),...
                    'VariableNames',{'meanvol','amp','pitch','sylldur','spikes','pct_error','burstvar','pkFR','activity',...
                    'birdid','unitid','seqid','burstid'})];
                
                %plot significant cases
                if eval(plotcasecondition)
                    figure;subplot(3,3,[1:3]);hold on
                    plotraster(spktms,tb(burstst),tb(burstend),...
                        seqons,seqoffs,seqst,seqend,anchor,ff(i).name,...
                        (pct_error),seqids{n});
                    
                    subplot(3,3,[4:6]);hold on;
                    plotPSTH(seqst,seqend,smooth_spiketrains,...
                        tb(burstst),tb(burstend));

                    subplot(3,3,7);hold on;
                    plotCORR(npks_burst,pitch,ifr,'pitch',r_pitch,p_pitch);
                    
                    subplot(3,3,8);hold on;
                    plotCORR(npks_burst,meanvol,ifr,'mean vol',r_mnvol,p_mnvol);
                    
                    subplot(3,3,9);hold on;
                    plotCORR(npks_burst,amplitude_pitchquant,ifr,'amplitude',r_amp,p_amp);
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

            %correlate FR with mean vol, amp, pitch and shuffle test
            %for proportion significant
            [r_mnvol p_mnvol] = partialcorr(npks_burst,meanvol,sylldur,'rows','complete');
            [shuffr1 shuffp1] = shuffle_multipleregress(npks_burst,[meanvol sylldur],shufftrials);
            try
                [r_amp p_amp] = partialcorr(npks_burst,amplitude_pitchquant,pitch,'rows','complete');
                [shuffr2 shuffp2] = shuffle_multipleregress(npks_burst,[amplitude_pitchquant pitch],shufftrials);
            catch
                r_amp = NaN; p_amp = NaN;shuffr2 = NaN(shufftrials,1);shuffp2 = NaN(shufftrials,1);
            end
            try
                [r_pitch p_pitch] = partialcorr(npks_burst,pitch,amplitude_pitchquant,'rows','complete');
                [shuffr3 shuffp3] = shuffle_multipleregress(npks_burst,[pitch amplitude_pitchquant],shufftrials);
            catch
                r_pitch = NaN; p_pitch = NaN;shuffr3 = NaN(shufftrials,1);shuffp3 = NaN(shufftrials,1);
            end
                
%             [r_amp p_amp] = corrcoef(npks_burst,amplitude_pitchquant,'rows','complete');
%             [r_pitch p_pitch] = corrcoef(npks_burst,pitch,'rows','complete');
%             r_amp = r_amp(2); p_amp = p_amp(2);
%             r_pitch = r_pitch(2); p_pitch = p_pitch(2);

            %save measurements and variables
            latency=NaN;burstid=NaN;wth=NaN;
            corrtable = [corrtable; table({birdid},{unitid},seqids(n),burstid,alignby,...
                    pkFR,pkactivity,wth,mean(pct_error),length(npks_burst),varfr,...
                    latency,{r_mnvol p_mnvol},{r_amp p_amp},{r_pitch p_pitch},...
                    {shuffr1 shuffp1},{shuffr2 shuffp2},{shuffr3 shuffp3},'VariableNames',...
                    {'birdid','unitid','seqid','burstid','alignby',...
                    'pkFR','pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'latency','mnvol_corr','amp_corr','pitch_corr','shuffle_mnvol',...
                    'shuffle_amp','shuffle_pitch'})];

             rawdatatable = [rawdatatable; table(meanvol,amplitude_pitchquant,pitch,sylldur,npks_burst,...
                    repmat(mean(pct_error),length(npks_burst),1),...
                    repmat(varfr,length(npks_burst),1),...
                    repmat(pkFR,length(npks_burst),1),...
                    repmat(pkactivity,length(npks_burst),1),...
                    repmat({birdid},length(npks_burst),1),...
                    repmat({unitid},length(npks_burst),1),...
                    repmat(seqids(n),length(npks_burst),1),...
                    repmat(burstid,length(npks_burst),1),...
                    'VariableNames',{'meanvol','amp','pitch','sylldur','spikes','pct_error','burstvar','pkFR','activity',...
                    'birdid','unitid','seqid','burstid'})];
            
            %plot significant cases
            if eval(plotcasecondition)
                figure;subplot(3,3,[1:3]);hold on
                plotraster(spktms,tb(tbid(1)),tb(tbid(end)),...
                    seqons,seqoffs,seqst,seqend,anchor,ff(i).name,(pct_error),...
                    seqids{n});
  
                subplot(3,3,[4:6]);hold on;
                plotPSTH(seqst,seqend,smooth_spiketrains,...
                    tb(tbid(1)),tb(tbid(end)));
                
                subplot(3,3,7);hold on;
                plotCORR(npks_burst,pitch,ifr,'pitch',r_pitch,p_pitch);

                subplot(3,3,8);hold on;
                plotCORR(npks_burst,meanvol,ifr,'mean vol',r_mnvol,p_mnvol);

                subplot(3,3,9);hold on;
                plotCORR(npks_burst,amplitude_pitchquant,ifr,'amplitude',r_amp,p_amp);
            end  
        end
    end
end

function [PSTH_mn tb smooth_spiketrains spktms spkpost] = smoothtrain...
        (spiketimes,spikeposterior,seqst,seqend,anchor,win,ifr);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    if ~isempty(spikeposterior)
        spkpost = cell(size(anchor,1),1);%posterior probability of spike to be in classified cluster
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
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
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
 %trial by trial correlation based on smoothed spike trains when computed by spikes not ifr
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
%non-alpha characters. for seqlen == 1, remove 'x' and 'i' lbls
    N = length(stringvect);
    if seqlen > 1
        [id, ~, nn] = unique(stringvect(bsxfun(@plus,1:seqlen,(0:N-seqlen)')),'rows');
        cnts = sum(bsxfun(@(x,y)x==y,1:size(id,1),nn))';
        removeind = [];
        for ii = 1:size(id,1)
            if length(unique(id(ii,:)))==1 | sum(~isletter(id(ii,:))) > 0 %remove repeats and sequences with non-alpha
                removeind = [removeind;ii];
            end
        end
    elseif seqlen == 1
        [id,~,nn] = unique(stringvect');
        cnts = sum(bsxfun(@(x,y)x==y,1:size(id,1),nn))';
        removeind = find(~isletter(id) | lower(id) == 'x' | lower(id) == 'i');      
    end
    cnts(removeind) = [];id(removeind,:) = [];   
    ind = find(cnts >= mincnt);%only sequences that occur more than min cnt 
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
    
function npks = countspks(spktms,tm1,tm2);
    if length(tm1) == 1
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    else
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    end
    npks = 1000*(npks./(tm2-tm1));

function npks = burstifr(spktms,tm1,tm2,win);
    npks = cellfun(@(x) x(find(x>=tm1 & x<tm2)),spktms,'un',0);
    npks = cell2mat(cellfun(@(x) median(instantfr(x)),npks,'un',0)).*1000;
    npks(isnan(npks)) = 0;
    %npks = mean(cell2mat(cellfun(@(x) conv(instantfr(x,tm1:tm2),win,'same'),npks,'un',0)),2).*1000;
    
function [r p] = shuffle(npks_burst,dur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr],'rows','pairwise');
    r = r(1:end-1,end);
    p = p(1:end-1,end);  

function [r p] = shuffle_multipleregress(npks_burst,vars,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
%     betas = NaN(shufftrials,size(vars,2));pVals = NaN(shufftrials,size(vars,2));
    r = NaN(shufftrials,1);p = NaN(shufftrials,1);
    parfor n = 1:size(npks_burst_shuff,1);
%         mdl = fitlm(vars,npks_burst_shuff(n,:));
%         betas(n,:) = mdl.Coefficients.Estimate(2:end);
%         pVals(n,:) = mdl.Coefficients.pValue(2:end);
        [r(n) p(n)] = partialcorr(npks_burst_shuff(n,:)',vars(:,1),vars(:,2:end),'rows','complete');
    end

function [r l] = shuffletrialcorr(npks_burst,dur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r l] = xcov([npks_burst_shuff',dur_id_corr],'coeff');
    r =r(:,shufftrials+1:shufftrials+1:end-shufftrials+1);
    
function T = maketable(name,seqid,dur_id_corr,npks_burst,pct_error,pkactivity,corrpval);
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    birdid = repmat({unitid(1:regexp(unitid,'_')-1)},length(dur_id_corr),1);
    unitid = repmat({unitid},length(dur_id_corr),1);
    seqid = repmat(seqid,length(dur_id_corr),1);
    npks_burstn = (npks_burst-nanmean(npks_burst))./nanstd(npks_burst);
    unittype = repmat(mean(pct_error),length(dur_id_corr),1);
    activitylevel = repmat(pkactivity,length(dur_id_corr),1);
    corrpval = repmat(corrpval,length(dur_id_corr),1);
    T = table(dur_id_corr,npks_burstn,unittype,activitylevel,birdid,unitid,seqid,corrpval,'VariableNames',...
        {'dur','spikes','unittype','activity','birdid','unitid','seqid','corrpval'});
                 
function plotraster(spktms,tm1,tm2,seqons,seqoffs,seqst,seqend,anchor,name,...
        pct_error,seqid)
    if length(tm1) == 1
        spktms_inburst = cellfun(@(x) x(find(x>=tm1&x<tm2)),spktms,'un',0);
    else
        spktms_inburst = cellfun(@(x,y,z) x(find(x>=y&x<z)),spktms,tm1,tm2,'un',0);
    end
    cnt=0;
    for m = 1:length(spktms)
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
    title([unitid,' ',seqid,' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
        
function plotPSTH(seqst,seqend,smooth_spiketrains,tm1,tm2);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    plot(repmat([tm1 tm2],2,1),yl,'g','linewidth',2);hold on;
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');

function plotCORR(npks_burst,dur_id_corr,ifr,ylbl,rho,pval);
    scatter(npks_burst,dur_id_corr,'k.');hold on;
    xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    if ifr == 0
        xlabel('FR');
    else
        xlabel('IFR');
    end
    ylabel(ylbl);
    text(0,1,{['r=',num2str(rho)];['p=',num2str(pval)]},'units','normalized',...
        'verticalalignment','top');
    set(gca,'fontweight','bold');

function plotampenv(dur_id_corr,song,seqons,seqoffs,anchor,fs);
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
