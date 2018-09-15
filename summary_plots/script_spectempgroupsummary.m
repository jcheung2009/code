%plots group comparison of spectral and temporal features for each condition
%from all birds in directory
%summary structs are from script_spectempsummary

%% extract information from each bird's spectemp summary
config;
conditions = params.conditions;

batch = uigetfile;
ff = load_batchf(batch);

group_pitch = struct();group_vol = struct();group_ent = struct();group_pcv = struct();
group_motifdur = struct();group_sylldur = struct(); group_gapdur = struct();
group_rep = struct();group_bout = struct();
for n = 1:length(conditions)
    group_pitch = setfield(group_pitch,strrep(conditions{n},' ','_'),cell(2,1));
    group_vol = setfield(group_vol,strrep(conditions{n},' ','_'),cell(2,1));
    group_ent = setfield(group_ent,strrep(conditions{n},' ','_'),cell(2,1));
    group_pcv = setfield(group_pcv,strrep(conditions{n},' ','_'),cell(2,1));
    group_motifdur = setfield(group_motifdur,strrep(conditions{n},' ','_'),cell(2,1));
    group_sylldur = setfield(group_sylldur,strrep(conditions{n},' ','_'),cell(2,1));
    group_gapdur = setfield(group_gapdur,strrep(conditions{n},' ','_'),cell(2,1));
    group_rep = setfield(group_rep,strrep(conditions{n},' ','_'),cell(2,1));
    group_bout = setfield(group_bout,strrep(conditions{n},' ','_'),cell(2,1));
end
for i = 1:length(ff)
    if ~exist(ff(i).name)
        load([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
        birdsummary = eval(['summary_',ff(i).name]);
    else
        try 
            load([ff(i).name,'/analysis/data_structures/summary_',ff(i).name,'_df']);
            birdsummary = eval(['summary_',ff(i).name,'_df']);
        catch
            load([ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
            birdsummary = eval(['summary_',ff(i).name]);
        end
    end
    
   
    if isfield(birdsummary,'spec')
        numsylls = length(fieldnames(birdsummary.spec));
        sylls = fieldnames(birdsummary.spec);
        for indcond = 1:length(conditions)
            for n = 1:numsylls
                ind = find(strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                
                pitch_pvals = [];
                for m = 1:length(ind)
                    pitch_pvals = [pitch_pvals; birdsummary.spec(ind(m)).([sylls{n}]).pitch.pval];
                end
                if sum(pitch_pvals <=0.05) > floor(length(pitch_pvals)/2)
                    pitch = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind(pitch_pvals<=0.05)),'unif',0)'),1);
                    pitch_pval = 0;
                else
                    pitch_pval = 1;
                    pitch = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                
                vol_pvals = [];
                for m = 1:length(ind)
                    vol_pvals = [vol_pvals; birdsummary.spec(ind(m)).([sylls{n}]).vol.pval];
                end
                if sum(vol_pvals <=0.05) > floor(length(vol_pvals)/2)
                    vol = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind(vol_pvals<=0.05)),'unif',0)'),1);
                    vol_pval = 0;
                else
                    vol_pval = 1;
                    vol = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                
                ent_pvals = [];
                for m = 1:length(ind)
                    ent_pvals = [ent_pvals; birdsummary.spec(ind(m)).([sylls{n}]).ent.pval];
                end
                if sum(ent_pvals <=0.05) > floor(length(ent_pvals)/2)
                    ent = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind(ent_pvals<=0.05)),'unif',0)'),1);
                    ent_pval = 0;
                else
                    ent_pval = 1;
                    ent = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                
                pcv_pvals = [];
                for m = 1:length(ind)
                    pcv_pvals = [pcv_pvals; birdsummary.spec(ind(m)).([sylls{n}]).pitchcv.pval];
                end
                if sum(pcv_pvals <=0.05) > floor(length(pcv_pvals)/2)
                    pitchcv = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind(pcv_pvals<=0.05)),'unif',0)'),1);
                    pcv_pval = 0;
                else
                    pcv_pval = 1;
                    pitchcv = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)'),1);
                end

                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),'deaf saline');
                pitch_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)'),1);
                vol_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)'),1);
                ent_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)'),1);
                pitchcv_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)'),1);
                
                group_pitch.(strrep(conditions{indcond},' ','_')){1} = [group_pitch.(strrep(conditions{indcond},' ','_')){1};pitch_sal pitch];
                group_vol.(strrep(conditions{indcond},' ','_')){1} = [group_vol.(strrep(conditions{indcond},' ','_')){1};vol_sal vol];
                group_ent.(strrep(conditions{indcond},' ','_')){1} = [group_ent.(strrep(conditions{indcond},' ','_')){1};ent_sal ent];
                group_pcv.(strrep(conditions{indcond},' ','_')){1} = [group_pcv.(strrep(conditions{indcond},' ','_')){1};pitchcv_sal pitchcv];
                group_pitch.(strrep(conditions{indcond},' ','_')){2} = [group_pitch.(strrep(conditions{indcond},' ','_')){2}; {ff(i).name}];
                group_vol.(strrep(conditions{indcond},' ','_')){2} = [group_vol.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];
                group_ent.(strrep(conditions{indcond},' ','_')){2} = [group_ent.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];
                group_pcv.(strrep(conditions{indcond},' ','_')){2} = [group_pcv.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];  
            end
