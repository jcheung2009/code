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
summary.error = [];
cnt=0;
for i = 1:length(params.trial)
    if isfield(params.trial(i),'post')
        if ~isempty(params.trial(i).post) & ~strcmp(params.trial(i).condition,'saline')
            cnt=cnt+1;
        end
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            prenote = params.findnote(n).prenotes;
            postnote = params.findnote(n).postnotes;
            if ~exist([params.findnote(n).fvstruct,params.trial(i).baseline])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).baseline]);
            end
            if ~isempty(params.trial(i).post) 
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).post]);
                post = eval([params.findnote(n).fvstruct,params.trial(i).post]);
            elseif strcmp(params.trial(i).condition,'saline')
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
                post = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            else
                continue
            end
            pre = eval([params.findnote(n).fvstruct,params.trial(i).baseline]);
            summary.error(cnt).([prenote upper(syllable) postnote]) = jc_ploterrorsummary(...
                pre,post,syllable,params,params.trial(i),h1);
        end
    end
end