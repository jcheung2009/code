%script to run jc_findwnote5 in batch with config settings
%start in directory with all data folders
tic
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
batch = uigetfile;
ff = load_batchf(batch);
ind = input('batch index [st, end]:');
for n = 1:length(params.findnote)
    if ~exist(params.findnote(n).dtwtemplate)
        load(['analysis/',params.findnote(n).dtwtemplate]);
    end
    dtwtemplate = eval([params.findnote(n).dtwtemplate]);
    for i = ind(1):ind(2)
        if isempty(ff(i).name)
            continue
        end
        disp(ff(i).name);
        cd(ff(i).name);
        cmd = [params.findnote(n).fvstruct,ff(i).name,'=',...
            'jc_findwnote5(params.batchfile,params.findnote(',num2str(n),'),dtwtemplate,params.filetype,params.fs);'];
        eval(cmd);

        varname = [params.findnote(n).fvstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ..
    end
end
toc