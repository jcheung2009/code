function [firstpeakdistance lag c locs pks] = find_acorr_peak(sm,fs,varargin);
%performs autocorrelation on smooth amp waveform to get interval-interval
%duration in seconds

if ~isempty(varargin)
    timeband = varargin{1};
else
    timeband = '';
end

[c lag] = xcorr(sm,'coeff');
c = c(ceil(length(lag)/2):end);
lag = lag(ceil(length(lag)/2):end);
[pks locs] = findpeaks(c,'minpeakwidth',256);
if isempty(locs)
    firstpeakdistance = NaN;
else
    if ~isempty(timeband)
         pkind = find(locs > timeband(1)*fs & locs < timeband(2)*fs);
        if length(pkind) == 1
            firstpeakdistance = locs(pkind)/fs;
        else
            firstpeakdistance = NaN;
        end
    else
        firstpeakdistance = locs(1)/fs;%average time in seconds between adjacent syllables from autocorr
    end
end