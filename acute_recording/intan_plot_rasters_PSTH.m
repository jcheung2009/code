%% 2/18/15 - LT modified to accept >1 file. i.e. 60seconds cutoff by Intan for one file, can enter all files and will concatenate auto


%% 11/9/14 - previously used lt_pj_PSTH_Intan_temp, or the pj version.  Here, make improvements such that:
% 1) No need to specificy stim windows, program gets automatically.
% 2) Median, not std, thresholding, which better approximates background noise.
% 3) Collects spike waveforms.
% 4) everything is in units of samples (until plotting).

%% INPUT PARAMS

clear all;
AmplChansOfInterest_0to31=0:31; % array of nums 0 to 31.
DigChan=0; % (usually 1 is individual stims, 2 is stim epochs), triggers
ThrXNoise=4; % how many multiples of median noise to use as spike threshold.
PSTH_bin=[0.01]; % bin in sec, if dont specificy ([]) then will use 1/10 of peri-stim dur.
PeriStimTime = [.5];%specify peristim duration in secs if hand jitter, leave empty if use mode of stimonsset/offset intervals
fn = uigetfile('*.rhd','Multiselect','on');

%% RUN --------------------
if ~iscell(fn)
    fn = {fn};
end
% how many filenames?
NumFiles=length(fn);

if NumFiles>1 % then need to concatenate files  
    for i=1:NumFiles
        clear amplifier_data
        clear board_dig_in_data
        clear aux_input_data
        clear supply_voltage_data
        
        disp(['Opening ' fn{i}]);
        pj_readIntanNoGui(fn{i}); % function writes to workspace
        
        % these 4 variables below are data. other variables should be the
        % same for the same recording (but diff filename).
        amplifier_data_Mult{i}=amplifier_data;
        board_dig_in_data_Mult{i}=board_dig_in_data;
        try
            aux_input_data_Mult{i}=aux_input_data;
            supply_voltage_data_Mult{i}=supply_voltage_data;
        catch err
            aux_input_data_Mult{i}=[];
            supply_voltage_data_Mult{i}=[];
        end
        disp(['Size of data: ' num2str(size(amplifier_data,2))]);
    end
    % concatenate to create large vectors
    clear amplifier_data
    clear board_dig_in_data
    clear aux_input_data
    clear supply_voltage_data
    
    amplifier_data= cell2mat(amplifier_data_Mult); % rows are still channels, columns extend across time of all files
    board_dig_in_data= cell2mat(board_dig_in_data_Mult);
    aux_input_data= cell2mat(aux_input_data_Mult);
    supply_voltage_data= cell2mat(supply_voltage_data_Mult);
else % if only one file
    pj_readIntanNoGui(fn{1});
end

disp('Loading done!');
disp(['Number of files: ' num2str(NumFiles) '. Total duration: ' num2str(size(amplifier_data,2)/frequency_parameters.amplifier_sample_rate) ' sec.']);
    
% AUTOMATIC PARAMETERS
% convert chans (0 to 31) to array indices
ChansOfInterest_1to32=AmplChansOfInterest_0to31+1;
fs=frequency_parameters.amplifier_sample_rate;

F_low=300;
F_high=5000;
N=4;
[b,a]=butter(N,[F_low*2/fs, F_high*2/fs]);

% number of amplifier channels
NumAmplChans=size(amplifier_data,1);
% ---------------------

for i=1:NumAmplChans
    amplifier_data_filt(i,:)=filtfilt(b,a,amplifier_data(i,:));
end

% GET SPIKE TIMES (all channels)
for i=1:length(ChansOfInterest_1to32);
    chan=ChansOfInterest_1to32(i);
    MedianNoise(chan)=median(abs(amplifier_data_filt(chan,:))./0.6745); % median noise (not std), from http://www.scholarpedia.org/article/Spike_sorting
    SpikeThreshold(chan)=ThrXNoise*MedianNoise(chan);
    
    [SpikePks{chan}, SpikeTimes{chan}]=findpeaks(-amplifier_data_filt(chan,:),'minpeakheight',...
        SpikeThreshold(chan),'minpeakdistance',floor(0.0003*fs)); % 0.3ms min separation btw peaks.
end


% GET STIM TIMES
% first, find dig data that corresponds to channel you want.
for i=1:length(board_dig_in_channels)
    if board_dig_in_channels(i).chip_channel==DigChan;
        DigInd=i;
    end
end

if length(DigChan)>1
    error('Problem, >1 dig channel, have not coded to deal with more than one chan');
