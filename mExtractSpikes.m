function [outstruct] = mExtractSpikes(data,fs,window)
%
% function [outstruct] = mExtractSpikes(data,fs,window)
%
% data is vector. fs = sampling rate. window is time around spike center to
% extract (one sided, in seconds)
%
% 0.001 seconds is a good window.
%
% outstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds
%

[spiketimes spiketimeamps] = mDetectSpikes(data,fs,0);

structlength = length(spiketimes);

winpnts = window*fs;

outstruct = struct('times',zeros(structlength,1),'waveform',zeros(structlength,1+(2*(window*fs))),'peak',zeros(structlength,1),'trough',zeros(structlength,1),'width',zeros(structlength,1));
outstruct.times = spiketimes;

for spikenum=1:1:length(spiketimes)
    thespiketime = (spiketimes(spikenum))*fs;
    winstart = thespiketime-winpnts;
    winstop = thespiketime+winpnts;
    
    thewaveform = data(winstart:winstop);
    thewaveform = smooth(thewaveform,5);
    [themax maxloc] = max(thewaveform);
    [themin minloc] = min(thewaveform);    
    outstruct.peak(spikenum) = themax;
    outstruct.trough(spikenum) = themin;
    outstruct.width(spikenum) = (maxloc - minloc)/fs;
    
    midpnt = min([maxloc minloc]) + (round((max([maxloc minloc]) - min([maxloc minloc]))/2)); % extract window +/- midpoint between peak and trough
    alignedstart = (winstart + midpnt)-winpnts;
    alignedstop = (winstart + midpnt)+winpnts;
    
    outstruct.waveform(spikenum,:) = data(alignedstart:alignedstop);  
end

