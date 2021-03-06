function [PSTHs, spiketrains, PSTHs_rand, spiketrains_rand burstprob] = firing_phase(...
    batchfile,seqlen,minsampsize,ifr,winsize,gap_or_syll);
%this function extracts information for looking at firing activity relative
%to the onset of all target gaps or syllables 
%PSTH: averaged across all trials for unit and target gap or syllable 
%spiketrains: smoothed spike trains for every trial of unit and target gap
%or syll
%PSTHs_rand: average across all trials after shuffling spike trains
%spiketrains_rand: shuffled spike trains
%burstprob: table where each row is single unit and the counts of whether
%it bursted before a target gap or syll in bird's song (ie: vector of 1's
%and 0's) 

%seqlen: length of the sequence for target gap or syll (6 or 5)
%minsampsize: minimum sample size 
%ifr: 0 or 1 for IFR or FR
%winsize: 10 ms, size of convolution window
%gap_or_syll: 'gap','syll'

%% parameters
win = gausswin(winsize);%for smoothing spike trains, 10-20 ms
win = win./sum(win);
shufftrials = 1000;%number of trials for shuffle
fs= 32000;%sampling rate
timewin = 100;
motorwin = -40;

%iterate through each unit summary "combined data" file 
ff = load_batchf(batchfile);
spiketrains = [];
PSTHs = [];
spiketrains_rand = [];
PSTHs_rand = [];
burstprob = table([],[],[],'VariableNames',{'birdid','unitid','counts'});
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
    burstcnts = [];
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
        
        if strcmp(gap_or_syll,'gap')
            anchor = seqoffs(:,seqlen/2);
        elseif strcmp(gap_or_syll,'syll')
            anchor = seqons(:,ceil(seqlen/2));
        end

        
        %compute PSTH from spike trains for specific alignment
        [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(...
            spiketimes,timewin,anchor,win,ifr);
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            timewin,anchor,win,ifr);
        
        %detect burst
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',20,'MinPeakWidth',10,...
                'MinPeakDistance',15,'MinPeakHeight',mean(PSTH_mn_rand)+20,...
                'Annotate','extents','WidthReference','halfheight');
        pkid = find(tb(locs)>=motorwin & tb(locs)<=0);
        if ~isempty(pkid)
            burstcnts = [burstcnts 1];
        else
            burstcnts = [burstcnts 0];
        end
 
        spiketrains = [spiketrains; smooth_spiketrains];
        PSTHs = [PSTHs; PSTH_mn];
        spiketrains_rand = [spiketrains_rand; smooth_spiketrains_rand];
        PSTHs_rand = [PSTHs_rand; PSTH_mn_rand];
    end
    burstprob = [burstprob; table({birdid},{unitid},{burstcnts},'VariableNames',...
        {'birdid','unitid','counts'})];
end
        
function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain...
        (spiketimes,timewin,anchor,win,ifr);
    %tb, PSTH_mn = timebase, average firing pattern across all trials, 
    %smooth_spiketrains = spike trains for each trial after convolution, 
    %spktms = time of each spike relative to anchor point in each trial
    spktms = cell(size(anchor,1),1);
    smooth_spiketrains = zeros(size(anchor,1),2*timewin+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,2*timewin+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-timewin) & spiketimes<=(anchor(m)+timewin)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+timewin+1;
        if ifr == 1
            temp = instantfr(spktms{m},-timewin:timewin);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-timewin:timewin];
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/second
    
function [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            timewin,anchor,win,ifr);
        %same as smoothtrain but spike trains are shuffled
    spktms = cell(size(anchor,1),1);
    smooth_spiketrains = zeros(size(anchor,1),2*timewin+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,2*timewin+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-timewin) & spiketimes<=(anchor(m)+timewin)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+timewin+1;
        if ifr == 1
            temp = instantfr(spktms{m},-timewin:timewin);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = temp;
    end
    tb = [-timewin:timewin];
    smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
    smooth_spiketrains_rand = conv2(1,win,smooth_spiketrains_rand,'same');
    PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;