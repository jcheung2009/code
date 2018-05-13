%trial by trial correlation of pitch/volume with gap durations in front and
%back
%extracts raw data and places into table pitchvolgap_tbl
%performs pairwise correlation and shuffle tests and stores in table
%pitchvolgap_corr

config;
shufftrials = 1000;
drug = 'saline';%naspm
baselinecondition = 'saline1';%saline in naspm, saline1 in saline
treatmentcondition = 'saline2';%naspm in naspm, saline2 in saline

trials = params.trial(arrayfun(@(x) strcmp(x.condition,drug),params.trial));
gapfordata = [];
gapbackdata = [];
for mtf = 1:length(params.findmotif)
    %preset data cell for number of syllables with gaps in front and back
    syllables = params.findmotif(mtf).syllables;
    motif = params.findmotif(mtf).motif;
    syllcnt = 0;
    for syllix = 1:length(syllables)
        mtfind = strfind(motif,syllables{syllix});
        for id = 1:length(mtfind)
            syllgapfordata = cell(1,2,2);
            syllgapbackdata = cell(1,2,2);
            syllcnt = syllcnt + 1;
            f1 = figure;%pitch
            f2 = figure;%volume
            for trialind = 1:length(trials)
                load(['analysis/data_structures/',params.findmotif(mtf).motifstruct,trials(trialind).name]);
                load(['analysis/data_structures/',params.findmotif(mtf).motifstruct,trials(trialind).baseline]);
                basedata = eval([params.findmotif(mtf).motifstruct,trials(trialind).baseline]);
                testdata = eval([params.findmotif(mtf).motifstruct,trials(trialind).name]);
    
                %cut off washin time
                tb_cond = jc_tb([testdata(:).datenm]',7,0);
                tb_base = jc_tb([basedata(:).datenm]',7,0);
                if ~strcmp(drug,'saline') & ~strcmp(params.baseepoch,'morn')
                    if ~isempty(trials(trialind).treattime)
                        start_time = time2datenum(trials(trialind).treattime) + 3600;%1.5 hr buffer
                    else
                        start_time = tb_cond(1) + 3600; 
                    end
                    ind = find(tb_cond >= start_time);
                    testdata = testdata(ind);
                else
                    ind = find(tb_cond >= 5*3600);
                    testdata = testdata(ind);
                    ind = find(tb_base < 5*3600);
                    basedata = basedata(ind);
                end
                
                %extract pitch and volume data
                pitch = arrayfun(@(x) x.syllpitch(syllcnt),basedata,'un',1)';
                volume = log10(arrayfun(@(x) x.syllvol(syllcnt),basedata,'un',1)');
                pitch2 = arrayfun(@(x) x.syllpitch(syllcnt),testdata,'un',1)';
                volume2 = log10(arrayfun(@(x) x.syllvol(syllcnt),testdata,'un',1)');
                
                pitch = jc_removeoutliers(pitch,3);
                pitch2 = jc_removeoutliers(pitch2,3);
                volume = jc_removeoutliers(volume,3);
                volume2 = jc_removeoutliers(volume2,3);
                
                pitch2 = (pitch2-nanmean(pitch))./nanstd(pitch);
                pitch = (pitch-nanmean(pitch))./nanstd(pitch);
                volume2 = (volume2-nanmean(volume))./nanstd(volume);
                volume = (volume-nanmean(volume))./nanstd(volume);
                
                %extract gap durations
                if mtfind(id) ~= length(motif)
                    gapdurfor1 = arrayfun(@(x) x.gaps(mtfind(id)),basedata,'un',1)';
                    gapdurfor2 = arrayfun(@(x) x.gaps(mtfind(id)),testdata,'un',1)';
                    gapdurfor2 = (gapdurfor2-nanmean(gapdurfor1))./nanstd(gapdurfor1);
                    gapdurfor1 = (gapdurfor1-nanmean(gapdurfor1))./nanstd(gapdurfor1);
                    
                    gapdurfor1 = jc_removeoutliers(gapdurfor1,3);
                    gapdurfor2 = jc_removeoutliers(gapdurfor2,3);
                    
                    syllgapfordata{1,1,1} = [syllgapfordata{1,1,1}; pitch gapdurfor1];
                    syllgapfordata{1,1,2} = [syllgapfordata{1,1,2}; volume gapdurfor1];
                    syllgapfordata{1,2,1} = [syllgapfordata{1,2,1}; pitch2 gapdurfor2];
                    syllgapfordata{1,2,2} = [syllgapfordata{1,2,2}; volume2 gapdurfor2];
                end
                
                if mtfind(id) ~= 1
                    gapdurback1 = arrayfun(@(x) x.gaps(mtfind(id)-1),basedata,'un',1)';
                    gapdurback2 = arrayfun(@(x) x.gaps(mtfind(id)-1),testdata,'un',1)';
                    gapdurback2 = (gapdurback2-nanmean(gapdurback1))./nanstd(gapdurback1);
                    gapdurback1 = (gapdurback1-nanmean(gapdurback1))./nanstd(gapdurback1);
                    
                    gapdurback1 = jc_removeoutliers(gapdurback1,3);
                    gapdurback2 = jc_removeoutliers(gapdurback2,3);
                    
                    syllgapbackdata{1,1,1} = [syllgapbackdata{1,1,1}; pitch gapdurback1];
                    syllgapbackdata{1,1,2} = [syllgapbackdata{1,1,2}; volume gapdurback1];
                    syllgapbackdata{1,2,1} = [syllgapbackdata{1,2,1}; pitch2 gapdurback2];
                    syllgapbackdata{1,2,2} = [syllgapbackdata{1,2,2}; volume2 gapdurback2];
                end
                
                %plot pitch vs gap correlations for each trial
                if mtfind(id) ~= length(motif)
                    figure(f1);hold on;
                    subplot(2,length(trials),trialind);hold on;
                    plot(pitch,gapdurfor1,'k.');hold on;
                    plot(pitch2,gapdurfor2,'r.');
                    xlabel('pitch');ylabel('gap dur forward');
                    title(strjoin({'syll',num2str(mtfind(id)),trials(trialind).name}),...
                        'interpreter','none')
                    subplot(2,length(trials),trialind+length(trials));hold on;
                    plot(volume,gapdurfor1,'k.');hold on;
                    plot(volume2,gapdurfor2,'r.');hold on;
                    xlabel('volume');ylabel('gap dur forward');
                end
                if mtfind(id) ~= 1
                    figure(f2);hold on;
                    subplot(2,length(trials),trialind);hold on;
                    plot(pitch,gapdurback1,'k.');hold on;
                    plot(pitch2,gapdurback2,'r.');
                    xlabel('pitch');ylabel('gap dur back');
                    title(strjoin({'syll',num2str(mtfind(id)),trials(trialind).name}),...
                        'interpreter','none')
                    subplot(2,length(trials),trialind+length(trials));hold on;
                    plot(volume,gapdurback1,'k.');hold on;
                    plot(volume2,gapdurback2,'r.');hold on;
                    xlabel('volume');ylabel('gap dur back');
                end
            end
            if mtfind(id) ~= length(motif)
                gapfordata = [gapfordata; syllgapfordata];
            end
            if mtfind(id) ~= 1
                gapbackdata = [gapbackdata; syllgapbackdata];
            end
        end
        
    end
end
    
    

%% plot pairwise correlation for data combined across trials and save into table
if ~exist(['analysis/data_structures/pitchvolgap_correlation_',params.birdname,'.mat'])
    pitchvolgap_corr = table([],[],[],[],[],[],[],[],'VariableNames',...
        {'birdname','syllID','condition','gaptype','pitchgap',...
        'volgap','pitchgap_shuff','volgap_shuff'});
    pitchvolgap_tbl = table([],[],[],[],[],[],[],'VariableNames',{'birdname','syllID',...
        'condition','gaptype','pitch','volume','gapdur'});
else
    load(['analysis/data_structures/pitchvolgap_correlation_',params.birdname]);
end
birdnm = params.birdname;
f1 = figure;%gapfor
for i = 1:size(gapfordata,1)
    figure(f1);hold on;
    subplot(2,size(gapfordata,1),i);hold on;
    plot(gapfordata{i,1,1}(:,1),gapfordata{i,1,1}(:,2),'k.');hold on;
    plot(gapfordata{i,2,1}(:,1),gapfordata{i,2,1}(:,2),'r.');hold on;
    xlabel('pitch');ylabel('gap dur forward');
    
    subplot(2,size(gapfordata,1),i+size(gapfordata,1));hold on;
    plot(gapfordata{i,1,2}(:,1),gapfordata{i,1,2}(:,2),'k.');hold on;
    plot(gapfordata{i,2,2}(:,1),gapfordata{i,2,2}(:,2),'r.');hold on;
    xlabel('volume');ylabel('gap dur forward');
    
    %correlation and significance values for pairwise comparison
    [r p] = corrcoef(gapfordata{i,1,1}(:,1),gapfordata{i,1,1}(:,2),...
        'rows','complete');
    [r2 p2] = corrcoef(gapfordata{i,2,1}(:,1),gapfordata{i,2,1}(:,2),...
        'rows','complete');
    pitchgapforbasecorr = [r(2) p(2)];
    pitchgapforcorr = [r2(2) p2(2)];
    
    [r p] = corrcoef(gapfordata{i,1,2}(:,1),gapfordata{i,1,2}(:,2),...
        'rows','complete');
    [r2 p2] = corrcoef(gapfordata{i,2,2}(:,1),gapfordata{i,2,2}(:,2),...
        'rows','complete');
    volgapforbasecorr = [r(2) p(2)];
    volgapforcorr = [r2(2) p2(2)];
    
    %shuffle tests
    [pitchgapforbaseshuff pitchgapforbaseshuffpval] = ...
        shuffle(gapfordata{i,1,1}(:,1),gapfordata{i,1,1}(:,2),shufftrials);
    [pitchgapforshuff pitchgapforshuffpval] = ...
        shuffle(gapfordata{i,2,1}(:,1),gapfordata{i,2,1}(:,2),shufftrials);
    [volgapforbaseshuff volgapforbaseshuffpval] = ...
        shuffle(gapfordata{i,1,2}(:,1),gapfordata{i,1,2}(:,2),shufftrials);
    [volgapforshuff volgapforshuffpval] = ...
        shuffle(gapfordata{i,2,2}(:,1),gapfordata{i,2,2}(:,2),shufftrials);
    
    pitchvolgap_corr = [pitchvolgap_corr; table({birdnm},{num2str(i)},{baselinecondition},...
        {'forward'},pitchgapforbasecorr,volgapforbasecorr,...
        {pitchgapforbaseshuff pitchgapforbaseshuffpval},...
        {volgapforbaseshuff volgapforbaseshuffpval},'VariableNames',...
        {'birdname','syllID','condition','gaptype','pitchgap',...
        'volgap','pitchgap_shuff','volgap_shuff'})];
    pitchvolgap_corr = [pitchvolgap_corr; table({birdnm},{num2str(i)},{treatmentcondition},...
        {'forward'},pitchgapforcorr,volgapforcorr,...
        {pitchgapforshuff pitchgapforshuffpval},...
        {volgapforshuff volgapforshuffpval},'VariableNames',...
        {'birdname','syllID','condition','gaptype','pitchgap',...
        'volgap','pitchgap_shuff','volgap_shuff'})];

    pitchvolgap_tbl = [pitchvolgap_tbl; table(repmat({birdnm},length(gapfordata{i,1,1}),1),...
        repmat({num2str(i)},length(gapfordata{i,1,1}),1),...
        repmat({baselinecondition},length(gapfordata{i,1,1}),1),...
        repmat({'forward'},length(gapfordata{i,1,1}),1),...
        gapfordata{i,1,1}(:,1),gapfordata{i,1,2}(:,1),...
        gapfordata{i,1,1}(:,2),'VariableNames',{'birdname','syllID',...
        'condition','gaptype','pitch','volume','gapdur'})];
    pitchvolgap_tbl = [pitchvolgap_tbl; table(repmat({birdnm},length(gapfordata{i,2,1}),1),...
        repmat({num2str(i)},length(gapfordata{i,2,1}),1),...
        repmat({treatmentcondition},length(gapfordata{i,2,1}),1),...
        repmat({'forward'},length(gapfordata{i,2,1}),1),...
        gapfordata{i,2,1}(:,1),gapfordata{i,2,2}(:,1),...
        gapfordata{i,2,1}(:,2),'VariableNames',{'birdname','syllID',...
        'condition','gaptype','pitch','volume','gapdur'})];
end

f2 = figure;%gapback        
for i = 1:size(gapbackdata,1)
    figure(f2);hold on;
    subplot(2,size(gapbackdata,1),i);hold on;
    plot(gapbackdata{i,1,1}(:,1),gapbackdata{i,1,1}(:,2),'k.');hold on;
    plot(gapbackdata{i,2,1}(:,1),gapbackdata{i,2,1}(:,2),'r.');hold on;
    xlabel('pitch');ylabel('gap dur back');
    
    subplot(2,size(gapbackdata,1),i+size(gapbackdata,1));hold on;
    plot(gapbackdata{i,1,2}(:,1),gapbackdata{i,1,2}(:,2),'k.');hold on;
    plot(gapbackdata{i,2,2}(:,1),gapbackdata{i,2,2}(:,2),'r.');hold on;
    xlabel('volume');ylabel('gap dur back');
    
    %correlation and significance values for pairwise comparison
    [r p] = corrcoef(gapbackdata{i,1,1}(:,1),gapbackdata{i,1,1}(:,2),...
        'rows','complete');
    [r2 p2] = corrcoef(gapbackdata{i,2,1}(:,1),gapbackdata{i,2,1}(:,2),...
        'rows','complete');
    pitchgapbackbasecorr = [r(2) p(2)];
    pitchgapbackcorr = [r2(2) p2(2)];
    
    [r p] = corrcoef(gapbackdata{i,1,2}(:,1),gapbackdata{i,1,2}(:,2),...
        'rows','complete');
    [r2 p2] = corrcoef(gapbackdata{i,2,2}(:,1),gapbackdata{i,2,2}(:,2),...
        'rows','complete');
    volgapbackbasecorr = [r(2) p(2)];
    volgapbackcorr = [r2(2) p2(2)];
    
    %shuffle tests
    [pitchgapbackbaseshuff pitchgapbackbaseshuffpval] = ...
        shuffle(gapbackdata{i,1,1}(:,1),gapbackdata{i,1,1}(:,2),shufftrials);
    [pitchgapbackshuff pitchgapbackshuffpval] = ...
        shuffle(gapbackdata{i,2,1}(:,1),gapbackdata{i,2,1}(:,2),shufftrials);
    [volgapbackbaseshuff volgapbackbaseshuffpval] = ...
        shuffle(gapbackdata{i,1,2}(:,1),gapbackdata{i,1,2}(:,2),shufftrials);
    [volgapbackshuff volgapbackshuffpval] = ...
        shuffle(gapbackdata{i,2,2}(:,1),gapbackdata{i,2,2}(:,2),shufftrials);
    
    pitchvolgap_corr = [pitchvolgap_corr; table({birdnm},{num2str(i)},{baselinecondition},...
        {'back'},pitchgapbackbasecorr,volgapbackbasecorr,...
        {pitchgapbackbaseshuff pitchgapbackbaseshuffpval},...
        {volgapbackbaseshuff volgapbackbaseshuffpval},'VariableNames',...
        {'birdname','syllID','condition','gaptype','pitchgap',...
        'volgap','pitchgap_shuff','volgap_shuff'})];
    pitchvolgap_corr = [pitchvolgap_corr; table({birdnm},{num2str(i)},{treatmentcondition},...
        {'back'},pitchgapbackcorr,volgapbackcorr,...
        {pitchgapbackshuff pitchgapbackshuffpval},...
        {volgapbackshuff volgapbackshuffpval},'VariableNames',...
        {'birdname','syllID','condition','gaptype','pitchgap',...
        'volgap','pitchgap_shuff','volgap_shuff'})];
    
    pitchvolgap_tbl = [pitchvolgap_tbl; table(repmat({birdnm},length(gapbackdata{i,1,1}),1),...
        repmat({num2str(i)},length(gapbackdata{i,1,1}),1),...
        repmat({baselinecondition},length(gapbackdata{i,1,1}),1),...
        repmat({'back'},length(gapbackdata{i,1,1}),1),...
        gapbackdata{i,1,1}(:,1),gapbackdata{i,1,2}(:,1),...
        gapbackdata{i,1,1}(:,2),'VariableNames',{'birdname','syllID',...
        'condition','gaptype','pitch','volume','gapdur'})];
    pitchvolgap_tbl = [pitchvolgap_tbl; table(repmat({birdnm},length(gapbackdata{i,2,1}),1),...
        repmat({num2str(i)},length(gapbackdata{i,2,1}),1),...
        repmat({treatmentcondition},length(gapbackdata{i,2,1}),1),...
        repmat({'back'},length(gapbackdata{i,2,1}),1),...
        gapbackdata{i,2,1}(:,1),gapbackdata{i,2,2}(:,1),...
        gapbackdata{i,2,1}(:,2),'VariableNames',{'birdname','syllID',...
        'condition','gaptype','pitch','volume','gapdur'})];
    
end                



%%
function [r p] = shuffle(x,y,shufftrials);
    xshuff = repmat(x',shufftrials,1);
    xshuff = permute_rowel(xshuff);
    [r p] = corrcoef([xshuff',y],'rows','pairwise');
    r = r(1:end-1,end);
    p = p(1:end-1,end);  
end

function shuffmat = permute_rowel(mat);
    %shuffle elements within rows in matrix
    [~,permmat] = sort(rand(size(mat,1),size(mat,2)),2);
    permmat = (permmat-1)*size(mat,1)+ndgrid(1:size(mat,1),1:size(mat,2));
    shuffmat = mat(permmat);
end