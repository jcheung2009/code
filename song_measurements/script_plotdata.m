function script_plotdata(batch,ind)
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
            if ~exist([params.findnote(n).fvstruct,ff(i).name])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,ff(i).name]);
            end
            fv = eval([params.findnote(n).fvstruct,ff(i).name]);
            if ~isempty(fv)
                jc_plotrawdata(fv,params.findnote(n).syllable,mrk,tb,fvfig(n),params.removeoutliers);
            end
        end
    end
    
    if isfield(params,'findmotif')
        for n = 1:length(params.findmotif)
            if ~exist([params.findmotif(n).motifstruct,ff(i).name])
                load(['analysis/data_structures/',params.findmotif(n).motifstruct,ff(i).name]);
            end
            mt = eval([params.findmotif(n).motifstruct,ff(i).name]);
            if ~isempty(fieldnames(mt))
                jc_plotmotifvals2(mt,params.findmotif(n).motif,mrk,tb,motiffig(n).a,motiffig(n).b,params.removeoutliers);
            end 
        end
    end
    
    if isfield(params,'findrepeat')
        for n = 1:length(params.findrepeat)
            if ~exist([params.findrepeat(n).repstruct,ff(i).name])
                load(['analysis/data_structures/',params.findrepeat(n).repstruct,ff(i).name]);
            end
            rp = eval([params.findrepeat(n).repstruct,ff(i).name]);
            if ~isempty(rp)
               jc_plotrepeatvals(rp,params.findrepeat(n).repnote,mrk,tb,repfig(n).a,repfig(n).b,params.removeoutliers); 
            end
        end
    end
    
    if isfield(params,'findbout')
        for n = 1:length(params.findbout)
            if ~exist([params.findbout(n).boutstruct,ff(i).name]) & exist(['analysis/data_structures/',params.findbout(n).boutstruct,ff(i).name])
                load(['analysis/data_structures/',params.findbout(n).boutstruct,ff(i).name]);
            else
                continue
            end
            bt = eval([params.findbout(n).boutstruct,ff(i).name]);
            if ~isempty(bt)
               jc_plotboutvals(bt,params.findbout(n).motif,mrk,color,tb,boutfig(n),params.findbout(n)); 
            end
        end
    end
end
    