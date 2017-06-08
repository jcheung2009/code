function check_motifdur(batch,motif)
%makes batch.keep.check to check motif labels where duration seems off

ff = load_batchf(batch);
cnt = 0;
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
    end
    ind = strfind(labels,motif);
    if isempty(ind)
        continue
    end
    for n = 1:length(ind)
        cnt=cnt+1;
        mdur(cnt).fn = ff(i).name;
        mdur(cnt).dur = offsets(ind(n)+length(motif)-1)-onsets(ind(n));
    end
end

ind = jc_findoutliers([mdur(:).dur]',3);
fkeep=fopen([batch,'.check'],'w');
for i = 1:length(ind)
    fprintf(fkeep,'%s\n',mdur(ind(i)).fn);
end
fclose(fkeep);