function [rhd_data BOSdata PSTH] = jc_plotBOSdata(batch,type)
%use for real time analysis in surgery presentation of BOS
%batch listing rhd files containing BOS or revBOS or CON
%type = 'BOS','CON','REV'
%plots multitrial rasters aligned to onset of audio playback 
%plots PSTH
%option to plot IFR 

%% Parameters
pretime = 2;%in seconds before onset of BOS audio
postime = 3;%in seconds, 2 seconds before audio, + 0.5 seconds after song ends, estimate song duration by segmenting from song files
stdmin = 3;%for segmenting audio 
binsize = 0.02;%in seconds for PSTH
binedges=-pretime:binsize:postime;
% ifrbinsize = 0.001;%in seconds for IFR
% ifrbins=-pretime:ifrbinsize:postime;

%% Import and extract amp data from all channels
rhd_data = jc_IntanRHDImportAll(batch);
jc_IntanExtractAmpdata(rhd_data);
numchannels = arrayfun(@(x) x.filedata.num_amplifier_channels,rhd_data);
for i = 1:numchannels
    movefile(['channel',num2str(i),'_data.mat'],['channel',num2str(i),'_',type,'data.mat']);
end

%% Detect spikes
for i = 1:numchannels
    filename = uigetfile;%load the mat file containing the concatenated channel data
    load(filename);
    [index] = jc_detectspikes(data);
    channel = input('channel number?:');
    rhd_data = jc_IntanMapSpiketimes2(rhd_data,index,channel);
end

%% Extract auditory and neural data aligned to onset of audio
BOSdata = struct;
avsp = [];
avsm = [];
for i = 1:length(rhd_data)
    fs = rhd_data(i).Fs;
    BOSdata(i).filename = rhd_data(i).filename;
    song = rhd_data(i).song;
    
    %segment the audio to find song onset
    sm = evsmooth(song,fs);
    noise_std_detect = median(sm)/0.6745;%from wave_clus 
    thr = stdmin*noise_std_detect;
    [ons offs] = SegmentNotes(sm,fs,5,20,thr);
    onset = floor(ons(1)*fs);%in sample points
    onsamp = onset-floor(pretime*fs);
    offsamp = onset+ceil(postime*fs);
    if offsamp > length(song)
        disp(['post song time is too long in file: ',rhd_data(i).filename,' index ',num2str(i)])
        continue
    end
    %save amplitude envelop and spec
    [sm, spec, t, f] = evsmooth(song(onsamp:offsamp),fs);
    if i == 1
        avsp = log(abs(spec));
        avsm = sm;
    else
        avsp = avsp + log(abs(spec));
        avsm = avsm + sm;
    end
    
    BOSdata(i).sm = sm;
    BOSdata(i).spec = log(abs(spec));
    BOSdata(i).ampdata = rhd_data(i).amp_data(:,onsamp:offsamp);
    
    nms = fieldnames(rhd_data(i).spiketimes);%channels in spiketimes field
    for p = 1:length(nms)
        spiketimes = rhd_data(i).spiketimes.([nms{p}])-onset;%changes spike times to be relative to song onset
        spiketimes = spiketimes(spiketimes >= -1*floor(pretime*fs) & spiketimes <= ceil(postime*fs));
        BOSdata(i).spiketimes.([nms{p}]) = spiketimes./fs;
    end
end
avsp = avsp./length(rhd_data);
avsm = avsm./length(rhd_data);

%% plot rasters of all trials with average aligned BOS
timevector = [0:1/fs:(length(avsm)-1)/fs];
timevector = timevector-pretime;%make it relative to song onset
spectimevector = [(256/fs):(512-floor(0.8*512))/fs:(size(avsp,2)-1)*(512-floor(0.8*512))/fs];%values are midpoint of each section, evsmooth
spectimevector = spectimevector-pretime;%relative to song onset

 spktms = [];
 for i = 1:length(BOSdata)
     channelnms = fieldnames(BOSdata(i).spiketimes);
     for ii = 1:length(channelnms)
         spktms.([channelnms{ii}]).(['trial',num2str(i)])=BOSdata(i).spiketimes.([channelnms{ii}]);
     end
 end
 
 channelnames = fieldnames(spktms);
 numchannels = length(channelnames);
 channelcolors = rand(numchannels,3);
 numplots = 2 + numchannels;
 
