function [idx,snippetsToSort] = quick_klustakwik_snippets(snippets,exe_dir)
%[idx] = quick_klustakwik_snippets(snippets,exe_dir)
%
%given some snippets and the path to the directory with the klustakwik
%code, this function will do spikesorting with the min, max, and first
%eight principal components and return the ids of each spike


log_file = 'BS_sort_log';
verbose = 1;
if ~exist('exe_dir','var')
    exe_dir = 'C:\Users\Bryan\Desktop\BSspikesort__bare\';
end

base_filename = 'spikes';

% savefile = ['BSS' input_file_name runTag 'KlustaKwik'];


%preprocess the data
data_columns = 1:size(snippets,2);
snippet_data = snippets(:,data_columns);
[~,snippets_pca] = princomp(snippet_data);
snippetsToSort = [min(snippet_data,[],2),max(snippet_data,[],2),snippets_pca(:,8)];

klustakwikfile = base_filename;
klustakwikpath = exe_dir;
numStarts = 3;
idx = KlustaKwik(klustakwikfile,klustakwikpath,snippetsToSort,numStarts,0);

return 