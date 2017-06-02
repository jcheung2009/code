%script to plot raw data of spectral and temporal features
%start in directory with all data folders
config;

batch = uigetfile;
ff = load_batchf(batch);
ind = input('batch index [st, end]:');
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
if isfield(params,'findrepeat')
    for  n = 1:length(params.findrepeat)
        repfig(n).a=figure;repfig(n).b=figure;
    end
end
if isfield(params,'findbout')
    for  n = 1:length(params.findbout)
        boutfig(n)=figure;
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
            load(['analysis/data_structures/',params.findnote(n).fvstruct,ff(i).name]);
            jc_plotrawdata(eval([params.findnote(n).fvstruct,ff(i).name]),...
                mrk,tb,fvfig(n),params.removeoutliers);
        end
    end
    
    if isfield(params,'findmotif')
        for n = 1:length(params.findmotif)
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,ff(i).name]);
            jc_plotmotifvals2(eval([params.findmotif(n).motifstruct,ff(i).name]),...
                mrk,tb,motiffig(n).a,motiffig(n).b,params.removeoutliers);
        end
    end
    
    if isfield(params,'findrepeat')
        for n = 1:length(params.findrepeat)
            load(['analysis/data_structures/',params.findrepeat(n).repstruct,ff(i).name]);
            jc_plotrepeatvals(eval([params.findrepeat(n).repstruct,ff(i).name]),...
                mrk,tb,repfig(n).a,repfig(n).b,params.removeoutliers);
        end
    end
    
    if isfield(params,'findbout')
        for n = 1:length(params.findbout)
            load(['analysis/data_structures/',params.findbout(n).boutstruct,ff(i).name]);
            jc_plotboutvals(eval([params.findbout(n).boutstruct,ff(i).name]),...
                mrk,color,tb,boutfig(n),params.findbout(n));
        end
    end
end
    