function [pks,spikeTimes,spikeThresh,timeVec] = pj_getSpikeTimes2(dat,fs,xNoise,flip,plotDetection,varargin)
%% Take as input a neural recording, return a list of spike times. Uses a simple amplitude threshold criterion to detect spikes.

% Required inputs:
%           dat: data vector (vector)
%           fs: sampling frequency (integer; samples/second)
%           xNoise: Factor multiplied by the "noise", used as an amplitude
%           threshold for spike detection (integer)
%           flip: 1 to detect negative peaks, 0 to detect positive peaks (0
%           or 1)
%           plotDetection: 1 to plot raw data and detected spikes, 0
%           otherwise (0 or 1)

% Optional inputs:
%           varargin{1}: Auxiliary data vector, such as a TTL pulse.
%           Plotted along with data and detected spikes if plotDetection ==
%           1 (vector). 

% Outputs:
%           pks: peak amplitudes of all detected spike events (vector)
%           spikeTimes

% Notes:
%           Uses findpeaks to detect local maxima. Flip argument may be
%           used to detect negative-going action potentials. 

%%
noise = rms(dat(1:fs/2)); % Noise is defined as root mean square of first 500ms of data.
spikeThresh = noise*xNoise; % spikeThresh is the threshold amplitude usd to detect putative events

if flip == 0
    [pks,spikeSamples] = findpeaks(dat,'minpeakheight',spikeThresh,'minpeakdistance',25);
    spikeTimes = spikeSamples/fs; % detected spikes times, in seconds 
else % Flips data to detect negative voltage excursions
    [pks,spikeSamples] = findpeaks(-dat,'minpeakheight',spikeThresh,'minpeakdistance',25);
    spikeTimes = spikeSamples/fs; % detected spikes times, in seconds 
    pks = -pks;
end

linVec = linspace(1,length(dat),length(dat));
timeVec = linVec/fs; %Vector of times (sample numbers converted to times, equal to length of dat)

% Plot detected spikes with raw wave form and option auxiliary input 
if plotDetection == 1
    figure, hold on
    plot(timeVec,dat,'b')
    scatter(spikeTimes,pks,'r*')
    xlabel('Time (s)')
    if length(varargin) > 0
        aux = varargin{1};
        aux = (aux/max(aux))*mean(pks);
        plot(timeVec,aux,'g')
    end
end


    
    


end

