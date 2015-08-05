function [] = make_markov_notmat(trns_strct,length,name)

crntsyl = 1;
for i = 1:length
    %%%generate transtion from prevsyl to crntsyl stochastically
    [v,idx] = sort(trns_strct.mtrx(:,crntsyl),'descend');
    [idxs] = find(cumsum(v) >= rand(1));
    %the currently active SMU
    if isempty(idxs)
        crntsyl =idx(1);
    else
        crntsyl = idx(idxs(1));
    end
    labels(i) = trns_strct.lbls(crntsyl);
end

onsets = [1:size(labels,2)];
offsets = ones(size(onsets))+onsets;

save([char(name) '.markov_seq.not.mat'],'labels','onsets','offsets');