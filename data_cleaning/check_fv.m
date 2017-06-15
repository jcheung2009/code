function check_fv(fv,hithresh,lothresh);
%makes batch.keep.check to check syll labels where pitch seems off
%hithresh and lothresh are pitch thresholds

mxvals = [fv(:).mxvals];
ind = [];
if isempty(hithresh) & isempty(lothresh)
    ind = jc_findoutliers(mxvals,3);
elseif ~isempty(hithresh)
    ind1 = find(mxvals >= hithresh);
    ind = [ind ind1];
elseif ~isempty(lothresh)
    ind2 = find(mxvals <= lothresh);
    ind = [ind ind2];
end
fkeep=fopen(['batch.keep.check'],'w');
filelist = unique(arrayfun(@(x) x.fn,fv(ind),'unif',0));
for i = 1:length(filelist)
    fprintf(fkeep,'%s\n',filelist{i});
end
fclose(fkeep);

