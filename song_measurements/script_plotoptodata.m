function script_plotoptodata(batch,ind)
%script to plot raw data of spectral and temporal features for OPTO
%experiments
%start in directory with all data folders

config;
ff = load_batchf(batch);
if isempty(ind)
    ind = [1 length(ff)];
end
numepochs = params.numepochs;
if ~isempty(numepochs)
    tbshft = repmat([0:length(ff)/numepochs-1],numepochs,1);
    tbshft = tbshft(:);
end

if isfield(params,'findnote')
    for  n = 1:length(params.findnote)
        fvfig(n)=figure;
    end
end
if isfield(params,'findmotif')
    for  n = 1:length(params.findmotif)
        motiffig(n).a=figure;motiffig(n).b=figure;
    end
end

for i = ind(1):ind(2)
    if isempty(ff(i).name)
        continue
    end
    disp(ff(i).name);
    
    if ~isempty(numepochs)
        tb=tbshft(i);
    else
        tb='';
    end
    
    trialind = find(arrayfun(@(x) strcmp(x.name,ff(i).name),params.trial));
    if isempty(trialind)
        trialparams = '';
    else
        trialparams = params.trial(trialind);
    end
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            load(['analysis/data_structures/',params.findnote(n).fvstruct,ff(i).name]);
            jc_plotoptofvdata(eval([params.findnote(n).fvstruct,ff(i).name]),...
                tb,params.findnote(n),trialparams,fvfig(n),params);
        end
    end
    
    if isfield(params,'findmotif')
        for n = 1:length(params.findmotif)
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,ff(i).name]);
            jc_plotoptomotifvals(eval([params.findmotif(n).motifstruct,ff(i).name]),...
                tb,params.findmotif(n),trialparams,motiffig(n).a,motiffig(n).b,params);
        end
    end
end