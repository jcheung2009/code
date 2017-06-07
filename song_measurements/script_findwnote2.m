function script_findwnote2(batch,ind)
%script to run jc_findwnote5 in batch with config settings
%start in directory with all data folders
%ind = index in batch 
tic
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
ff = load_batchf(batch);
if isempty(ind)
    ind = [1 length(ff)];
end

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
        
        trialind = find(arrayfun(@(x) strcmp(x.name,ff(i).name),params.trial));
        if isempty(trialind)
            trialparams = '';
        else
            trialparams = params.trial(trialind);
        end
        
        %for WN or light feedback 
        if isfield(trialparams,'fbdur')
            fbdur = trialparams.fbdur;
        else
            fbdur = '';
        end
        
        cmd = [params.findnote(n).fvstruct,ff(i).name,'=',...
            'jc_findwnote5(params.batchfile,params.findnote(',num2str(n),'),dtwtemplate,params.filetype,params.fs,fbdur);'];
        eval(cmd);

        varname = [params.findnote(n).fvstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ..
    end
end
toc