figure;hold on;
subtightplot(numplots,1,1,0.05,0.03,0.1);imagesc(spectimevector,f,avsp);syn();h = get(gca,'xlim');
title('average spectrogram of BOS')
 %subtightplot(2,1,2,0.04,0.03,0.1);plot(timevector,avsm,'k','linewidth',2);set(gca,'xlim',h);
 %title('average amplitude envelop of motif')
 
 % create another structure with spike times in each trial as a subfield in
 % each channel, needed for plotting 

 count = 1;
 y_label = {};
 binnedspktms = [];
 %instfr = [];
 for i = 1:length(channelnames)
     trialnms = fieldnames(spktms.([channelnames{i}]));
     binnedspktms.([channelnames{i}]) = zeros(length(trialnms),length(binedges));
     %instfr.([channelnames{i}])=zeros(length(trialnms),length(ifrbins));
     for k = 1:length(trialnms)
         if isempty(spktms.([channelnames{i}]).([trialnms{k}]))
             rowvector = [count*ones(1,length(spktms.([channelnames{i}]).([trialnms{k}])));...
                (count-1)*ones(1,length(spktms.([channelnames{i}]).([trialnms{k}])))];
             subtightplot(numplots,1,2,0.05,0.03,0.1);hold on;
             plot(repmat(spktms.([channelnames{i}]).([trialnms{k}]),2,1),rowvector,'k-','color',...
                channelcolors(i,:),'LineWidth',2);hold on;
             binnedspktms.([channelnames{i}])(k,:) = zeros(1,length(binedges));
             %instfr.([channelnames{i}])(k,:)=zeros(1,length(ifrbins));
             count = count+1;
             continue
         else
             rowvector = [count*ones(1,length(spktms.([channelnames{i}]).([trialnms{k}])));...
                (count-1)*ones(1,length(spktms.([channelnames{i}]).([trialnms{k}])))];
             subtightplot(numplots,1,2,0.05,0.03,0.1);hold on;
             plot(repmat(spktms.([channelnames{i}]).([trialnms{k}]),2,1),rowvector,'k-','color',...
                channelcolors(i,:),'LineWidth',2);hold on;
             binnedspktms.([channelnames{i}])(k,:) =histc(spktms.([channelnames{i}]).([trialnms{k}]),binedges);
             %instfr.([channelnames{i}])(k,:)= instantfr(spktms.([channelnames{i}]).([trialnms{k}]),ifrbins);
             count = count+1;
         end
     end
     y_label{i} = [channelnames{i}];
 end
 title('rasters aligned to playback')
 set(gca,'xlim',h,'color','none','ytick',...
     [length(BOSdata):length(BOSdata):length(BOSdata)*(numchannels)],...
     'ylim',[0 length(BOSdata)*(numchannels)],'yticklabel',y_label);

%% PSTH
for i = 1:numchannels
    PSTH.([channelnames{i}]).spikerate = mean(binnedspktms.([channelnames{i}]),1)./binsize;
    PSTH.([channelnames{i}]).rateSEM = (std(binnedspktms.([channelnames{i}]),0,1)./sqrt(length(trialnms)-1))/binsize;
    PSTH.([channelnames{i}]).bins = binedges;
end

%plot PSTH for each channel
for i = 1:numchannels
    subtightplot(numplots,1,2+i,0.05,0.03,0.1);
    stairs(binedges,PSTH.([channelnames{i}]).spikerate,'k','LineWidth',2);
    title(['PSTH for ',channelnames{i}]);set(gca,'xlim',h);
    ylabel('Firing Rate (Hz)');
end

        
% %% IFR
% %average the IFR over all trials
% for i = 1:numchannels
%     IFR.([channelnames{i}]).meanIFR = mean(instfr.([channelnames{i}]),1);
%     IFR.([channelnames{i}]).sem = stderr(instfr.([channelnames{i}]),1);
% end
% 
% %plot IFR for each channel
% for i = 1:numchannels
%     subtightplot(4,1,4,0.04,0.03,0.1);
%     plot(ifrbins,IFR.([channelnames{i}]).meanIFR,'k');
% end