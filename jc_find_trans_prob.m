function transprobs = jc_find_trans_prob(batch,syllables)
%finds all divergent and convergent probabilities for all syllables
%{'a','b',etc}
%'x' represents motif stop or motif start
%transition probabilities consists of the mean, and 95% confidence interval
%from boot strapping


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

%divergent and convergent transitions
for i = 1:length(syllables)
    postnote = {};
    prenote = {};
    for ii = 1:length(motifstrings)
        ind = strfind(motifstrings{ii},syllables{i});
        for p = 1:length(ind)
            if length(motifstrings{ii}) == ind(p)
                postnote = [postnote;'x'];
            else
                postnote = [postnote;motifstrings{ii}(ind(p)+1)];
            end
            
            if ind(p) == 1
                prenote = [prenote; 'x'];
            else
                prenote = [prenote;motifstrings{ii}(ind(p)-1)];
            end
        end
    end
    [uniquepostnotes,~,idx] = unique(postnote);
    %[counts b] = hist(idx,[1:length(uniquepostnotes)]);
    for m = 1:length(uniquepostnotes)
        [mn hi lo] = mBootstrapseqCI(postnote,uniquepostnotes{m},'');
        transprobs.([syllables{i}]).divergence.([uniquepostnotes{m}]) = [mn hi lo];%95% confidence interval of trans probability
    end
    [uniqueprenotes,~,idx] = unique(prenote);
    for m = 1:length(uniqueprenotes)
        [mn hi lo] = mBootstrapseqCI(prenote,uniqueprenotes{m},'');
        transprobs.([syllables{i}]).convergence.([uniqueprenotes{m}]) = [mn hi lo];
    end
end

