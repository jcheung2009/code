function script_findtempo(batch,ind)
%script to run jc_tempo in batch with config settings
%start in directory with all data folders
%ind = index in batch 

config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
ff = load_batchf(batch);
if isempty(ind)
    ind = [1:length(ff)];
end

for i = ind
    if isempty(ff(i).name)
        continue
    end
    disp(ff(i).name);
    cd(ff(i).name);
    
    cmd = ['durations_',ff(i).name,'=',...
        'jc_tempo(params.batchfile,params.filetype);'];
    eval(cmd);

    varname = ['durations_',ff(i).name];
    matfile = fullfile(pathname,varname);
    savecmd = ['save(matfile,varname,''-v7.3'')'];
    eval(savecmd);
    cd ..
end

