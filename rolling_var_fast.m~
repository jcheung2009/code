function [varout] = rolling_var_fast(invect,winsize)
%
% function [varout] = rolling_var_fast(invect,winsize)
% 
% returns rolling variance of invect computed at winsize windows
% Vectorized version is faster than for-loop

outlength = length(invect);

coeffs = ones(1,outlength);
rolling_mean1 = filter(coeffs,1,invect.^2);
rolling_mean2 = filter(coeffs,1,invect).^2;

rolling_mean1 = rolling_mean1(outlength:end);
rolling_mean2 = rolling_mean2(outlength:end);

varout = (outlength / outlength-1)*(rolling_mean1 - rolling_mean2);