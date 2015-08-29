function [motifs] = jc_findmotifsequences(batch)
%finds all motifs in batch and counts their frequency
%finds divergent and convergent transition probabilities for all syllables {'a','b',etc}

%extract labels from each song file into cell
labelstrings = {};
ff = load_batchf(batch);
for i = 1:length(ff)
    load([ff(i).name,'.not.mat']);
    labelstrings = [labelstrings;labels];
end

%find motifs and store in cell
motifstrings = {};
for i = 1:length(labelstrings)
    [s e] = regexp(labelstrings{i},'\w+');
    for ii = 1:length(s)
    motifstrings = [motifstrings; labelstrings{i}(s(ii):e(ii))];
    end
end

%count the number of times each type of motif occurs 
[uniquestrings, ~, ind] = unique(motifstrings);
[counts b] = hist(ind,[1:length(uniquestrings)]);
motifs.strings = uniquestrings;
motifs.counts = counts';


            
        