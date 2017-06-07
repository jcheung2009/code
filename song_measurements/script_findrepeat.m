function script_findrepeat(batch,ind)
%script to run jc_findrepeat5 for batch of folders
tic
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
ff = load_batchf(batch);
if isempty(ind)
    ind = [1 length(ff)];
end
for ii = 1:length(params.findrepeat)
    if ~exist(params.findrepeat(ii).dtwtemplate)
        load(['analysis/',params.findrepeat(ii).dtwtemplate]);
    end
    dtwtemplate = eval([params.findrepeat(ii).dtwtemplate]);
    for i = ind(1):ind(2)
        if isempty(ff(i).name)
            continue
        end
        disp(ff(i).name);
        cd(ff(i).name);
        if isfield(params.findrepeat(ii),'batchfile')
            batch = params.findrepeat(ii).batchfile;
        else
            batch = params.batchfile;
        end
        
        cmd = [params.findrepeat(ii).repstruct,ff(i).name,'=','jc_findrepeat5(batch,params.findrepeat(',num2str(ii),'),dtwtemplate,params.filetype,params.fs)'];
        eval(cmd);
        varname = [params.findrepeat(ii).repstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ..
    end
end
toc