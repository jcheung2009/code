%script to run jc_findmotifs for batch of folders
tic
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
batch = uigetfile;
ff = load_batchf(batch);
ind = input('batch index [st end]:');

for ii = 1:length(params.findmotif)
    if ~exist(params.findmotif(ii).dtwtemplate)
        load(['analysis/',params.findmotif(ii).dtwtemplate]);
    end
    dtwtemplate = eval([params.findmotif(ii).dtwtemplate]);
    for i = ind(1):ind(2)%1:length(ff)
        if isempty(ff(i).name)
            continue
        end
        disp(ff(i).name);
        cd(ff(i).name);
        cmd = [params.findmotif(ii).motifstruct,ff(i).name,'=','jc_findmotifs(params.batchfile,params.findmotif(',num2str(ii),'),dtwtemplate,params.filetype,params.fs)'];
        eval(cmd);

        varname = [params.findmotif(ii).motifstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ..
    end
end
toc