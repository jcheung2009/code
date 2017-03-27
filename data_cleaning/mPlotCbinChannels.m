function [] = mPlotCbinChannels(cbin,channels,spect);
% [] = mPlotCbinChannels(cbin,channels,spect);
% plots all channels of Cbin File, assumes channel 1 is audio & plots
% spectrogram. Channels is [] of channel IDs to plot, if empty all channels
% are plotted
%
% plots spectrogram of channel 1 if spect == 1, otherwise plots raw audio
%

[data fs] = ReadCbinFile(cbin);

if(isempty(channels))
  channels = 1:1:size(data,2);
end

smoothdata = zeros(size(data));
smoothdata(:,1) = data(:,1);
for i=2:length(channels)
   smoothdata(:,channels(i)) = smooth(data(:,channels(i)),5);    
end

timebase = maketimebase(length(data(:,1)),fs);

fig = figure();
ax = zeros(1,length(channels));
plotnum=1;
for plotnum=1:length(channels)
    figure(fig);hold on;ax(plotnum)=subplot(length(channels),1,plotnum);
    if(plotnum==1 && spect==1)
        %plotspect(data(:,1),fs,1);
        mplotcbin(cbin,[]);
    else
        plot(timebase,data(:,channels(plotnum)));hold on;
        plot(timebase,smoothdata(:,channels(plotnum)),'r');hold off;
    end
end
linkaxes(ax,'x');
zoom xon;
hold off;