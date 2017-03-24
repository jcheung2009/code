function jc_filterbatch(batch,percent)
%randomly choose subset of cleaned batch file

ff=load_batchf(batch);
subset = randsample(length(ff),ceil(percent*length(ff)));
subset = sort(subset);

fkeep=fopen([batch,'.rand'],'w');

for i = 1:length(subset)
    
    fprintf(fkeep,'%s\n',ff(subset(i)).name);
    
end

fclose(fkeep);
