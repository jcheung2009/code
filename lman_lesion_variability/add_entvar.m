%add entropy variance (wiener entropy) to fv struct

config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            for ind = 1:length(fv)
                smtmp = fv(ind).smtmp;
                filtsong = bandpass(smtmp,params.fs,500,10000,'hanningffir');
                ev = entropy_variance(filtsong,params.fs);
                fv(ind).entropyvar = ev;
            end
            cmd = [params.findnote(n).fvstruct,params.trial(i).name, '= fv'];
            eval(cmd);
            varname = [params.findnote(n).fvstruct,params.trial(i).name];
            matfile = fullfile(pathname,varname);
            savecmd = ['save(matfile,varname,''-v7.3'')'];
            eval(savecmd);
        end
    end
end