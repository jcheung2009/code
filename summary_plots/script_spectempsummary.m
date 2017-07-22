%script for summary spectemp summary plots

config;

if isfield(params,'findnote')
    h1=figure;
end
if isfield(params,'findmotif')
    h2=figure;
end
if isfield(params,'findrepeat')
    h3=figure;
end
if isfield(params,'findbout')
    h4=figure;
end
summary=struct();
for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            prenote = params.findnote(n).prenotes;
            postnote = params.findnote(n).postnotes;
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).baseline]);
            if isfield(params.trial(i),'name2') && ~isempty(params.trial(i).name2)
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name2]);
                fv_cond1 = eval([params.findnote(n).fvstruct,params.trial(i).name]);
                fv_cond2 = eval([params.findnote(n).fvstruct,params.trial(i).name2]);
                fv_cond = [fv_cond1 fv_cond2];
            else
                fv_cond = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            end
            fv_base = eval([params.findnote(n).fvstruct,params.trial(i).baseline]);
            summary.spec(i).([prenote upper(syllable) postnote]) = jc_plotfvsummary3...
                (fv_base,fv_cond,syllable,params,params.trial(i),h1);
        end
    end
    
    if isfield(params,'findmotif')
        for n = 1:length(params.findmotif)
            motif = params.findmotif(n).motif;
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).baseline]);
            if isfield(params.trial(i),'name2') && ~isempty(params.trial(i).name2)
                    load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name2]);
                    motif_cond1 = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
                    motif_cond2 = eval([params.findmotif(n).motifstruct,params.trial(i).name2]);
                    motif_cond = [motif_cond1 motif_cond2];
            else
                motif_cond = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
            end
            motif_base = eval([params.findmotif(n).motifstruct,params.trial(i).baseline]);
            summary.temp(i).([motif]) = jc_plotmotifsummary4(motif_base,motif_cond,...
                motif,params,params.trial(i),h2);
        end
    end
    
    if isfield(params,'findrepeat')
        for n = 1:length(params.findrepeat)
            repeat = params.findrepeat(n).repnote;
            load(['analysis/data_structures/',params.findrepeat(n).repstruct,params.trial(i).name]);
            load(['analysis/data_structures/',params.findrepeat(n).repstruct,params.trial(i).baseline]);
            if isfield(params.trial(i),'name2') && ~isempty(params.trial(i).name2)
                load(['analysis/data_structures/',params.findrepeat(n).repstruct,params.trial(i).name2]);
                rep_cond1 = eval([params.findrepeat(n).repstruct,params.trial(i).name]);
                rep_cond2 = eval([params.findrepeat(n).repstruct,params.trial(i).name2]);
                rep_cond = [rep_cond1 rep_cond2];
            else
               rep_cond = eval([params.findrepeat(n).repstruct,params.trial(i).name]); 
            end
            rep_base = eval([params.findrepeat(n).repstruct,params.trial(i).baseline]);
            summary.rep(i).([repeat]) = jc_plotrepeatsummary3(rep_base,rep_cond,...
                repeat,params,params.trial(i),h3);
        end
    end
    
    if isfield(params,'findbout')
        for n = 1:length(params.findbout)
            bout = params.findbout(n).motif;
            if isempty(bout)
                bout = 'nomotif';
            end
            load(['analysis/data_structures/',params.findbout(n).boutstruct,params.trial(i).name]);
            load(['analysis/data_structures/',params.findbout(n).boutstruct,params.trial(i).baseline]);
            if isfield(params.trial(i),'name2') && ~isempty(params.trial(i).name2)
                load(['analysis/data_structures/',params.findbout(n).boutstruct,params.trial(i).name2]);
                bout_cond1 = eval([params.findbout(n).boutstruct,params.trial(i).name]);
                bout_cond2 = eval([params.findbout(n).boutstruct,params.trial(i).name2]);
                bout_cond = [bout_cond1 bout_cond2];
            else
                bout_cond = eval([params.findbout(n).boutstruct,params.trial(i).name]);
            end
            bout_base = eval([params.findbout(n).boutstruct,params.trial(i).baseline]); 
            summary.bout(i).([bout]) = jc_plotboutsummary3(bout_base,bout_cond,...
                params,params.trial(i),h4);
        end
    end
            
end
            
        
        
