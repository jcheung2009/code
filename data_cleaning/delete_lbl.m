function delete_lbl(batch,lbl_to_delete);
%delete segmentations labelled by letter

ff = load_batchf(batch);
for i = 1:length(ff)
    load([ff(i).name,'.not.mat']);
    ind = strfind(labels,lbl_to_delete);
    labels(ind) = [];
    onsets(ind) = [];
    offsets(ind) = [];
    save([ff(i).name,'.not.mat'],'labels','onsets','offsets','-append');
end
