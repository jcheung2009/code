function [all_output] = sliding_gaussian_isolation(events,clustering,which_cluster,min_count,target_segments)

if ~exist('min_count','var')
    min_count = 50;
end
if ~exist('target_segments','var')
    target_segments = 50;
end

total_interested_events = sum(clustering == which_cluster);
if total_interested_events < min_count
    error('too few events for sliding_gaussian_isolation');
end

%determine segments
if total_interested_events < min_count*target_segments
    start_index = ones( ceil(total_interested_events/min_count),1); 
    for i = 2:length(start_index)-1 %make the last one extra long
        start_index(i) = min_count * (i-1);
    end
    start_index(end) = total_interested_events + 1;
else
    start_index = ones(target_segments + 1,1); %don't run last index
    for i = 2:length(start_index)-1
        start_index(i) = (i-1)*floor(total_interested_events / target_segments );
    end
    start_index(end) = total_interested_events + 1;
end
%for each segment get P()'s
outputs = [];
true_indicies = 1:length(clustering);
true_indicies = true_indicies(clustering == which_cluster);

for i = 1:length(start_index)-1 %don't run last index it's a stop value
    %pull out segment
    ind_min = true_indicies(start_index(i));
    ind_max = true_indicies(start_index(i+1)-1);
    local_events = events(ind_min:ind_max,:);
    local_clustering = clustering(ind_min:ind_max);
    
    %ensure that there are enough events in each cluster
    unique_clusters = unique(local_clustering);
    cluster_counts = zeros(size(unique_clusters));
    for j = 1:length(unique_clusters)
        cluster_counts(j) = sum(local_clustering == unique_clusters(j));
    end
    [values, sort_inds] = sort(cluster_counts,'descend');
    target_cluster = unique_clusters(sort_inds(1)); %find the larget cluster to merge smallest clusters into
    if target_cluster == which_cluster
        target_cluster = unique_clusters(sort_inds(2));
    end
    for j = 1:length(values)
        if values(j) < min(min_count,size(events,2)*2); %minimum size for clustering should just be size(2), but be safe
            small_cluster = unique_clusters(sort_inds(j));
            %relabel as part of largest cluster not of interest
            local_clustering(local_clustering == small_cluster) = target_cluster; 
        end
    end
    if(sum(local_clustering == which_cluster) ~= start_index(i+1)-start_index(i))
        error('Clusters were not combined correctly');
    end
    outputs = [outputs, gaussian_isolation(local_events,local_clustering,which_cluster)];
end

all_output.p_raw_event = vertcat(outputs.p_raw_event);
all_output.p_event = vertcat(outputs.p_event);
all_output.p_false_p = vertcat(outputs.p_false_p);
all_output.p_false_n =  vertcat(outputs.p_false_n);
all_output.p_entropy = vertcat(outputs.p_entropy);
% because some clusters may not be present in all segments, drop these
% all_output.p_raw_clusters =vertcat(outputs. p_raw_clusters);
% all_output.p_all_clusters = vertcat(outputs.p_all_clusters);
% all_output.unique_clusters = vertcat(outputs.unique_clusters);
% all_output.p_clusters = vertcat(outputs.p_clusters);
% all_output.sum_probabilities = vertcat(outputs.sum_probabilities);