%             group_pitch.(conditions{indcond}){2} = unique(group_pitch.(conditions{indcond}){2});
%             group_vol.(conditions{indcond}){2} = unique(group_vol.(conditions{indcond}){2});
%             group_ent.(conditions{indcond}){2} = unique(group_ent.(conditions{indcond}){2});
%             group_pcv.(conditions{indcond}){2} = unique(group_pcv.(conditions{indcond}){2});  
        end
    end
    
    if isfield(birdsummary,'temp')
        nummotifs = length(fieldnames(birdsummary.temp));
        motifs = fieldnames(birdsummary.temp);
        for indcond = 1:length(conditions)
            for n = 1:nummotifs
                ind = find(strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),conditions{indcond}));
                ind_sal = strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),'deaf saline');
                if isempty(ind)
                    continue
                end
                
                mdur_pvals = [];
                for m = 1:length(ind)
                    mdur_pvals = [mdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).motifdur.pval];
                end
                if sum(mdur_pvals <=0.05) > floor(length(mdur_pvals)/2)
                    motifdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind(mdur_pvals<=0.05)),'unif',0)'),1);
                    mdur_pval = 0;
                else
                    mdur_pval = 1;
                    motifdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind),'unif',0)'),1);
                end

                motifdur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind_sal),'unif',0)'),1);
                group_motifdur.(strrep(conditions{indcond},' ','_')){1} = [group_motifdur.(strrep(conditions{indcond},' ','_')){1};motifdur_sal motifdur];
                
                numsylls = length(motifs{n});
                for syllind = 1:numsylls
                    sdur_pvals = [];
                    for m = 1:length(ind)
                        sdur_pvals = [sdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).sylldur.pval(syllind)];
                    end
                    if sum(sdur_pvals <=0.05) > floor(length(sdur_pvals)/2)
                        sylldur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind),birdsummary.temp(ind(sdur_pvals<=0.05)),'unif',0)'),1);
                        sdur_pval = 0;
                    else
                        sdur_pval = 1;
                        sylldur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind),birdsummary.temp(ind),'unif',0)'),1);
                    end
                    sylldur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind)',birdsummary.temp(ind_sal),'unif',0)'),1);
                    group_sylldur.(strrep(conditions{indcond},' ','_')){1} = [group_sylldur.(strrep(conditions{indcond},' ','_')){1};sylldur_sal sylldur];
                end
                
                numgaps = numsylls-1;
                for gapind = 1:numgaps
                    gdur_pvals = [];
                    for m = 1:length(ind)
                        gdur_pvals = [gdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).gapdur.pval(gapind)];
                    end
                    if sum(gdur_pvals <=0.05) > floor(length(gdur_pvals)/2)
                        gapdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind),birdsummary.temp(ind(gdur_pvals<=0.05)),'unif',0)'),1);
                        gdur_pval = 0;
                    else
                        gdur_pval = 1;
                        gapdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind),birdsummary.temp(ind),'unif',0)'),1);
                    end
                    gapdur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind)',birdsummary.temp(ind_sal),'unif',0)'),1);
                    group_gapdur.(strrep(conditions{indcond},' ','_')){1} = [group_gapdur.(strrep(conditions{indcond},' ','_')){1};gapdur_sal gapdur];
                end   
                
                group_motifdur.(strrep(conditions{indcond},' ','_')){2} = [group_motifdur.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];
                group_sylldur.(strrep(conditions{indcond},' ','_')){2} = [group_sylldur.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];
                group_gapdur.(strrep(conditions{indcond},' ','_')){2} = [group_gapdur.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];  
            end
        end
