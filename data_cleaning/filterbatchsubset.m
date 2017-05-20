ff = load_batchf('batch.keep');
ff2 = load_batchf('batch.keep.rand');
ind = [];
for i = 1:length(ff2)
    for ii = 1:length(ff)
        if strcmp(ff(ii).name,ff2(i).name)
            ind = [ind;ii];
        else
            continue
        end
    end
end
ind_diff = setdiff([1:length(ff)],ind);

subset = randsample(ind_diff,ceil(0.17*length(ind_diff)));
subset = sort(subset);
ind = [ind' subset];
ind = sort(ind);

fkeep=fopen(['batch.keep','.rand2'],'w');

for i = 1:length(ind)
    
    fprintf(fkeep,'%s\n',ff(ind(i)).name);
    
end

fclose(fkeep);