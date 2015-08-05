function [prob_hist cum_hist rawAxis] = cumhist(raw_in)
%
% returns cumulative histogram calculated from raw_in
% mnm, 4 may 2009
%

[rawHist rawAxis] = hist(raw_in);

prob_hist = (rawHist / sum(rawHist));

cum_elements = histc(raw_in,rawAxis);
cum_hist = cumsum(cum_elements);

cum_hist = (cum_hist / max(cum_hist));

