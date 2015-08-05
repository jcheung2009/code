%script to sort the files from the TDT system for the Hasenstaub lab

path_to_spikesort_output_folder = '\\holding\users\bryan\spike_data\sorted_data\';

for i = [10,12,13,14,15,16,17,18,19,24,25,22,26,27,28]
    params.TankFolder = '\\holding\users\bryan\';
    params.DescriptorFolder = '\\holding\users\bryan\sound gui\v10\Descriptors\';

    params.Tank = '2013-01-25'; %required
    params.ExptNum = i;  %required
    params.probe_style = '4x4(200x200)'; %required
    params.channels = 1:16;
    params.unit_store = 'Wave'; %required

    results = get_analyzer_results_or_save(params);
%     results = analyzer_to_save(params);

    for j = 1:length(results)
        [results(j).OAContext.unsorted_events.event_idx,...
         results(j).OAContext.unsorted_events.event_features]...
            = quick_klustakwik_snippets(results(j).snippets);
    end
    
    sorted_results = results;
    output_file = sprintf('%s%s Expt %d %s sorted.mat',path_to_spikesort_output_folder,results(1).OAContext.Tank,results(1).OAContext.ExptNum,results(1).OAContext.SoundTypeDesc);    
    save(output_file,'sorted_results');
    
    fprintf(1,'\nFinished: %s, ExptNum %d\n\n',params.Tank,params.ExptNum);
end