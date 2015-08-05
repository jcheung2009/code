function [filttimes spikeamps] = mDetectSpikes(data,fs,thresh,plotit);
% function [times spikeamps] = mDetectSpikes(data,fs,tresh,plotit);
% 
% detects extracellular spikes in data vector based on amplitude above noise
% 
% returns spike times (in seconds) and amplitide of spikes, plot times vs
% spikeamps on top of raw data to check accuracy
%
% if plotit != 0, plots trace, detection threshold envelopes, & detected
% spike times on current axis
%

%thresh = 6; % Std Dev threshold, spikes called if there are this factor above noise

smoothed50 = smooth(data,50);
smoothedSD = movingstd(smoothed50,1000);
thresh_pos = thresh .* smoothedSD;
thresh_neg = -thresh .* smoothedSD;

smoothed5 = smooth(data,5);

threshedData = data.*(smoothed5 > thresh_pos | smoothed5 < thresh_neg); % thresholded to excursions above/below SD thresh
threshedData = mzeros2nan(threshedData);

[pks pklocs] = findpeaks(threshedData,'minpeakdistance',.001*fs);
pks = smoothed5(pklocs);
pktimes = pklocs .* (1/fs);

[negpks negpklocs] = findpeaks(-threshedData,'minpeakdistance',.001*fs);
negpks = smoothed5(negpklocs);
negpktimes = negpklocs .* (1/fs);

allpeakstimes = vertcat(pktimes,negpktimes);
allpeaks = vertcat(pks,negpks);

sortMtx = horzcat(allpeakstimes,allpeaks);
sortedMtx = sortrows(sortMtx,1); % positive & negative peaks in correct temporal order with corresponding peak amplitides

difftimes = diff(sortedMtx(:,1));
difftimes = vertcat(nan,difftimes);
filttimes = sortedMtx(:,1) .* (difftimes <.00075 & difftimes > 5/fs); % detect spikes that are <.75ms apart, but not adjacent
filttimes = mzeros2nan(filttimes);

spikeamps = sortedMtx(:,2);

killpnts = find(isnan(filttimes));
filttimes(killpnts) = [];
spikeamps(killpnts) = [];

%
if(plotit)
    timebase = maketimebase(length(data),fs);
    plot(timebase,smoothed5,'k');hold on;plot(timebase,thresh_pos,'b');plot(timebase,thresh_neg,'b');
    plot(filttimes,spikeamps,'ro','MarkerFaceColor','r');
    % plot(pktimes,pks,'ro','MarkerFaceColor','r');
    % plot(negpktimes,negpks,'bo','MarkerFaceColor','b');   
end








