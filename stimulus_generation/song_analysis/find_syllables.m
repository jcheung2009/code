function [idxs, t] = find_syllables(x, fs)


% extract syllables from frong


% generate envelope
envelope = abs(hilbert(x));
envelope = filtfilt(ones(1,windowsize*fs), 1, envelope);

% find thereshold crossings
