function [ccvar,ccmean,ncc] = calc_ccstats(data,ccut)
% Compute the center clipped amplitude statistics

idx_ccut = find(abs(data) > ccut);
ccvar = mean(data(idx_ccut).^2);
ccmean = mean(data(idx_ccut));
ncc = length(data(idx_ccut));

