%script to run jc_findrepeat5 for batch of folders
tic
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
batch = uigetfile;
ff = load_batchf(batch);
ind = input('batch index [st end]:');
for i = ind(1):ind(2)
    cd(ff(i).name);
    disp(ff(i).name);
    for ii = 1:length(params.findrepeat)
        if ~exist(params.findrepeat(ii).dtwtemplate)
            load(['../analysis/',params.findrepeat(ii).dtwtemplate]);
        end
        dtwtemplate = eval([params.findrepeat(ii).dtwtemplate]);
        cmd = [params.findrepeat(ii).repstructs,ff(i).name,'=','jc_findrepeat5(''batch.keep'',params.findrepeat(',num2str(ii),'),dtwtemplate,params.filetype,params.fs)'];
        eval(cmd);
        varname = [params.findrepeat(ii).repstructs,ff(i).name,''''];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
    end
    cd ..
end
toc