%         group_motifdur.(conditions{indcond}){2} = unique( group_motifdur.(conditions{indcond}){2});
%         group_sylldur.(conditions{indcond}){2} = unique(group_sylldur.(conditions{indcond}){2});
%         group_gapdur.(conditions{indcond}){2} = unique(group_gapdur.(conditions{indcond}){2});
        
    end
    
    if isfield(birdsummary,'rep')
        numreps = length(fieldnames(birdsummary.rep));
        reps = fieldnames(birdsummary.rep);
        for indcond = 1:length(conditions)
            for n = 1:numreps
                ind = find(strcmp(arrayfun(@(x) x.([reps{n}]).condition,birdsummary.rep,'unif',0),conditions{indcond}));
                ind_sal = strcmp(arrayfun(@(x) x.([reps{n}]).condition,birdsummary.rep,'unif',0),'deaf saline');
                if isempty(ind)
                    continue
                end
                rep_pvals = [];
                for m = 1:length(ind)
                    rep_pvals = [rep_pvals;birdsummary.rep(ind(m)).([reps{n}]).runlength.pval];
                end
                if sum(rep_pvals <=0.05) > floor(length(rep_pvals)/2)
                    runlength = mean(cell2mat(arrayfun(@(x) [x.([reps{n}]).runlength.percent],birdsummary.rep(ind(rep_pvals<=0.05)),'unif',0)'),1);
                    rep_pval = 0;
                else
                    rep_pval = 1;
                    runlength = mean(cell2mat(arrayfun(@(x) [x.([reps{n}]).runlength.percent],birdsummary.rep(ind),'unif',0)'),1);
                end
                runlength_sal = mean(cell2mat(arrayfun(@(x) x.([reps{n}]).runlength.percent,birdsummary.rep(ind_sal),'unif',0)'),1);
                group_rep.(strrep(conditions{indcond},' ','_')){1} = [group_rep.(strrep(conditions{indcond},' ','_')){1};runlength_sal runlength];
                group_rep.(strrep(conditions{indcond},' ','_')){2} = [group_rep.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];
            end
        end
%         group_rep.(conditions{indcond}){2} =unique(group_rep.(conditions{indcond}){2});
    end
    
    if isfield(birdsummary,'bout')
        numbouts = length(fieldnames(birdsummary.bout));
        bouts = fieldnames(birdsummary.bout);
        for indcond = 1:length(conditions)
            for n = 1:numbouts
                ind = find(strcmp(arrayfun(@(x) x.([bouts{n}]).condition,birdsummary.bout,'unif',0),conditions{indcond}));
                ind_sal = strcmp(arrayfun(@(x) x.([bouts{n}]).condition,birdsummary.bout,'unif',0),'deaf saline');
                if isempty(ind)
                    continue
                end
                bout_pvals = [];
                for m = 1:length(ind)
                    bout_pvals = [bout_pvals;birdsummary.bout(ind(m)).([bouts{n}]).meansingingrate.pval];
                end
                if sum(bout_pvals <=0.05) > floor(length(bout_pvals)/2)
                    meansingingrate = mean(cell2mat(arrayfun(@(x) [x.([bouts{n}]).meansingingrate.percent],birdsummary.bout(ind(bout_pvals<=0.05)),'unif',0)'),1);
                    bout_pvals = 0;
                else
                    bout_pvals = 1;
                    meansingingrate = mean(cell2mat(arrayfun(@(x) [x.([bouts{n}]).meansingingrate.percent],birdsummary.bout(ind),'unif',0)'),1);
                end
                meansingingrate_sal = mean(cell2mat(arrayfun(@(x) x.([bouts{n}]).meansingingrate.percent,birdsummary.bout(ind_sal),'unif',0)'),1);
                group_bout.(strrep(conditions{indcond},' ','_')){1} = [group_bout.(strrep(conditions{indcond},' ','_')){1};meansingingrate_sal meansingingrate];
                group_bout.(strrep(conditions{indcond},' ','_')){2} = [group_bout.(strrep(conditions{indcond},' ','_')){2};{ff(i).name}];
            end       
        end
%         group_bout.(conditions{indcond}){2} = unique(group_bout.(conditions{indcond}){2});
    end
end
%% plot group results for spectral features

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_pitch.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_pitch.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_pitch.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_pitch.(strrep(conditions{n},' ','_')){1}(:,1),group_pitch.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'pitch');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_vol.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_vol.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_vol.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_vol.(strrep(conditions{n},' ','_')){1}(:,1),group_vol.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'volume');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_ent.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_ent.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_ent.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_ent.(strrep(conditions{n},' ','_')){1}(:,1),group_ent.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'entropy');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_pcv.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_pcv.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_pcv.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_pcv.(strrep(conditions{n},' ','_')){1}(:,1),group_pcv.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'pitch variability');

%% plot group temp summary
figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_motifdur.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_motifdur.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_motifdur.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_motifdur.(strrep(conditions{n},' ','_')){1}(:,1),group_motifdur.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'motif duration');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_sylldur.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_sylldur.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_sylldur.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_sylldur.(strrep(conditions{n},' ','_')){1}(:,1),group_sylldur.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'syllable duration');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_gapdur.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_gapdur.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_gapdur.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_gapdur.(strrep(conditions{n},' ','_')){1}(:,1),group_gapdur.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'gap duration');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_rep.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_rep.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    if ~isempty(group_rep.(strrep(conditions{n},' ','_')){1})
        plot(h1,[n-offset n+offset],group_rep.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
        p = signrank(group_rep.(strrep(conditions{n},' ','_')){1}(:,1),group_rep.(strrep(conditions{n},' ','_')){1}(:,2));
        if p <= 0.05
            text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
        end
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'repeat length');

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_bout.(strrep(conditions{n},' ','_')){1}(:,1)) mean(group_bout.(strrep(conditions{n},' ','_')){1}(:,2))];
end
if length(conditions) == 1
    dat = [dat; NaN NaN];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_bout.(strrep(conditions{n},' ','_')){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_bout.(strrep(conditions{n},' ','_')){1}(:,1),group_bout.(strrep(conditions{n},' ','_')){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'singing rate');
%% extract direction and magnitude and significance of change
config;
conditions = params.conditions;

batch = uigetfile;
ff = load_batchf(batch);

group_pitch = struct();group_vol = struct();group_ent = struct();group_pcv = struct();
group_motifdur = struct();group_sylldur = struct(); group_gapdur = struct();
group_rep = struct();group_bout = struct();
for n = 1:length(conditions)
    group_pitch = setfield(group_pitch,conditions{n},cell(2,1));
    group_vol = setfield(group_vol,conditions{n},cell(2,1));
    group_ent = setfield(group_ent,conditions{n},cell(2,1));
    group_pcv = setfield(group_pcv,conditions{n},cell(2,1));
    group_motifdur = setfield(group_motifdur,conditions{n},cell(2,1));
    group_sylldur = setfield(group_sylldur,conditions{n},cell(2,1));
    group_gapdur = setfield(group_gapdur,conditions{n},cell(2,1));
    group_rep = setfield(group_rep,conditions{n},cell(2,1));
    group_bout = setfield(group_bout,conditions{n},cell(2,1));
end
for i = 1:length(ff)
    if ~exist(ff(i).name)
        load([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    else
        load([ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    end
    
    birdsummary = eval(['summary_',ff(i).name]);
    if isfield(birdsummary,'spec')
        numsylls = length(fieldnames(birdsummary.spec));
        sylls = fieldnames(birdsummary.spec);
        for indcond = 1:length(conditions)
            for n = 1:numsylls
                ind = find(strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                pitch_pvals = [];
                for m = 1:length(ind)
                    pitch_pvals = [pitch_pvals; birdsummary.spec(ind(m)).([sylls{n}]).pitch.pval];
                end
                if sum(pitch_pvals <=0.05) > floor(length(pitch_pvals)/2)
                    pitch = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind(pitch_pvals<=0.05)),'unif',0)'),1);
                    pitch_pval = 0;
                else
                    pitch_pval = 1;
                    pitch = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                group_pitch.(conditions{indcond}){1} = [group_pitch.(conditions{indcond}){1};pitch pitch_pval];
                
                vol_pvals = [];
                for m = 1:length(ind)
                    vol_pvals = [vol_pvals; birdsummary.spec(ind(m)).([sylls{n}]).vol.pval];
                end
                if sum(vol_pvals <=0.05) > floor(length(vol_pvals)/2)
                    vol = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind(vol_pvals<=0.05)),'unif',0)'),1);
                    vol_pval = 0;
                else
                    vol_pval = 1;
                    vol = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                group_vol.(conditions{indcond}){1} = [group_vol.(conditions{indcond}){1};vol vol_pval];
                
                ent_pvals = [];
                for m = 1:length(ind)
                    ent_pvals = [ent_pvals; birdsummary.spec(ind(m)).([sylls{n}]).ent.pval];
                end
                if sum(ent_pvals <=0.05) > floor(length(ent_pvals)/2)
                    ent = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind(ent_pvals<=0.05)),'unif',0)'),1);
                    ent_pval = 0;
                else
                    ent_pval = 1;
                    ent = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                group_ent.(conditions{indcond}){1} = [group_ent.(conditions{indcond}){1};ent ent_pval];
                
                pcv_pvals = [];
                for m = 1:length(ind)
                    pcv_pvals = [pcv_pvals; birdsummary.spec(ind(m)).([sylls{n}]).pitchcv.pval];
                end
                if sum(pcv_pvals <=0.05) > floor(length(pcv_pvals)/2)
                    pcv = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind(pcv_pvals<=0.05)),'unif',0)'),1);
                    pcv_pval = 0;
                else
                    pcv_pval = 1;
                    pcv = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)'),1);
                end
                group_pcv.(conditions{indcond}){1} = [group_pcv.(conditions{indcond}){1};pcv pcv_pval];

                group_pitch.(conditions{indcond}){2} = [group_pitch.(conditions{indcond}){2}; {ff(i).name}];
                group_vol.(conditions{indcond}){2} = [group_vol.(conditions{indcond}){2};{ff(i).name}];
                group_ent.(conditions{indcond}){2} = [group_ent.(conditions{indcond}){2};{ff(i).name}];
                group_pcv.(conditions{indcond}){2} = [group_pcv.(conditions{indcond}){2};{ff(i).name}];  
            end
        end
    end
    if isfield(birdsummary,'temp')
        nummotifs = length(fieldnames(birdsummary.temp));
        motifs = fieldnames(birdsummary.temp);
        for indcond = 1:length(conditions)
            for n = 1:nummotifs
                ind = find(strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                mdur_pvals = [];
                for m = 1:length(ind)
                    mdur_pvals = [mdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).motifdur.pval];
                end
                if sum(mdur_pvals <=0.05) > floor(length(mdur_pvals)/2)
                    motifdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind(mdur_pvals<=0.05)),'unif',0)'),1);
                    mdur_pval = 0;
                else
                    mdur_pval = 1;
                    motifdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind),'unif',0)'),1);
                end
                group_motifdur.(conditions{indcond}){1} = [group_motifdur.(conditions{indcond}){1}; motifdur mdur_pval];
                
                numsylls = length(motifs{n});
                for syllind = 1:numsylls
                    sdur_pvals = [];
                    for m = 1:length(ind)
                        sdur_pvals = [sdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).sylldur.pval(syllind)];
                    end
                    if sum(sdur_pvals <=0.05) > floor(length(sdur_pvals)/2)
                        sylldur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind),birdsummary.temp(ind(sdur_pvals<=0.05)),'unif',0)'),1);
                        sdur_pval = 0;
                    else
                        sdur_pval = 1;
                        sylldur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind),birdsummary.temp(ind),'unif',0)'),1);
                    end
                    group_sylldur.(conditions{indcond}){1} = [group_sylldur.(conditions{indcond}){1};sylldur sdur_pval];
                    group_sylldur.(conditions{indcond}){2} = [group_sylldur.(conditions{indcond}){2};{ff(i).name}];
                end
                
                numgaps = numsylls-1;
                for gapind = 1:numgaps
                    gdur_pvals = [];
                    for m = 1:length(ind)
                        gdur_pvals = [gdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).gapdur.pval(gapind)];
                    end
                    if sum(gdur_pvals <=0.05) > floor(length(gdur_pvals)/2)
                        gapdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind),birdsummary.temp(ind(gdur_pvals<=0.05)),'unif',0)'),1);
                        gdur_pval = 0;
                    else
                        gdur_pval = 1;
                        gapdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind),birdsummary.temp(ind),'unif',0)'),1);
                    end
                    group_gapdur.(conditions{indcond}){1} = [group_gapdur.(conditions{indcond}){1};gapdur gdur_pval];
                    group_gapdur.(conditions{indcond}){2} = [group_gapdur.(conditions{indcond}){2};{ff(i).name}];  
                end   
                group_motifdur.(conditions{indcond}){2} = [group_motifdur.(conditions{indcond}){2};{ff(i).name}];
            end
        end
    end
    if isfield(birdsummary,'rep')
        numreps = length(fieldnames(birdsummary.rep));
        reps = fieldnames(birdsummary.rep);
        for indcond = 1:length(conditions)
            for n = 1:numreps
                ind = find(strcmp(arrayfun(@(x) x.([reps{n}]).condition,birdsummary.rep,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                rep_pvals = [];
                for m = 1:length(ind)
                    rep_pvals = [rep_pvals;birdsummary.rep(ind(m)).([reps{n}]).runlength.pval];
                end
                if sum(rep_pvals <=0.05) > floor(length(rep_pvals)/2)
                    runlength = mean(cell2mat(arrayfun(@(x) [x.([reps{n}]).runlength.percent],birdsummary.rep(ind(rep_pvals<=0.05)),'unif',0)'),1);
                    rep_pval = 0;
                else
                    rep_pval = 1;
                    runlength = mean(cell2mat(arrayfun(@(x) [x.([reps{n}]).runlength.percent],birdsummary.rep(ind),'unif',0)'),1);
                end
                group_rep.(conditions{indcond}){1} = [group_rep.(conditions{indcond}){1};runlength rep_pval];
                group_rep.(conditions{indcond}){2} = [group_rep.(conditions{indcond}){2};{ff(i).name}];
            end
        end
    end
    
    if isfield(birdsummary,'bout')
        numbouts = length(fieldnames(birdsummary.bout));
        bouts = fieldnames(birdsummary.bout);
        for indcond = 1:length(conditions)
            for n = 1:numbouts
                ind = find(strcmp(arrayfun(@(x) x.([bouts{n}]).condition,birdsummary.bout,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                bout_pvals = [];
                for m = 1:length(ind)
                    bout_pvals = [bout_pvals;birdsummary.bout(ind(m)).([bouts{n}]).meansingingrate.pval];
                end
                if sum(bout_pvals <=0.05) > floor(length(bout_pvals)/2)
                    meansingingrate = mean(cell2mat(arrayfun(@(x) [x.([bouts{n}]).meansingingrate.percent],birdsummary.bout(ind(bout_pvals<=0.05)),'unif',0)'),1);
                    bout_pvals = 0;
                else
                    bout_pvals = 1;
                    meansingingrate = mean(cell2mat(arrayfun(@(x) [x.([bouts{n}]).meansingingrate.percent],birdsummary.bout(ind),'unif',0)'),1);
                end
                
                group_bout.(conditions{indcond}){1} = [group_bout.(conditions{indcond}){1}; meansingingrate bout_pvals];
                group_bout.(conditions{indcond}){2} = [group_bout.(conditions{indcond}){2};{ff(i).name}];
            end       
        end
    end
end
%% chi2 test of gap and syll duration 

% test whether proportion of syllables with decrease is less than
% proportion of gaps with decrease 

    n1 = 27;%syllables with decrease
    n2 = 28;%gaps with decrease
    N1 = 43;%sylls with significant change
    N2 = 34;%gaps with significant change

    %pooled estimate of proportion
    p0 = (n1+n2)/(N1+N2);

    %expected counts under Ho
    n10 = N1*p0;
    n20 = N2*p0;

    %chisquare test
    observed = [n1 N1-n1 n2 N2-n2];
    expected = [n10 N1-n10 n20 N2-n20];
    chi2stat = sum((observed-expected).^2./expected);
    p = 1-chi2cdf(chi2stat,1)

    
% test whether proportion of gaps with decrease is more than proportion of
% gaps with increase 
    
    n1 = 28;%gaps with decrease
    n2 = 6;%gaps with increase
    N1 = 34;%gaps with significant change
    N2 = 34;%gaps with significant change

    %pooled estimate of proportion
    p0 = (n1+n2)/(N1+N2);

    %expected counts under Ho
    n10 = N1*p0;
    n20 = N2*p0;

    %chisquare test
    observed = [n1 N1-n1 n2 N2-n2];
    expected = [n10 N1-n10 n20 N2-n20];
    chi2stat = sum((observed-expected).^2./expected);
    p = 1-chi2cdf(chi2stat,1)

% test whether proportion of sylls with decrease is less than proportion of
% sylls with increase 
    
    n1 = 27;%sylls with decrease
    n2 = 16;%sylls with increase
    N1 = 43;%sylls with significant change
    N2 = 43;%sylls with significant change

    %pooled estimate of proportion
    p0 = (n1+n2)/(N1+N2);

    %expected counts under Ho
    n10 = N1*p0;
    n20 = N2*p0;

    %chisquare test
    observed = [n1 N1-n1 n2 N2-n2];
    expected = [n10 N1-n10 n20 N2-n20];
    chi2stat = sum((observed-expected).^2./expected);
    p = 1-chi2cdf(chi2stat,1)
  
%test whether more syllables or gaps have a significant change
    n1 = 43;%sylls with change
    n2 = 34;%gaps with change
    N1 = 73;%sylls 
    N2 = 57;%gaps

    %pooled estimate of proportion
    p0 = (n1+n2)/(N1+N2);

    %expected counts under Ho
    n10 = N1*p0;
    n20 = N2*p0;

    %chisquare test
    observed = [n1 N1-n1 n2 N2-n2];
    expected = [n10 N1-n10 n20 N2-n20];
    chi2stat = sum((observed-expected).^2./expected);
    p = 1-chi2cdf(chi2stat,1)
%% correlate experiment changes in pitch, volume, motifdur, repeats and singing rate across birds
pitch_vol_motifdur_rep_bout = [];
config;
for i = 1:length(ff)
    birdsummary = eval(['summary_',ff(i).name]);
    
    trialnms = {};
    for indcond = 1:length(conditions)
        sylls = fieldnames(birdsummary.spec);
        ind = strcmp(arrayfun(@(x) x.([sylls{1}]).condition,birdsummary.spec,'unif',0),conditions{indcond});
        if isempty(find(ind))
            continue
        end
        trialnms = [trialnms; arrayfun(@(x) x.([sylls{1}]).trialname,birdsummary.spec(ind),'unif',0)];
    end
    
    if isfield(birdsummary,'spec')
        numsylls = length(fieldnames(birdsummary.spec));
        sylls = fieldnames(birdsummary.spec);
        pitch=[];vol = [];
        for n = 1:numsylls
            p1 = []; v1 = [];
            for m = 1:length(trialnms)
                idx = find(strcmp(arrayfun(@(x) x.([sylls{n}]).trialname,birdsummary.spec,'unif',0),trialnms{m}));
                p1 = [p1; birdsummary.spec(idx).([sylls{n}]).pitch.percent];
                v1 = [v1; birdsummary.spec(idx).([sylls{n}]).vol.percent];
            end
            pitch = [pitch p1];
            vol = [vol v1];
        end
    end
    
    if isfield(birdsummary,'temp')
        nummotifs = length(fieldnames(birdsummary.temp));
        motifs = fieldnames(birdsummary.temp); 
        mdur = [];
        for n = 1:nummotifs
            m1 = [];
            for m = 1:length(trialnms)
                idx = find(strcmp(arrayfun(@(x) x.([motifs{n}]).trialname,birdsummary.temp,'unif',0),trialnms{m}));
                m1 = [m1;birdsummary.temp(idx).([motifs{n}]).motifdur.percent];
            end
            mdur = [mdur m1];
        end
    end
               
    if isfield(birdsummary,'rep')
        numreps = length(fieldnames(birdsummary.rep));
        reps = fieldnames(birdsummary.rep);
        rep = [];
        for n = 1:numreps
            r1 = [];
            for m = 1:length(trialnms)
                idx = find(strcmp(arrayfun(@(x) x.([reps{n}]).trialname,birdsummary.rep,'unif',0),trialnms{m}));
                r1 = [r1; birdsummary.rep(idx).([reps{n}]).runlength.percent];
            end
            rep = [rep r1];
        end
    else
        rep = NaN(size(pitch,1),1);
    end

    if isfield(birdsummary,'bout')
        numbouts = length(fieldnames(birdsummary.bout));
        bouts = fieldnames(birdsummary.bout);
        bout = [];
        for n = 1:numbouts
            for m = 1:length(trialnms)
                idx = find(strcmp(arrayfun(@(x) x.([bouts{n}]).trialname,birdsummary.bout,'unif',0),trialnms{m}));
                bout = [bout;birdsummary.bout(idx).([bouts{n}]).maxsingingrate.percent];
            end
        end
    end
    pitch_vol_motifdur_rep_bout = [pitch_vol_motifdur_rep_bout; mean(pitch,2) mean(vol,2) mean(mdur,2) mean(rep,2) mean(bout,2)];
end




figure;hold on;
plot(pitch_vol_motifdur_rep_bout(:,1),pitch_vol_motifdur_rep_bout(:,3),'k.');
xlabel('pitch');ylabel('motifdur');
set(gca,'fontweight','bold');
[r p] = corrcoef(pitch_vol_motifdur_rep_bout(:,1),pitch_vol_motifdur_rep_bout(:,3),'rows','complete');
text(0,0.95,['p=',num2str(p(2))],'units','normalized','fontweight','bold');
h = lsline;
set(h,'color',[0.5 0.5 0.5],'linewidth',2);

figure;hold on;
plot(pitch_vol_motifdur_rep_bout(:,2),pitch_vol_motifdur_rep_bout(:,3),'k.');
xlabel('volume');ylabel('motifdur');
set(gca,'fontweight','bold');
[r p] = corrcoef(pitch_vol_motifdur_rep_bout(:,2),pitch_vol_motifdur_rep_bout(:,3),'rows','complete');
text(0,0.95,['p=',num2str(p(2))],'units','normalized','fontweight','bold');
h = lsline;
set(h,'color',[0.5 0.5 0.5],'linewidth',2);

figure;hold on;
plot(pitch_vol_motifdur_rep_bout(:,1),pitch_vol_motifdur_rep_bout(:,4),'k.');
xlabel('pitch');ylabel('rep');
set(gca,'fontweight','bold');
[r p] = corrcoef(pitch_vol_motifdur_rep_bout(:,1),pitch_vol_motifdur_rep_bout(:,4),'rows','complete');
text(0,0.95,['p=',num2str(p(2))],'units','normalized','fontweight','bold');
h = lsline;
set(h,'color',[0.5 0.5 0.5],'linewidth',2);

figure;hold on;
plot(pitch_vol_motifdur_rep_bout(:,2),pitch_vol_motifdur_rep_bout(:,4),'k.');
xlabel('volume');ylabel('rep');
set(gca,'fontweight','bold');
[r p] = corrcoef(pitch_vol_motifdur_rep_bout(:,2),pitch_vol_motifdur_rep_bout(:,4),'rows','complete');
text(0,0.95,['p=',num2str(p(2))],'units','normalized','fontweight','bold');
h = lsline;
set(h,'color',[0.5 0.5 0.5],'linewidth',2);

figure;hold on;
plot(pitch_vol_motifdur_rep_bout(:,1),pitch_vol_motifdur_rep_bout(:,5),'k.');
xlabel('pitch');ylabel('bout');
set(gca,'fontweight','bold');
[r p] = corrcoef(pitch_vol_motifdur_rep_bout(:,1),pitch_vol_motifdur_rep_bout(:,5),'rows','complete');
text(0,0.95,['p=',num2str(p(2))],'units','normalized','fontweight','bold');
h = lsline;
set(h,'color',[0.5 0.5 0.5],'linewidth',2);

figure;hold on;
plot(pitch_vol_motifdur_rep_bout(:,2),pitch_vol_motifdur_rep_bout(:,5),'k.');
xlabel('volume');ylabel('bout');    
set(gca,'fontweight','bold');
[r p] = corrcoef(pitch_vol_motifdur_rep_bout(:,2),pitch_vol_motifdur_rep_bout(:,5),'rows','complete');
text(0,0.95,['p=',num2str(p(2))],'units','normalized','fontweight','bold');
h = lsline;
set(h,'color',[0.5 0.5 0.5],'linewidth',2);
