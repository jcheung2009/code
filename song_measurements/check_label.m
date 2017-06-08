function check_label(batch,label)


fkeep=fopen([batch,'.check'],'w');
ff = load_batchf(batch);

for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
            load([ff(i).name,'.not.mat']);
     end
    ind = strfind(labels,label);
    if ~isempty(ind)
        fprintf(fkeep,'%s\n',ff(i).name);
    end
end
fclose(fkeep);