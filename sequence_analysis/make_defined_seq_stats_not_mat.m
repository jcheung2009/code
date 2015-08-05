function [seqcnstrct] = make_defined_seq_stats_not_mat(seqs,prbs,lng,name)

seqcnstrct =[];
for i =1:lng
    [v,idx] = sort(prbs,'descend');
    [idxs] = find(cumsum(v) >= rand(1));
    if isempty(idxs)
        crntseq =seqs{idx(1)};
    else
        crntseq = seqs{idxs(1)};
    end
    seqcnstrct = [seqcnstrct crntseq];
end


labels = seqcnstrct;
onsets = [1:length(labels)];
offsets = onsets+ones(size(onsets));
save([name '.not.mat'],'labels','onsets','offsets');