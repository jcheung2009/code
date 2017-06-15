function script_plotentropyvar(batch,ind)
%script to plot raw data of spectral and temporal features
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

for i = ind(1):ind(2)
    if isempty(ff(i).name)
        continue
    end
    disp(ff(i).name);
    
    [mrk color] = markercolor(ff(i).name);
    
    if ~isempty(numepochs)
        tb=tbshft(i);
    else
        tb='';
    end
    
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            if ~exist([params.findnote(n).fvstruct,ff(i).name])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,ff(i).name]);
            end
            jc_plotentropyvar(eval([params.findnote(n).fvstruct,ff(i).name]),...
                params.findnote(n).syllable,mrk,tb,fvfig(n),params.removeoutliers);
        end
    end
end