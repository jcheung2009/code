%extract data table of gap durations and predictors 
%for gaps that are bordered by syllables with spectral measurements

config;
condition = {'naspm','iem','saline'};
data = [];
trialnms = {};%make sure no duplicate observations
if isfield(params,'gapdata') 
    trialnms = [trialnms params.gapdata.excludetrials];
end
nstd = 3;
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
            gapind = gapind(arrayfun(@(x) length(intersect(syllind,[x x+1]))==2,gapind));
            
            if isempty(find(cellfun(@(x) strcmp(x,params.trial(i).name),trialnms)))
                load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
                motif_cond = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
            else
                motif_cond = '';
            end
            
            if isempty(find(cellfun(@(x) strcmp(x,params.trial(i).baseline),trialnms)))
                load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).baseline]);
                motif_base = eval([params.findmotif(n).motifstruct,params.trial(i).baseline]);
            else
                motif_base = '';
            end

            for m = 1:length(gapind)
                ind = [find(syllind == gapind(m)) find(syllind == gapind(m)+1)];
                if ~isempty(motif_base)
                    gap_base = jc_removeoutliers(arrayfun(@(x) x.gaps(gapind(m)),motif_base)',nstd);
                    pitch_base = jc_removeoutliers(cell2mat(arrayfun(@(x) x.syllpitch(ind)',motif_base,'unif',0)'),nstd);
                    vol_base = jc_removeoutliers(cell2mat(arrayfun(@(x) log10(x.syllvol(ind)'),motif_base,'unif',0)'),nstd);
                    dur_base = jc_removeoutliers(cell2mat(arrayfun(@(x) x.durations(ind)',motif_base,'unif',0)'),nstd);
                    data = [data; gap_base pitch_base vol_base dur_base zeros(length(gap_base),1)...
                    repmat(gapid,length(gap_base),1)];
                end
                
                if ~isempty(motif_cond)
                    gap_cond = jc_removeoutliers(arrayfun(@(x) x.gaps(gapind(m)),motif_cond)',nstd);
                    pitch_cond = jc_removeoutliers(cell2mat(arrayfun(@(x) x.syllpitch(ind)',motif_cond,'unif',0)'),nstd);
                    vol_cond = jc_removeoutliers(cell2mat(arrayfun(@(x) log10(x.syllvol(ind)'),motif_cond,'unif',0)'),nstd);
                    dur_cond = jc_removeoutliers(cell2mat(arrayfun(@(x) x.durations(ind)',motif_cond,'unif',0)'),nstd);
                    if ~strcmp(condition{indcond},'saline')
                        data = [data; gap_cond pitch_cond vol_cond dur_cond ones(length(gap_cond),1)...
                            repmat(gapid,length(gap_cond),1)];
                    else
                        data = [data; gap_cond pitch_cond vol_cond dur_cond zeros(length(gap_cond),1)...
                            repmat(gapid,length(gap_cond),1)];
                    end
                end
                gapid=gapid+1;
            end    
        end
        trialnms = [trialnms,{params.trial(i).name}];
        trialnms = [trialnms,{params.trial(i).baseline}];
    end
end

data = [data NaN(size(data,1),2)];
gapid = unique(data(:,9));
for i = 1:length(gapid)
    ind = data(:,9)==gapid(i) & data(:,8)==0;
    meangap = nanmean(data(ind,1));
    gapcv = cv(data(ind,1));
    data(ind,10:11) = [repmat([meangap gapcv],[size(find(ind)),1])];
    ind2 = data(:,9)==gapid(i) & data(:,8)==1;
    data(ind2,10:11) = [repmat([meangap gapcv],[size(find(ind2)),1])];
end

gapdata = table(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),data(:,6),data(:,7),data(:,8),...
    data(:,9),data(:,10),data(:,11),repmat({params.birdname},size(data,1),1),...
    'VariableNames',{'GapDur','PitchN1','PitchN2','VolN1','VolN2',...
    'DurN1','DurN2','Treatment','GapID','MeanGap','GapCV','BirdID'});