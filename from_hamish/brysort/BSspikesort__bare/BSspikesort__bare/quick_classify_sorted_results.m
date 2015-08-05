path_to_spikesort_output_folder = '\\holding\users\bryan\spike_data\classified_data\';

for i = 1:length(sorted_results);
    idx = sorted_results(i).OAContext.unsorted_events.event_idx;
    snippets = sorted_results(i).OAContext.unsorted_events.snippets;
%     snippetsToSort = sorted_results(i).OAContext.unsorted_events.snippetsToSort;
    [uids,ids,goodness,notes,toresort] = SpikeSortGuiM(idx,snippets);%snippetsToSort
    sorted_results(i).OAContext.sorted_events.uids = uids;
    sorted_results(i).OAContext.sorted_events.ids = ids;
    sorted_results(i).OAContext.sorted_events.goodness = goodness;
    sorted_results(i).OAContext.sorted_events.toresort = toresort;
end

classified_results = sorted_results;
output_file = sprintf('%s%s Expt %d %s classified.mat',path_to_spikesort_output_folder,classified_results(1).OAContext.Tank,classified_results(1).OAContext.ExptNum,classified_results(1).OAContext.SoundTypeDesc);    
save(output_file,'classified_results');

fprintf(1,'\nFinished: %s, ExptNum %d\n\n',params.Tank,params.ExptNum);