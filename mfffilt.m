function [filtout] = mfffilt(ffvect,confvect)
%
% [filtout] = mfffilt(ffvect,confvect)
% replaces values of ffvect with confidence < noise with NaN
%
%

[histout histbins] = hist(confvect,200);
ffvectfilt = ffvect .* (confvect > histbins(2));
filtout = mzeros2nan(ffvectfilt);
return;
