function jc_checkrepeatlabel(batch,nt,prent);
%use to check labelling of repeats before using jc_findrepeat2
%make sure target syllable is only preceded by the prent or by itself

ff = load_batchf(batch);

for i = 1:length(ff)
    fn = ff(i).name;
    load([fn,'.not.mat']);
    ind = strfind(labels,nt);
    if ~isempty(find(labels(ind-1)~=prent&labels(ind-1)~=nt))
        disp(fn)
    end
end
