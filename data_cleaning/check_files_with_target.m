function check_files_with_target(batch,target);
%makes batch.check containing target label 



ff = load_batchf(batch);
fkeep=fopen([batch,'.check'],'w');

for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
    end
    ind = strfind(labels,target);
    if ~isempty(ind)
        fprintf(fkeep,'%s\n',ff(i).name);
    end
end
fclose(fkeep);
