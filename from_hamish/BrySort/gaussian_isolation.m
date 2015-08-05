function [output] = gaussian_isolation(events,clustering,which_cluster)
% [output] = gaussian_isolation(events,clustering,which_cluster)
%
% Computes the probability of each event as well as the probabilities of
% false positives and false negatives assuming each cluster is a
% multivariate gaussian.
%
% Inputs - 
%       events - an NxM matrix, with N events and M features
%       clustering - an Nx1 vector, with the cluster of each event
%       which_cluster - the cluster of interest for output parameters
%                   Specifying -Inf returns outputs that do not require a
%                   specific cluster to be selected.
% Outputs -
%       output - a struct with the following fields
%           p_raw_event - probility of (event | cluster of interest)
%           p_event - probability of (event |
%                       cluster of interst and knowlege of other clusters)
%           p_false_p - probability events are assigned to cluster of
%                       interest but really belong to another cluster
%           p_false_n - probability events are assigned to other clusters
%                       but really belong to the cluster of interest
%           p_entropy - the mean entropy of the p_event considering P(all
%                       clusters) but only for cluster of interest
%           p_raw_clusters - MxC - probability of each (event | each cluster)
%           p_all_clusters - MxC proabiliity of each (event | 
%                       each cluster and knowledge of other clusters)
%           unique_clusters - Cx1 - the ordering of clusters along axis C
%           p_clusters - Cx1 - the probability of each cluster C
%           sum_probabilities - Nx1 - overall probability of each event
%
% Bryan Seybold - 2013,06,25

% NOTE: this function makes heavy use of the multivariate normal pdf
% function, mvnpdf. If the number of events in a cluster is smaller than
% the number of feature dimensions, it will throw an error.

unique_clusters = unique(clustering);
which_index = find(which_cluster == unique_clusters);

if which_cluster ~= -inf && isempty(which_index)
    error('which_cluster must be a cluster id in clustering');
end

p_raw_clusters = zeros(size(events,1),length(unique_clusters));

p_clusters = zeros(size(unique_clusters));
sum_probabilities = zeros(size(clustering));
for i = 1:length(unique_clusters)
    this_class = events(clustering == unique_clusters(i),:);
    %compute the probability of each event for each cluster
    p_raw_clusters(:,i) = mvnpdf(events, mean(this_class,1), cov(this_class));
    %compute the probability of each cluster
    p_clusters(i) = (sum(unique_clusters(i) == clustering)/length(clustering));
    %compute the total probability of this event
    sum_probabilities = sum_probabilities + ...
        p_raw_clusters(:,i) * p_clusters(i);
end

p_all_clusters = zeros(size(p_raw_clusters));
for i = 1:length(unique_clusters)
    %invert with bayes rule
    %probability for each cluster given this waveform
    p_all_clusters(:,i) = p_raw_clusters(:,i) .* p_clusters(i) ./sum_probabilities;
end

if which_cluster ~= -inf
    %probability of each event given the selected cluster
    p_raw_event = p_raw_clusters(clustering == which_cluster,which_index);
    %probability of each event given the total model
    p_event = p_all_clusters(clustering == which_cluster,which_index);
    
    %calculate false positives
    %probabilities from other clusters for spikes assigned to this one
    p_false_p = sum(sum(p_all_clusters(clustering == which_cluster, unique_clusters ~= which_cluster)))/sum(clustering == which_cluster);
    
    %calcluate false negatives
    %probabilities from this cluster for spikes assigned to other ones
    p_false_n = sum(sum(p_all_clusters(clustering ~= which_cluster, which_index)))/sum(clustering ~= which_cluster);
    
    p_entropy = -p_all_clusters(clustering == which_cluster,:).*log2(p_all_clusters(clustering == which_cluster,:));
    p_entropy(isnan(p_entropy)) = 0; % if P() evalutes as 0, log is undefined
    p_entropy = mean(sum(p_entropy,2)); %collapse down to mean entropy
else
    p_raw_event = nan;
    p_event = nan;
    p_false_p = nan;
    p_false_n = nan;
    p_entropy = nan;
end

% if p_false_n < 0 || p_false_n > 1
%     disp('here')
% end

output.p_raw_event = p_raw_event;
output.p_event = p_event;
output.p_false_p = p_false_p;
output.p_false_n =  p_false_n;
output.p_raw_clusters = p_raw_clusters;
output.p_all_clusters = p_all_clusters;
output.unique_clusters = unique_clusters;
output.p_clusters = p_clusters;
output.sum_probabilities = sum_probabilities;
output.p_entropy = p_entropy;