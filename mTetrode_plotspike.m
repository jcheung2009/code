function [] = mTetrode_spikes(tetstruct,spikenum,fs)
%
% function [] = mTetrode_spikes(tetstruct,spikenum,fs)
%
% plots spikes on all 4 channels, good for quickly looking
% at extracted waveforms. 
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



structsize = size(tetstruct);
timebase = maketimebase(size(tetstruct(1).waveform,2),fs);
wavmtx = zeros(4,size(tetstruct(1).waveform,2));

figure();hold on;
for i=1:1:structsize(2) % each channel
    wavmtx(i,:) = smooth(tetstruct(i).waveform(spikenum,:),4);
end
h=plot(timebase,wavmtx);
hold off;

c=get(h,'Color');
% disp('Channel 1 ',c{1});
% disp('Channel 2 ',c{2});
% disp('Channel 3 ',c{3});
% disp('Channel 4 ',c{4});
