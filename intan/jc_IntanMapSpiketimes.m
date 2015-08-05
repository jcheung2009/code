function rhd_data = jc_IntanMapSpiketimes(rhd_data,cluster_class,channel);

%takes cluster_class from wave_clus after spike sorting from concatenated
%amplifier channel
%maps spike times in cluster_class back to each rhd_data file 
%adds spiketimes field in rhd_data structure: each point is time in sample
%points in amp_data

fs = arrayfun(@(x) x.Fs,rhd_data);
numchannel = arrayfun(@(x) size(x.amp_data,1),rhd_data);
if isempty(find(diff(fs)))
    fs = fs(1);
else
    error('sampling rate changes')
end
if isempty(find(diff(numchannel)))
    numchannel = numchannel(1);
else
    error('number of channels changes')
end

cluster_class(:,2) = floor(cluster_class(:,2)*1e-3*fs); %changes spike times to data points 
filesizes = arrayfun(@(x) size(x.amp_data,2),rhd_data);
filesizes = cumsum(filesizes);%data end points 

nms = fieldnames(rhd_data);
if isempty(find(strcmp(nms,'spiketimes')))
    [rhd_data(:).(['spiketimes'])] = deal([]);
end

for i = 1:length(rhd_data)
    if i == 1
        fileind = [1 filesizes(i)];
    else
        fileind = [filesizes(i-1)+1 filesizes(i)];
    end
    clusterind = find(cluster_class(:,2) >= fileind(1) & cluster_class(:,2) <= fileind(2));
    if i == 1
        rhd_data(i).spiketimes.(['channel',num2str(channel)]) = cluster_class(clusterind,:);
    else
        rhd_data(i).spiketimes.(['channel',num2str(channel)]) = [cluster_class(clusterind,1) cluster_class(clusterind,2)-filesizes(i-1)];
    end
end

       
    