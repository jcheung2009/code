function script_plotoptodatasummary(batch,ind)
%script to plot summary data of spectral and temporal features for OPTO
%experiments
%start in directory with all data folders

config;
ff = load_batchf(batch);
if isempty(ind)
    ind = [1 length(ff)];
end

if isfield(params,'findnote')
    for  n = 1:length(params.findnote)
        fvfig(n)=figure;
    end
end
if isfield(params,'findmotif')
    for  n = 1:length(params.findmotif)
        motiffig(n)=figure;
    end
end
cnt=1;
for i = ind(1):ind(2)
    if isempty(ff(i).name)
        continue
    end
    disp(ff(i).name);
    
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            load(['analysis/data_structures/',params.findnote(n).fvstruct,ff(i).name]);
            jc_plotoptofvsummary(eval([params.findnote(n).fvstruct,ff(i).name]),...
               params.findnote(n),fvfig(n),params,cnt);
        end
    end
    
    if isfield(params,'findmotif')
        for n = 1:length(params.findmotif)
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,ff(i).name]);
            jc_plotoptomotifsummary(eval([params.findmotif(n).motifstruct,ff(i).name]),...
                params.findmotif(n),motiffig(n),params,cnt);
        end
    end
    cnt=cnt+1;
end