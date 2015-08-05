function rhd_data = jc_IntanMapSpiketimes2(rhd_data,spiketimeidxs,channel);

%takes indices of spike times from jc_detectspikes (for real time analysis
%in surgery
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
    spikeind = find(spiketimeidxs >= fileind(1) & spiketimeidxs<= fileind(2));
    if i == 1
        rhd_data(i).spiketimes.(['channel',num2str(channel)]) = spiketimeidxs(spikeind);
    else
        rhd_data(i).spiketimes.(['channel',num2str(channel)]) = [spiketimeidxs(spikeind)-filesizes(i-1)];
    end
end