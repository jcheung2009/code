function var_med = mVar_median(invect)
%
%
% function var_med = mVar_median(invect)
%
% returns variance about the median of invect
%

squaresvect = (invect - median(invect)).^2;

var_med = sum(squaresvect) / length(invect);

