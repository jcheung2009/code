%script for summary of pitch aftereffects for naspm error analysis

config;
birdnm = params.birdname;

if isfield(params,'findnote')
    h1=figure;
end

if ~exist(['summary_',birdnm])
    load(['analysis/data_structures/summary_',birdnm]);
end
summary = eval(['summary_',birdnm]);
for i = 1:length(params.trial)
    if isfield(params.trial(i),'post') 
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            prenote = params.findnote(n).prenotes;
            postnote = params.findnote(n).postnotes;
            if ~exist([params.findnote(n).fvstruct,params.trial(i).baseline])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).baseline]);
            end
            if ~exist([params.findnote(n).fvstruct,params.trial(i).post])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).post]);
            end
            pre = eval([params.findnote(n).fvstruct,params.trial(i).baseline]);
            post = eval([params.findnote(n).fvstruct,params.trial(i).post]);
            summary.error(i).([prenote upper(syllable) postnote]) = jc_ploterrorsummary(...
                pre,post,syllable,params,params.trial(i),h1);
        end
    end
end