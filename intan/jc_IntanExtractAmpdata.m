function jc_IntanExtractAmpdata(rhd_data_songs)
%extract amplifier data from each channel into mat files to be used in
%wave_clus


numchannels = arrayfun(@(x) x.filedata.num_amplifier_channels,rhd_data_songs);
if isempty(find(diff(numchannels)))
    numchannels = numchannels(1);
else
    error('number of channels changes')
end

concat_channels = [];
for i = 1:numchannels
    single_concatchan = [];
    for ii = 1:length(rhd_data_songs)
        single_concatchan = [single_concatchan rhd_data_songs(ii).amp_data(i,:)];
    end
    concat_channels = [concat_channels; single_concatchan];
end
    
for i = 1:numchannels
    data = concat_channels(i,:);
    save(['channel',num2str(i),'_data.mat'],'data');
end
