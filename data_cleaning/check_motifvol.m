function mdur = check_motifvol(batch,motif,hithresh,lothresh)
%makes batch.keep.check to check motif labels where volume seems off
%hithresh and lothresh are in seconds

ff = load_batchf(batch);
cnt = 0;
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
        [dat fs] = evsoundin('',ff(i).name,'obs0');
    end
    ind = strfind(labels,motif);
    if isempty(ind)
        continue
    end
    for n = 1:length(ind)
        cnt=cnt+1;
        mdur(cnt).fn = ff(i).name;
        smtemp = dat(floor(onsets(ind(n))*1e-3*fs):ceil(offsets(ind(n))*1e-3*fs));
        sm = evsmooth(smtemp,fs,'','','',5);
        mdur(cnt).vol = mean(log10(sm));
    end
end
fkeep=fopen([batch,'.check'],'w');
ind = [];
if isempty(hithresh) & isempty(lothresh)
    ind = jc_findoutliers([mdur(:).vol]',3);
elseif ~isempty(hithresh)
    ind1 = find([mdur(:).vol] >= hithresh);
    ind = [ind ind1];
elseif ~isempty(lothresh)
    ind2 = find([mdur(:).vol] <= lothresh);
    ind = [ind ind2];
end
filelist = unique(arrayfun(@(x) x.fn,mdur(ind),'unif',0));
for i = 1:length(filelist)
    fprintf(fkeep,'%s\n',filelist{i});
end
fclose(fkeep);