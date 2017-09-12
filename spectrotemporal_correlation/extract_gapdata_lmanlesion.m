%extract data table of gap durations and predictor for lman lesion data set
%for gaps that are preceded by syllables with spectral measurements

config;
condition = {'pre','post'};
data = [];
trialnms = {};%make sure no duplicate observations
if isfield(params,'gapdata') 
    trialnms = [trialnms params.gapdata.excludetrials];
end
nstd = 3;
filenms = {};
for indcond = 1:length(condition)
    for i = 1:length(params.trial)
        if ~strcmp(params.trial(i).condition,condition{indcond})
            continue
        end
        gapid = 1;
        for n = 1:length(params.findmotif)
            motif = params.findmotif(n).motif;
            syllables = params.findmotif(n).syllables;
            syllind = cell2mat(cellfun(@(x) strfind(motif,x),syllables,'unif',0)); 
            gapind = 1:length(motif)-1;
            gapind = gapind(arrayfun(@(x) ~isempty(intersect(syllind,x)),gapind));
            
            if isempty(find(cellfun(@(x) strcmp(x,params.trial(i).name),trialnms)))
                load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
                motif_cond = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
            else
                motif_cond = '';
            end

            for m = 1:length(gapind)
                ind = find(syllind == gapind(m));
                if ~isempty(motif_cond)
                    gap_cond = jc_removeoutliers(arrayfun(@(x) x.gaps(gapind(m)),motif_cond)',nstd);
                    pitch_cond = jc_removeoutliers(cell2mat(arrayfun(@(x) x.syllpitch(ind)',motif_cond,'unif',0)'),nstd);
                    vol_cond = jc_removeoutliers(cell2mat(arrayfun(@(x) log10(x.syllvol(ind)'),motif_cond,'unif',0)'),nstd);
                    dur_cond = jc_removeoutliers(cell2mat(arrayfun(@(x) x.durations(ind)',motif_cond,'unif',0)'),nstd);
                    rendind = [motif_cond(:).boutind]';
                    filenms = [filenms; {motif_cond(:).filename}'];
                    if ~strcmp(condition{indcond},'pre')
                        data = [data; gap_cond pitch_cond vol_cond dur_cond ones(length(gap_cond),1)...
                             rendind repmat(gapid,length(gap_cond),1)];
                    else
                        data = [data; gap_cond pitch_cond vol_cond dur_cond zeros(length(gap_cond),1)...
                            rendind repmat(gapid,length(gap_cond),1)];
                    end
                end
                gapid=gapid+1;
            end    
        end
        trialnms = [trialnms,{params.trial(i).name}];
    end
end

%add average baseline gap and gap cv
data = [data NaN(size(data,1),2)];
gapid = unique(data(:,7));
for i = 1:length(gapid)
    ind = data(:,7)==gapid(i) & data(:,5)==0;
    meanpitch = nanmean(data(ind,2));
    pitchcv = cv(data(ind,2));
    data(ind,8:9) = [repmat([meanpitch pitchcv],[size(find(ind)),1])];
    ind2 = data(:,7)==gapid(i) & data(:,5)==1;
    meanpitch = nanmean(data(ind2,2));
    pitchcv = cv(data(ind2,2));
    data(ind2,8:9) = [repmat([meanpitch pitchcv],[size(find(ind2)),1])];
end

gapdata = table(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7),data(:,8),...
    data(:,9),filenms,repmat({params.birdname},size(data,1),1),...
    'VariableNames',{'GapDur','PitchN1','VolN1','DurN1','Treatment',...
    'RenditionID','GapID','MeanPitch','PitchCV','BoutID','BirdID'});