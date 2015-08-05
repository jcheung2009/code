function [prob_data,bincenters,binedges,prob_data_btstrp] = computeadaptdist(data,Nbins,Nbtstrp)

% This version will output histograms rather than normalized
% probability distributions

if nargin < 1 
  error('Not enough input arguments to computeadaptdist.')
end
Nsamp = length(data);
if nargin == 1
  Nbins = round(Nsamp^(1/3))
elseif nargin == 2
  Nbtstrp = 100
end

data = sort(data);

% if Nbins is a vector, then it contains the input bin edges
if size(Nbins,1) == 1 & size(Nbins,2) == 1
  cutindex = round([1:Nbins]*Nsamp/Nbins);
  cutindex = [1 cutindex];
  binedges = data(cutindex);
  bincenters = zeros(Nbins,1);
  for n=1:Nbins-1
    bincenters(n) = mean(data(cutindex(n):cutindex(n+1)-1));
  end
  bincenters(Nbins) = mean(data(cutindex(Nbins):cutindex(Nbins+1)));
else
  binedges = Nbins;
  Nbins = length(binedges) - 1;
  bincenters = zeros(Nbins,1);
  for n=1:Nbins-1
    databin_idx = find(data >= binedges(n) & data < binedges(n+1));
    bincenters(n) = mean(data(databin_idx));
  end
  databin_idx = find(data >= binedges(Nbins) & data <= binedges(Nbins+1));
  bincenters(Nbins) = mean(data(databin_idx));
end

% Compute probability distribution
prob_data = zeros(Nbins,1);
[hist_data, bin_idx] = histc(data,binedges);
prob_data = hist_data(1:Nbins);
% Add data to last bin corresponding to the last bin edge
prob_data(Nbins) = prob_data(Nbins) + hist_data(Nbins+1);
%prob_data = prob_data/sum(prob_data);

% Compute Nbtstrp examples of the probability distribution
if Nbtstrp > 0
  prob_data_btstrp = zeros(Nbins,Nbtstrp);
  for K=1:Nbtstrp
    samples = ceil(rand(Nsamp,1)*Nsamp);
    data_samp = data(samples);

    [hist_data, bin_idx] = histc(data_samp,binedges);
    prob_data_btstrp(:,K) = hist_data(1:Nbins);
    % Add data to last bin corresponding to the last bin edge
    prob_data_btstrp(Nbins,K) = prob_data_btstrp(Nbins,K) + hist_data(Nbins+1);

    %prob_data_btstrp(:,K) = prob_data_btstrp(:,K)/sum(prob_data_btstrp(:,K));
  end
else
  prob_data_btstrp = -1;
end
