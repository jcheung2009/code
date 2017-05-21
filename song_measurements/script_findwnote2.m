%script to run jc_findwnote5 in batch with config settings

%start in directory with all data folders
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
batch = uigetfile;
ff = load_batchf(batch);
ind = input('batch index [st, end]:');
tic
for i = ind(1):ind(2)%1:length(ff)
    cd(ff(i).name);
    disp(ff(i).name);
    numsylls = length(params.syllables);
    for n = 1:length(params.findnote)
        cmd = [params.findnote(n).fvstruct,ff(i).name,'=',...
            'jc_findwnote5(''batch.keep'',params.findnote(',num2str(n),'),params.filetype);'];
        eval(cmd);
    
        varname = [params.findnote(n).fvstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
    end
    cd ..
end
toc