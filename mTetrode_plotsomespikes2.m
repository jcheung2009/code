function [miny maxy] = mTetrode_plotsomespikes2(tetstruct,channel,fs,spikenums,RGB)
% function [miny maxy] = mTetrode_plotallspikes(tetstruct,channel,fs,spikenums,RGB)
%
% plots some spikes on the channel, given by vector of spikenums. RGB is
% Color vector like [1 0 0] for red
%
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds. all are scalar except waveform, which is a
% vector
% 
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc
%
% returns min and max amplitude values for all the spikes in spikenums
%

numspikes = size(spikenums);

timebase = maketimebase(length(tetstruct(channel).waveform(1,:)),fs);

miny = 1.2 * min(tetstruct(channel).trough);
maxy = 1.2 * max(tetstruct(channel).peak);

hold on;
for i=1:1:numspikes
    plot(timebase,smooth(tetstruct(channel).waveform(spikenums(i),:),4),'Color',RGB,'LineWidth',0.5);    
end
avgspike = mean(tetstruct(channel).waveform(spikenums,:));
%plot(timebase,mean(tetstruct(channel).waveform(spikenums,:)),'k','LineWidth',2)
plot(timebase,smooth(avgspike,3),'Color',RGB,'LineWidth',2);
hold off;