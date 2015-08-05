function jc_checkspiketimemap(rhd_data,channel)
%for each rhd file, plots the amp data from specified channel, and marks
%locations of spikes according to the spiketimes field for the
%corresponding channel

fmin_detect = 300;
fmax_detect = 10000;

i = randi(length(rhd_data),1);

amp_data = rhd_data(i).amp_data(channel,:);
sr = rhd_data(i).Fs;

%high pass filter amp data from wave_clus
[b,a]=ellip(2,0.1,40,[fmin_detect fmax_detect]*2/sr);
amp_data=filtfilt(b,a,amp_data);

figure;hold on;
numclusters = length(unique(rhd_data(i).spiketimes.(['channel',num2str(channel)])(:,1)))-1;
for ii = 1:numclusters
    clusterind = find(rhd_data(i).spiketimes.(['channel',num2str(channel)])(:,1)==ii);
    spiketimes = rhd_data(i).spiketimes.(['channel',num2str(channel)])(clusterind,2);
    for p = 1:length(spiketimes)
        subtightplot(1,numclusters,ii);hold on;
        plot(amp_data,'k');hold on;
        plot(spiketimes,amp_data(spiketimes),'r.');hold on;
        title(['cluster ',num2str(ii),'for channel ',num2str(channel)]);
    end
end


    
    
  