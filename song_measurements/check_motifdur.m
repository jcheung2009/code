function mdur = check_motifdur(batch,motif,hithresh,lothresh)
%makes batch.keep.check to check motif labels where duration seems off
%hithresh and lothresh are in seconds

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
        mdur(cnt).dur = 1e-3*(offsets(ind(n)+length(motif)-1)-onsets(ind(n)));
    end
end
fkeep=fopen([batch,'.check'],'w');
ind = [];
if isempty(hithresh) & isempty(lothresh)
    ind = jc_findoutliers([mdur(:).dur]',3);
elseif ~isempty(hithresh)
    ind1 = find([mdur(:).dur] >= hithresh);
    ind = [ind ind1];
elseif ~isempty(lothresh)
    ind2 = find([mdur(:).dur] <= lothresh);
    ind = [ind ind2];
end
filelist = unique(arrayfun(@(x) x.fn,mdur(ind),'unif',0));
for i = 1:length(filelist)
    fprintf(fkeep,'%s\n',filelist{i});
end
fclose(fkeep);