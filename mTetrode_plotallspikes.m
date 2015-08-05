function [] = mTetrode_plotallspikes(tetstruct,channel,fs)
% function [] = mTetrode_plotallspikes(tetstruct,channel,fs)
%
% plots all detected spikes on the channel
%
% does same for troughs & widths
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

numspikes = size(tetstruct(channel).waveform);
numspikes = numspikes(1);

timebase = maketimebase(length(tetstruct(channel).waveform(1,:)),fs);

figure();hold on;
for i=1:1:numspikes
    plot(timebase,smooth(tetstruct(channel).waveform(i,:),4))    
end
plot(timebase,mean(tetstruct(channel).waveform),'k','LineWidth',2)
hold off;