else
    
    StimChangeTimes=midcross(board_dig_in_data(DigInd,:)); % time stim switch 1 or 0
    
    TotSwitchTimes=length(StimChangeTimes); % Get on and off times;
    StimOnTimes=StimChangeTimes(1:2:TotSwitchTimes); % odd vals are stim onset
    StimOffTimes=StimChangeTimes(2:2:TotSwitchTimes);
    NumStims=length(StimOnTimes);
    
    % make sure there are same number of stim ons/off (otherwise stim probably
    % clipped);
    if length(StimOnTimes)~=length(StimOffTimes)
        disp('PROBLEM: Num of StimOn times ~= Num StimOff times.  Stim epoch clipped?');
        disp('Will remove one stim');
        
        if length(StimOnTimes)>length(StimOffTimes)
            StimOnTimes=StimOnTimes(1:end-1);
        NumStims=NumStims-1;
        
        elseif length(StimOffTimes)>length(StimOnTimes)
            StimOffTimes=StimOffTimes(1:end-1);
        end
    end
end

disp(['Number of stims: ' num2str(NumStims) ]);

% ====== BIN SPIKES RELATIVE TO STIM WINDOWS

% 1) find optimal peristimulus time window
if isempty(PeriStimTime)
    [PeriStimTime, F] =mode(StimOnTimes(2:end)-StimOffTimes(1:end-1)); % to get peri time, find the most common time between off and on of next stim. works because each file only uses one stim train parameter
    if F<NumStims/2 % then cannot use mode, since F is occurances of the mode.  if low jitter, expect this to be at least 1/2 number of trials.
        MinISI=min(StimOnTimes(2:end)-StimOffTimes(1:end-1)); % minimum interstim dur recorded
        % round down by 100ms to get prestim time
        MinISI_sec=MinISI/fs;
        PeriStimTime_sec= (floor(MinISI_sec*10))/10; % i.e. convert to 100ms units, round down, then convert back to sec.
        PeriStimTime=PeriStimTime_sec*fs;
        disp(['NOTE: no strong mode found in ISI (by auto peri-stim-time-maker), so peristim time chosen to be ' num2str(PeriStimTime_sec) 's (i.e. minimum ISI rounded down to nearest 0.1s)']);
    end
else
    PeriStimTime=PeriStimTime*fs;
end

StimDur=mode(StimOffTimes-StimOnTimes);

if isempty(PSTH_bin)
    PSTH_bin=max(0.005,(PeriStimTime/10)/fs); % bin in sec
end

% Collect Spike Times for each Stim epoch
for i=1:length(ChansOfInterest_1to32)
    chan=ChansOfInterest_1to32(i);
    for ii=1:NumStims; % for each stim epoch
        StimEpoch(ii,:)=[StimOnTimes(ii)-PeriStimTime StimOffTimes(ii)+PeriStimTime]; % samples of epoch
        spktimes=SpikeTimes{chan}(SpikeTimes{chan}>StimEpoch(ii,1) ...
            & SpikeTimes{chan}<StimEpoch(ii,2)); % sample time of spikes in this stim epoch
        SpikeTimesInStim_RelToStimEpoch{chan}{ii} = spktimes-StimEpoch(ii,1); % spike time in stim epoch, relative to stim on.
    end
end


% Bin and take mean to get PSTH
BinEdges=0:PSTH_bin*fs:(StimDur+2*PeriStimTime); % edges spanning each stim epoch
% Collect spikes and put into time bins, defined relative to stim epochs.
for i=1:length(ChansOfInterest_1to32)
    chan=ChansOfInterest_1to32(i);
    for ii=1:NumStims;
        if isempty(SpikeTimesInStim_RelToStimEpoch{chan}{ii}); % i.e. no spikes at all;
            BinnedSpikesStimEpoch{chan}(ii,:)=zeros(length(BinEdges),1)'; % fill with "0" bins
        else
            BinnedSpikesStimEpoch{chan}(ii,:)=histc(SpikeTimesInStim_RelToStimEpoch{chan}{ii},BinEdges);
        end
    end
    
    % Get summary stats (across stim epochs)
    if isempty(BinnedSpikesStimEpoch{chan})
        MeanSpikes_PSTH{chan}=0;
        StdSpikes{chan}=0;
        SEMspikes{chan}=0;
    else
        MeanSpikes_PSTH{chan}=mean(BinnedSpikesStimEpoch{chan},1);
        StdSpikes{chan}=std(BinnedSpikesStimEpoch{chan},0,1);
        SEMspikes{chan}=StdSpikes{chan}./sqrt(NumStims-1);
    end
    
    
    % convert to firing rate
    BinnedSpikeRate{chan}=MeanSpikes_PSTH{chan}./PSTH_bin; % rate is #spikes/binsize.
    BinnedRateSEM{chan}=SEMspikes{chan}./PSTH_bin;
end


%% PLOT PSTH FOR ALL CHANNELS IN ONE PLOT (PSTH), ORDERED BY ELECTRODE POSITION:

figure; hold on;
ElectrodePosToPlot_0to31=[7 1 6 14 10 11 5 12 4 3 9 8 13 2 15 0 23 28 25 20 22 27 17 21 26 30 19 24 29 18 31 16]; % Enter channels in spatial order - to plot channels in order (top to bottom of right shank, then top to bottom of left shank) : i.e. if electrode positions (from top to bottom, left to right) is like: [1 2; 3 4; ... ; 31 32] then rewrite that as: [2 4 8 ... 32 17 19 ... 31];

