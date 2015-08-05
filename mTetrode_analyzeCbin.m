function [tetstruct] = mTetrode_analyzeCbin(cbin,channels,sdthresh)
% function [] = mTetrode_analyzeCbin(cbin,channels,sdthresh)
%
% extracts spikes & generates tetstruct containing extracted data from
% multichannel cbin file.
%
% channels is vector of cbin channels with neural data, like [3 4 5 6]
% 
% SDthresh is std deviation threshold above rolling noise estimate for
% spike detection, usually 5-7 is a good range.
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds except width which is in millseconds. all are scalar except waveform, which is a
% vector
% 
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc

wavewin = 0.001; % +/- extraction window around detected spikes, in seconds

[tetdata fs] = ReadCbinFile(cbin);
tetstruct = mExtractSpikes_mult(tetdata,channels,fs,wavewin,sdthresh);

mTetrode_plotPeakScatters(tetstruct);

