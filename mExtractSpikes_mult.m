function [outstruct] = mExtractSpikes_mult(data,channels,fs,window, sdthresh)
%
% function [outstruct] = mExtractSpikes(data,channels,fs,window,sdthresh)
%
% data is vector. channels is vector of channels in data. fs = sampling rate. window is time around spike center to
% extract (one sided, in seconds)
%
% 0.001 seconds is a good window.
%
% example [outstruct] = mExtractSpikes_mult(data,[2 3 4 5],32000,0.001);
% 
% function expects data to be x by y matrix, where x is data points and y is number of
% channels.
%
% outstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds, except width which is in milliseconds. all are scalar except waveform, which is a
% vector
%
%
%
% creates one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc
%

maxspikes = 20000; % hardcoded maximum spikes per channel, adjust for high firing rates or very long files.

allspiketimes = zeros(maxspikes,length(channels)); 
figure();hold on;ax = zeros(1,length(channels));
for channelnum=1:1:length(channels) % detect all spikes on all channels to properly initialize data struct
    thechannel = channels(channelnum);
    ax(channelnum)=subplot(length(channels),1,channelnum);
    [spiketimes spiketimeamps] = mDetectSpikes(data(:,thechannel),fs,sdthresh,1);
    allspiketimes(1:length(spiketimes),channelnum) = spiketimes;
end
linkaxes(ax,'x');
zoom xon;
hold off;

zeroidx = find(allspiketimes==0);
linearspiketimes = allspiketimes;
linearspiketimes(zeroidx') = []; % remove buffer zeros and linearize spike times matrix

linearspiketimes = sort(linearspiketimes);
difftimes = horzcat(nan,diff(linearspiketimes));
%uniquespiketimes = unique(linearspiketimes);
uniquespiketimes = linearspiketimes.*(difftimes > .001); % eliminate redundant sipke times (time difference across channels < 1ms, hardcoded)
killpnts = find(uniquespiketimes==0);
uniquespiketimes(killpnts) = [];

structlength = length(uniquespiketimes);

winpnts = window*fs;

% initialize output data struct 
outstruct(1:length(channels)) = struct('times',zeros(structlength,1),'waveform',zeros(structlength,1+(2*(window*fs))),'peak',zeros(structlength,1),'trough',zeros(structlength,1),'width',zeros(structlength,1));

for spikenum=1:1:structlength % each unique spike time
    thespiketime = round((uniquespiketimes(spikenum))*fs);
    winstart = thespiketime-winpnts;
    winstop = thespiketime+winpnts;
    for channelnum = 1:1:length(channels) % each channel, measure & extract spike, populate data struct      
        thechannel = channels(channelnum);
        rawwaveform = data(winstart:winstop,thechannel);
        thewaveform = smooth(rawwaveform,5);
        [themax maxloc] = max(thewaveform);
        [themin minloc] = min(thewaveform);
        outstruct(channelnum).peak(spikenum) = themax;
        outstruct(channelnum).trough(spikenum) = themin;
        outstruct(channelnum).width(spikenum) = ((maxloc - minloc)/fs)*1e3;
        outstruct(channelnum).times(spikenum) = uniquespiketimes(spikenum);
      
        midpnt = maxloc; % extract window +/- midpoint between peak and trough of spike
        alignedstart = (winstart + midpnt)-winpnts;
        alignedstop = (winstart + midpnt)+winpnts;
        
        outstruct(channelnum).waveform(spikenum,:) = data(alignedstart:alignedstop,thechannel);
    end
end