for i=1:32 % indices, with correcponsdence to electrode defined by the subplot positions they call
    subtightplot(2,16,i,[0.07 0.025],0.05,0.03); hold on;
    
    ChanNum_0to31=ElectrodePosToPlot_0to31(i); % what Channel?
    chan=ChanNum_0to31+1;  % convert from 0to31 to 1to32 scale
    
    % Plot for a channel
    bar(BinEdges./fs,BinnedSpikeRate{chan},'histc');
    xlabel('Time (s)');
    ylabel('Mean spikes/s')
    
    % plot stim on and off.
    line([PeriStimTime./fs PeriStimTime./fs],ylim);  % put lines denoting stim on and off
    line([PeriStimTime./fs+StimDur./fs PeriStimTime./fs+StimDur./fs],ylim);
    
    xlim([0 StimDur./fs+(6/5)*PeriStimTime./fs]); % to reduce size of plot, as post and pre are identical.
    
    y0=max(0, min(BinnedSpikeRate{chan}(1:end-1))-10); % lower y limit
    yf=max(BinnedSpikeRate{chan})+10;
    ylim([y0 yf]);
    
    title(['Channel: ' num2str(ChanNum_0to31) ]);
end

ChansOfInterest_0to31 = input('channels of interest (0-31):');
ChansOfInterest_1to32 = ChansOfInterest_0to31+1;
%% PLOT Raster + PSTH
for i=1:length(ChansOfInterest_1to32)
    chan=ChansOfInterest_1to32(i);
    figure; hold on;
    h1 = subplot(2,1,1); hold on;
    for ii=1:NumStims
        if ~isempty(SpikeTimesInStim_RelToStimEpoch{chan}{ii}) % if no spikes, then will not plot
            plot(h1,SpikeTimesInStim_RelToStimEpoch{chan}{ii}./fs,ii,'k.');
        else
            plot(h1,1,ii,'Color',[1 1 1]); % if no spikes, plot a white thing as placeholder (important if this is last line).
        end
    end
    
    xlim(h1,[0 StimDur./fs+2*PeriStimTime./fs]); % makes sure xlims represent entire trial.
    ylim(h1,[1 NumStims]);
    line(h1,[PeriStimTime./fs PeriStimTime./fs],[0 NumStims]);  % put lines denoting stim on and off
    line(h1,[PeriStimTime./fs+StimDur./fs PeriStimTime./fs+StimDur./fs],ylim);
    title(['Raster plot: Channel (0-31): ' num2str(chan-1)]);
    ylabel(h1,'Stim trial #');
    xlabel(h1,'Time (s)');
    
    % Plot PSTH
    h2 = subplot(2,1,2);hold on;
    X=BinEdges+(1/2)*PSTH_bin*fs; % midpoint of bin edges.
    X=X./fs; % convert to sec
    bar(h2,BinEdges./fs,BinnedSpikeRate{chan},'histc'); % actual plot
    hold on;

    ylabel(h2,'Mean Firing Rate (hz)');
    xlabel(h2,'Time (s)');
    xlim(h2,[0 StimDur./fs+2*PeriStimTime./fs])
    
    % zoom in y axis.
    y0=max(0, min(BinnedSpikeRate{chan}(1:end-1))-10); % lower y limit
    yf=max(BinnedSpikeRate{chan})+10;
    ylim(h2,[y0 yf]);
    
    % plot stim on and off.
    line(h2,[PeriStimTime./fs PeriStimTime./fs],ylim);  % put lines denoting stim on and off
    line(h2,[PeriStimTime./fs+StimDur./fs PeriStimTime./fs+StimDur./fs],ylim);
    
end



%% PLOT RAW DATA, SPIKES, and STIM

for i=1:length(ChansOfInterest_1to32);
    chan=ChansOfInterest_1to32(i);
    
    figure; hold on;
    X_s=1/fs:1/fs:(length(amplifier_data_filt(chan,:)))/fs; % conv from sample to Sec
    X_ms=1000*X_s; 
    plot(X_s,-amplifier_data_filt(chan,:),'k'); % plot filtered waveform
    scatter(SpikeTimes{chan}./fs,SpikePks{chan},'r'); % plot spikes
    line(xlim, [SpikeThreshold(chan) SpikeThreshold(chan)],'LineStyle','--') % plot threshold used for spike detection
    
    ylimits=ylim;
    for ii=1:NumStims;
        line([StimOnTimes(ii)./fs StimOffTimes(ii)./fs],[0 0],'LineWidth',5);
    end
    
    title(['Raw voltage trace, stim epochs, and spikes, for channel (0-31): ' num2str(chan-1) ]);
    ylabel('Voltage (uV)');
    xlabel('Time (s)');
    
end

%% plot spike forms




