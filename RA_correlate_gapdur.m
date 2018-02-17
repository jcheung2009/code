function [corrtable rawdatatable corrtrial] = RA_correlate_gapdur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,targetactivity,targetdur,...
    plotcasecondition,mode,ifr,gap_or_syll)
%correlate premotor spikes with gapdur 
%seqlen = length of syllable sequence (use even # for gap and odd for syll)
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
% targetactivity = 0;%-1:previous, 0:current, 1:next
% targetdur = 0;%-1:previous, 0:current, 1:next
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y+su' (...single units)
%spk_gapdur_corr = [corrcoef pval alignment firingrate width mn(pct_error)...
%numtrials, corrcoefdur1 pval corrcoefdur2 pval durmotorwin]
%alignby=1 or 2 (off1 vs on1: gap; on1 vs prevoff: syll)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%ifr = 1 use mean instantaneous FR or 0 use spike count
%gap_or_syll = 'gap' or 'syll'

%% parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
shufftrials = 1000;%number of trials for shuffle
fs= 32000;%sampling rate
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y+')
    plotcasecondition = ['p(2)<=0.05 & pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y++')
    plotcasecondition = ['p(2)<=0.05 & abs(r(2)) >= 0.3 & pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y+su')
     plotcasecondition = ['p(2)<=0.05 & mean(pct_error)<=0.02 & pkactivity >=',num2str(activitythresh)];
end

%% 
corrtrial = {};
corrtable = table([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],...
    'VariableNames',{'birdid','unitid','seqid','burstid','alignby','pkactivity','width',...
    'pct_error','ntrials','trialbytrialcorr','bgactivity','latency','durcorr',...
    'adjdurcorr','volcorr'});
rawdatatable = table([],[],[],[],[],[],[],[],[],[],[],[],'VariableNames',{'dur','spikes',...
    'unittype','activity','birdid','unitid','seqid','burstid','vol1','vol2','dur1','dur2'});

ff = load_batchf(batchfile);
for i = 1:length(ff)
    disp(ff(i).name);
    [~,stid] = regexp(ff(i).name,'data_');enid = regexp(ff(i).name,'_TH');
    unitid = ff(i).name(stid+1:enid-1);
    birdid = unitid(1:regexp(unitid,'_')-1);
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
            dur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);
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
                dur_id_corr = gapseq(:,seqlen/2+targetdur);%gapdur for correlation with activity
            elseif strcmp(gap_or_syll,'syll')
                dur_id_corr = durseq(:,ceil(seqlen/2)+targetdur);
            end
        else
            dur_id_corr = dur_id;    
        end
        
        %anchors for aligning by target element
        pt = [motorwin 0];
        if strcmp(gap_or_syll,'gap')
            anchor = seqoffs(:,seqlen/2+targetactivity);
        elseif strcmp(gap_or_syll,'syll')
            anchor = seqons(:,ceil(seqlen/2)+targetactivity);
        end
        seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-anchor));%end border 
        
        %anchors for aligning by secondary element
        pt2 = offset;
        if strcmp(gap_or_syll,'gap')
            anchor2 = seqons(:,seqlen/2+targetactivity);
        elseif strcmp(gap_or_syll,'syll')
            anchor2 = seqoffs(:,ceil(seqlen/2)+targetactivity-1);
        end
        seqst2 = ceil(max(anchor2-seqons(:,1)));%boundaries for sequence activity relative to on1
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
        
        %compute PSTH from spike trains for specific alignment
        [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(...
            spiketimes,seqst,seqend,anchor,win,ifr);
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,ifr);
        
        if strcmp(mode,'burst')
            
            %find peaks/bursts in PSTH in premotor window aligned to target
            %element
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,'MinPeakWidth',10,...
                'Annotate','extents','WidthReference','halfheight');
            pkid = find(tb(locs)>=pt(1) & tb(locs)<=pt(2));
            wc = round(wc);

            if isempty(pkid)
                continue
            end

            %for each burst found, correlate with target dur
            burstid = 0;
            for ixx = 1:length(pkid)
                %define peak borders and other peak characteristics
                [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);
                wth = tb(burstend)-tb(burstst);
                gaplatency = tb(locs(pkid(ixx)))-pt(2);%((tb(burstst)+tb(burstend))/2)-pt(2);
                pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                outbursts = cell2mat(arrayfun(@(x,y) (x:x+y)',wc(:,1),wc(:,2)-wc(:,1),'un',0));
                outbursts = setdiff([1:length(PSTH_mn)],outbursts);
                outburstactivity = (mean(PSTH_mn(outbursts))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                 if ifr == 1
                    npks_burst = burstifr(spktms,tb(burstst),tb(burstend));
                 else
                    npks_burst = countspks(spktms,tb(burstst),tb(burstend));
                 end
               %npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;  
               
                %measure latency between burst center and next syllable/gap onset 
                if targetactivity == 0 & targetdur == 0
                    if strcmp(gap_or_syll,'gap')
                        durmotorwin = tb(locs(pkid(ixx)))-mean(gapseq(:,seqlen/2));
                    elseif strcmp(gap_or_syll,'syll')
                        durmotorwin = tb(locs(pkid(ixx)))-mean(durseq(:,ceil(seqlen/2)));
                    end
                else
                    durmotorwin = NaN;
                end
                
                %n-trial lag correlation 
                if nargout >=3
                    [r p] = corrcoef(npks_burst,dur_id_corr);
                    if mean(pct_error)<=0.02 & pkactivity >= activitythresh & p(2)<=0.05
                        [trcorr lag] = xcov(npks_burst,dur_id_corr,'coeff');
                        [shuffcorrtrial lag] = shuffletrialcorr(npks_burst,dur_id_corr,1000);
                        corrtrial = [corrtrial; [trcorr lag' shuffcorrtrial]];
                    end
                    continue
                end
                
                %extract volume for syllables adjacent to target dur and
                %correlate with target burst
                if exist('song') & length_song == length(song)
                    vol1 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                        seqons(:,ceil(seqlen/2)),seqoffs(:,ceil(seqlen/2)),'un',1);
                    vol2 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                        seqons(:,ceil(seqlen/2)+1),seqoffs(:,ceil(seqlen/2)+1),'un',1);
                    [rvol1 pvol1] = corrcoef(npks_burst,vol1);rvol1 = rvol1(2); pvol1 = pvol1(2);
                    [rvol2 pvol2] = corrcoef(npks_burst,vol2);rvol2 = rvol2(2); pvol2 = pvol2(2);
                    [shuffr4 shuffp4] = shuffle(npks_burst,vol1,shufftrials);
                    [shuffr5 shuffp5] = shuffle(npks_burst,vol2,shufftrials);
                else
                    vol1=NaN(length(npks_burst),1);vol2=NaN(length(npks_burst),1);
                    rvol1=NaN;pvol1=NaN;rvol2=NaN;pvol2=NaN;
                    shuffr4=NaN;shuffp4=NaN;shuffr5=NaN;shuffp5=NaN;
                end
                
                %correlation with target and adjacent elements (border
                %syllables  or gaps) 
                [r p] = corrcoef(npks_burst,dur_id_corr);
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
                [r1 p1] = corrcoef(npks_burst,dur1_id);
                [r2 p2] = corrcoef(npks_burst,dur2_id);

                %shuffle analysis
                [shuffr shuffp] = shuffle(npks_burst,dur_id_corr,shufftrials);
                [shuffr2 shuffp2] = shuffle(npks_burst,dur1_id,shufftrials);
                [shuffr3 shuffp3] = shuffle(npks_burst,dur2_id,shufftrials);

                %save measurements and variables
                burstid = burstid+1;
                corrtable = [corrtable; table({birdid},{unitid},gapids(n),burstid,alignby,...
                    pkactivity,wth,mean(pct_error),length(dur_id_corr),varfr,...
                    outburstactivity,[gaplatency durmotorwin],{r(2) p(2) shuffr shuffp},...
                    {r1 p1 r2 p2 shuffr2 shuffp2 shuffr3 shuffp3},...
                    {rvol1 pvol1 rvol2 pvol2 shuffr4 shuffp4 shuffr5 shuffp5},...
                    'VariableNames',{'birdid','unitid','seqid','burstid','alignby',...
                    'pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                    'bgactivity','latency','durcorr','adjdurcorr','volcorr'})];
                
                %normalized variables and save raw data in table
                 fr = npks_burst;%(npks_burst-mean(npks_burst))./std(npks_burst);
                 dur = dur_id_corr;%(dur_id_corr-mean(dur_id_corr))./std(dur_id_corr);
                 %vol1 = (vol1-mean(vol1))./std(vol1);
                 %vol2 = (vol2-mean(vol2))./std(vol2);
                 dur1 = dur1_id;%(dur1_id-mean(dur1_id))./std(dur1_id);
                 dur2 = dur2_id;%(dur2_id-mean(dur2_id))./std(dur2_id);
                 rawdatatable = [rawdatatable; table(dur,fr,...
                    repmat(mean(pct_error)<=0.02,length(npks_burst),1),...
                    repmat(pkactivity,length(npks_burst),1),...
                    repmat({birdid},length(npks_burst),1),...
                    repmat({unitid},length(npks_burst),1),...
                    repmat(gapids(n),length(npks_burst),1),...
                    repmat(burstid,length(npks_burst),1),...
                    vol1,vol2,dur1,dur2,...
                    'VariableNames',{'dur','spikes','unittype','activity',...
                    'birdid','unitid','seqid','burstid','vol1','vol2','dur1','dur2'})];

                if eval(plotcasecondition)
                    figure;subplot(3,1,1);hold on
                    plotraster(dur_id_corr,spktms,tb(burstst),tb(burstend),...
                        seqons,seqoffs,seqst,seqend,anchor,ff(i).name,...
                        (pct_error),gapids{n},r(2));
                    
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
            pkactivity = (max(PSTH_mn(tbid))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
            if ifr == 1
                npks_burst = burstifr(spktms,tb(tbid(1)),tb(tbid(end)));
            else
                npks_burst = countspks(spktms,tb(tbid(1)),tb(tbid(end)));
            end

            %extract volume for syllables adjacent to target dur and
            %correlate with target burst
            if exist('song') & length_song == length(song)
                vol1 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                    seqons(:,ceil(seqlen/2)),seqoffs(:,ceil(seqlen/2)),'un',1);
                vol2 = arrayfun(@(x,y) mean(log(song(floor(x*1e-3*fs):ceil(y*1e-3*fs)))),...
                    seqons(:,ceil(seqlen/2)+1),seqoffs(:,ceil(seqlen/2)+1),'un',1);
                [rvol1 pvol1] = corrcoef(npks_burst,vol1);rvol1 = rvol1(2); pvol1 = pvol1(2);
                [rvol2 pvol2] = corrcoef(npks_burst,vol2);rvol2 = rvol2(2); pvol2 = pvol2(2);
                [shuffr4 shuffp4] = shuffle(npks_burst,vol1,shufftrials);
                [shuffr5 shuffp5] = shuffle(npks_burst,vol2,shufftrials);
            else
                vol1=NaN(length(npks_burst),1);vol2=NaN(length(npks_burst),1);
                rvol1=NaN;pvol1=NaN;rvol2=NaN;pvol2=NaN;
                shuffr4=NaN;shuffp4=NaN;shuffr5=NaN;shuffp5=NaN;
            end

            %correlation with target and adjacent elements (border
            %syllables  or gaps) 
            [r p] = corrcoef(npks_burst,dur_id_corr);
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
            [r1 p1] = corrcoef(npks_burst,dur1_id);
            [r2 p2] = corrcoef(npks_burst,dur2_id);

            %shuffle analysis
            [shuffr shuffp] = shuffle(npks_burst,dur_id_corr,shufftrials);
            [shuffr2 shuffp2] = shuffle(npks_burst,dur1_id,shufftrials);
            [shuffr3 shuffp3] = shuffle(npks_burst,dur2_id,shufftrials);
            
            %save measurements and variables
            outburstactivity=NaN;gaplatency=NaN;durmotorwin=NaN;burstid=NaN;wth=NaN;
            corrtable = [corrtable; table({birdid},{unitid},gapids(n),burstid,alignby,...
                pkactivity,wth,mean(pct_error),length(dur_id_corr),varfr,...
                outburstactivity,[gaplatency durmotorwin],{r(2) p(2) shuffr shuffp},...
                {r1 p1 r2 p2 shuffr2 shuffp2 shuffr3 shuffp3},...
                {rvol1 pvol1 rvol2 pvol2 shuffr4 shuffp4 shuffr5 shuffp5},...
                'VariableNames',{'birdid','unitid','seqid','burstid','alignby',...
                'pkactivity','width','pct_error','ntrials','trialbytrialcorr',...
                'bgactivity','latency','durcorr','adjdurcorr','volcorr'})];
              
            %normalized variables and save raw data in table
            fr = npks_burst;%(npks_burst-mean(npks_burst))./std(npks_burst);
             dur = dur_id_corr;%(dur_id_corr-mean(dur_id_corr))./std(dur_id_corr);
             %vol1 = (vol1-mean(vol1))./std(vol1);
             %vol2 = (vol2-mean(vol2))./std(vol2);
             dur1 = dur1_id;%(dur1_id-mean(dur1_id))./std(dur1_id);
             dur2 = dur2_id;%(dur2_id-mean(dur2_id))./std(dur2_id);
             rawdatatable = [rawdatatable; table(dur,fr,...
                repmat(mean(pct_error)<=0.02,length(npks_burst),1),...
                repmat(pkactivity,length(npks_burst),1),...
                repmat({birdid},length(npks_burst),1),...
                repmat({unitid},length(npks_burst),1),...
                repmat(gapids(n),length(npks_burst),1),...
                repmat(burstid,length(npks_burst),1),...
                vol1,vol2,dur1,dur2,...
                'VariableNames',{'dur','spikes','unittype','activity',...
                'birdid','unitid','seqid','burstid','vol1','vol2','dur1','dur2'})];
                
            if eval(plotcasecondition)
                figure;subplot(3,1,1);hold on
                plotraster(dur_id_corr,spktms,tb(tbid(1)),tb(tbid(end)),...
                    seqons,seqoffs,seqst,seqend,anchor,ff(i).name,(pct_error),...
                    gapids{n},r(2));
  
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

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
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
    [~,tb,smooth_spiketrains] = smoothtrain(spiketimes,seqst,seqend,anchor,win,0);
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
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);  

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
    singleunit = mean(pct_error)<=0.02;
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
        xlabel('FR');
    else
        xlabel('IFR');
    end
    ylabel('gap duration (ms)');
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
