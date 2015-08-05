function [] = mTetrode_plotsomespikes(tetstruct,channel,fs,spikenums)
% function [] = mTetrode_plotallspikes(tetstruct,channel,fs,spikenums)
%
% plots some spikes on the channel, given by vector of spikenums
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

numspikes = size(spikenums);

timebase = maketimebase(length(tetstruct(channel).waveform(1,:)),fs);

figure();hold on;
for i=1:1:numspikes
    plot(timebase,smooth(tetstruct(channel).waveform(spikenums(i),:),4))    
end
avgspike = mean(tetstruct(channel).waveform(spikenums,:));
%plot(timebase,mean(tetstruct(channel).waveform(spikenums,:)),'k','LineWidth',2)
plot(timebase,smooth(avgspike,3),'k','LineWidth',2);
hold off;