function [] = mTetrode_plotavgspikes(tetstruct,channel,fs,spikenums,RGB)
% function [] = mTetrode_plotavgspikes(tetstruct,channel,fs,spikenums,RGB)
%
% plots avg +/- 1SD spikes on the channel, given by vector of spikenums. RGB is
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

numspikes = size(spikenums);

timebase = maketimebase(length(tetstruct(channel).waveform(1,:)),fs);

hold on;

avgspike = mean(tetstruct(channel).waveform(spikenums,:));
plot(timebase,smooth(avgspike,3),'Color',RGB,'LineWidth',3);
SDplus = avgspike + std(tetstruct(channel).waveform(spikenums,:));
SDneg = avgspike - std(tetstruct(channel).waveform(spikenums,:));
plot(timebase,smooth(SDplus,3),'Color',RGB,'LineWidth',.5);
plot(timebase,smooth(SDneg,3),'Color',RGB,'LineWidth',.5);
hold off;