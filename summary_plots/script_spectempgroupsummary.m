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
                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),conditions{indcond});
                if isempty(find(ind))
                    continue
                end
                pitch = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)'),1);
                vol = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)'),1);
                ent = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)'),1);
                pitchcv = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)'),1);

                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),'saline');
                pitch_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)'),1);
                vol_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)'),1);
                ent_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)'),1);
                pitchcv_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)'),1);
                
                group_pitch.(conditions{indcond}){1} = [group_pitch.(conditions{indcond}){1};pitch_sal pitch];
                group_vol.(conditions{indcond}){1} = [group_vol.(conditions{indcond}){1};vol_sal vol];
                group_ent.(conditions{indcond}){1} = [group_ent.(conditions{indcond}){1};ent_sal ent];
                group_pcv.(conditions{indcond}){1} = [group_pcv.(conditions{indcond}){1};pitchcv_sal pitchcv];
                group_pitch.(conditions{indcond}){2} = [group_pitch.(conditions{indcond}){2}; {ff(i).name}];
                group_vol.(conditions{indcond}){2} = [group_vol.(conditions{indcond}){2};{ff(i).name}];
                group_ent.(conditions{indcond}){2} = [group_ent.(conditions{indcond}){2};{ff(i).name}];
                group_pcv.(conditions{indcond}){2} = [group_pcv.(conditions{indcond}){2};{ff(i).name}];  
            end
            group_pitch.(conditions{indcond}){2} = unique(group_pitch.(conditions{indcond}){2});
            group_vol.(conditions{indcond}){2} = unique(group_vol.(conditions{indcond}){2});
            group_ent.(conditions{indcond}){2} = unique(group_ent.(conditions{indcond}){2});
            group_pcv.(conditions{indcond}){2} = unique(group_pcv.(conditions{indcond}){2});  
        end
    end
    
    if isfield(birdsummary,'temp')
        nummotifs = length(fieldnames(birdsummary.temp));
        motifs = fieldnames(birdsummary.temp);
        for indcond = 1:length(conditions)
            for n = 1:nummotifs
                ind = strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),conditions{indcond});
                ind_sal = strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),'saline');
                if isempty(find(ind))
                    continue
                end
                motifdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind),'unif',0)'),1);
                motifdur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind_sal),'unif',0)'),1);
                group_motifdur.(conditions{indcond}){1} = [group_motifdur.(conditions{indcond}){1};motifdur_sal motifdur];
                
                numsylls = length(motifs{n});
                for syllind = 1:numsylls
                    sylldur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind)',birdsummary.temp(ind),'unif',0)'),1);
                    sylldur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind)',birdsummary.temp(ind_sal),'unif',0)'),1);
                    group_sylldur.(conditions{indcond}){1} = [group_sylldur.(conditions{indcond}){1};sylldur_sal sylldur];
                end
                
                numgaps = numsylls-1;
                for gapind = 1:numgaps
                    gapdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind)',birdsummary.temp(ind),'unif',0)'),1);
                    gapdur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind)',birdsummary.temp(ind_sal),'unif',0)'),1);
                    group_gapdur.(conditions{indcond}){1} = [group_gapdur.(conditions{indcond}){1};gapdur_sal gapdur];
                    
                end   
                
                group_motifdur.(conditions{indcond}){2} = [group_motifdur.(conditions{indcond}){2};{ff(i).name}];
                group_sylldur.(conditions{indcond}){2} = [group_sylldur.(conditions{indcond}){2};{ff(i).name}];
                group_gapdur.(conditions{indcond}){2} = [group_gapdur.(conditions{indcond}){2};{ff(i).name}];  
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
                ind = strcmp(arrayfun(@(x) x.([reps{n}]).condition,birdsummary.rep,'unif',0),conditions{indcond});
                ind_sal = strcmp(arrayfun(@(x) x.([reps{n}]).condition,birdsummary.rep,'unif',0),'saline');
                if isempty(find(ind))
                    continue
                end
                runlength = mean(cell2mat(arrayfun(@(x) x.([reps{n}]).runlength.percent,birdsummary.rep(ind),'unif',0)'),1);
                runlength_sal = mean(cell2mat(arrayfun(@(x) x.([reps{n}]).runlength.percent,birdsummary.rep(ind_sal),'unif',0)'),1);
                group_rep.(conditions{indcond}){1} = [group_rep.(conditions{indcond}){1};runlength_sal runlength];
                group_rep.(conditions{indcond}){2} = [group_rep.(conditions{indcond}){2};{ff(i).name}];
            end
        end
        group_rep.(conditions{indcond}){2} =unique(group_rep.(conditions{indcond}){2});
    end
    
    if isfield(birdsummary,'bout')
        numbouts = length(fieldnames(birdsummary.bout));
        bouts = fieldnames(birdsummary.bout);
        for indcond = 1:length(conditions)
            for n = 1:numbouts
                ind = strcmp(arrayfun(@(x) x.([bouts{n}]).condition,birdsummary.bout,'unif',0),conditions{indcond});
                ind_sal = strcmp(arrayfun(@(x) x.([bouts{n}]).condition,birdsummary.bout,'unif',0),'saline');
                if isempty(find(ind))
                    continue
                end
                meansingingrate = mean(cell2mat(arrayfun(@(x) x.([bouts{n}]).meansingingrate.percent,birdsummary.bout(ind),'unif',0)'),1);
                meansingingrate_sal = mean(cell2mat(arrayfun(@(x) x.([bouts{n}]).meansingingrate.percent,birdsummary.bout(ind_sal),'unif',0)'),1);
                group_bout.(conditions{indcond}){1} = [group_bout.(conditions{indcond}){1};meansingingrate_sal meansingingrate];
                group_bout.(conditions{indcond}){2} = [group_bout.(conditions{indcond}){2};{ff(i).name}];
            end       
        end
        group_bout.(conditions{indcond}){2} = unique(group_bout.(conditions{indcond}){2});
    end
end
%% plot group results for spectral features

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_pitch.(conditions{n}){1}(:,1)) mean(group_pitch.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_pitch.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_pitch.(conditions{n}){1}(:,1),group_pitch.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_vol.(conditions{n}){1}(:,1)) mean(group_vol.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_vol.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_vol.(conditions{n}){1}(:,1),group_vol.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_ent.(conditions{n}){1}(:,1)) mean(group_ent.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_ent.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_ent.(conditions{n}){1}(:,1),group_ent.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_pcv.(conditions{n}){1}(:,1)) mean(group_pcv.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_pcv.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_pcv.(conditions{n}){1}(:,1),group_pcv.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_motifdur.(conditions{n}){1}(:,1)) mean(group_motifdur.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_motifdur.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_motifdur.(conditions{n}){1}(:,1),group_motifdur.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_sylldur.(conditions{n}){1}(:,1)) mean(group_sylldur.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_sylldur.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_sylldur.(conditions{n}){1}(:,1),group_sylldur.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_gapdur.(conditions{n}){1}(:,1)) mean(group_gapdur.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_gapdur.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_gapdur.(conditions{n}){1}(:,1),group_gapdur.(conditions{n}){1}(:,2));
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
    if ~isempty(group_rep.(conditions{n}){1})
        dat = [dat;mean(group_rep.(conditions{n}){1}(:,1)) mean(group_rep.(conditions{n}){1}(:,2))];
    else
        dat = [dat;NaN NaN];
    end
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    if ~isempty(group_rep.(conditions{n}){1})
        plot(h1,[n-offset n+offset],group_rep.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
        p = signrank(group_rep.(conditions{n}){1}(:,1),group_rep.(conditions{n}){1}(:,2));
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
    dat = [dat;mean(group_bout.(conditions{n}){1}(:,1)) mean(group_bout.(conditions{n}){1}(:,2))];
end
b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    plot(h1,[n-offset n+offset],group_bout.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_bout.(conditions{n}){1}(:,1),group_bout.(conditions{n}){1}(:,2));
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
                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),conditions{indcond});
                if isempty(find(ind))
                    continue
                end
                pitch = mean(cell2mat(arrayfun(@(x) [x.([sylls{n}]).pitch.percent x.([sylls{n}]).pitch.pval],birdsummary.spec(ind),'unif',0)'),1);
                vol = mean(cell2mat(arrayfun(@(x) [x.([sylls{n}]).vol.percent x.([sylls{n}]).vol.pval],birdsummary.spec(ind),'unif',0)'),1);
                ent = mean(cell2mat(arrayfun(@(x) [x.([sylls{n}]).ent.percent x.([sylls{n}]).ent.pval],birdsummary.spec(ind),'unif',0)'),1);
                pitchcv = mean(cell2mat(arrayfun(@(x) [x.([sylls{n}]).pitchcv.percent x.([sylls{n}]).pitchcv.pval],birdsummary.spec(ind),'unif',0)'),1);
                
                group_pitch.(conditions{indcond}){1} = [group_pitch.(conditions{indcond}){1};pitch];
                group_vol.(conditions{indcond}){1} = [group_vol.(conditions{indcond}){1};vol];
                group_ent.(conditions{indcond}){1} = [group_ent.(conditions{indcond}){1};ent];
                group_pcv.(conditions{indcond}){1} = [group_pcv.(conditions{indcond}){1};pitchcv];
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
                ind = strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),conditions{indcond});
                if isempty(find(ind))
                    continue
                end
                motifdur = mean(cell2mat(arrayfun(@(x) [x.([motifs{n}]).motifdur.percent x.([motifs{n}]).motifdur.pval],birdsummary.temp(ind),'unif',0)'),1);
                group_motifdur.(conditions{indcond}){1} = [group_motifdur.(conditions{indcond}){1}; motifdur];
                
                numsylls = length(motifs{n});
                for syllind = 1:numsylls
                    sylldur = mean(cell2mat(arrayfun(@(x) [x.([motifs{n}]).sylldur.percent(syllind) x.([motifs{n}]).sylldur.pval(syllind)] ,birdsummary.temp(ind),'unif',0)'),1);
                    group_sylldur.(conditions{indcond}){1} = [group_sylldur.(conditions{indcond}){1};sylldur];
                    group_sylldur.(conditions{indcond}){2} = [group_sylldur.(conditions{indcond}){2};{ff(i).name}];
                end
                
                numgaps = numsylls-1;
                for gapind = 1:numgaps
                    gapdur = mean(cell2mat(arrayfun(@(x) [x.([motifs{n}]).gapdur.percent(gapind) x.([motifs{n}]).gapdur.pval(gapind)],birdsummary.temp(ind),'unif',0)'),1);
                    group_gapdur.(conditions{indcond}){1} = [group_gapdur.(conditions{indcond}){1};gapdur];
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
                if isempty(find(ind))
                    continue
                end
                rep_pvals = [];
                for m = 1:length(ind)
                    rep_pvals = [rep_pvals;birdsummary.rep(ind(m)).([reps{n}]).runlength.pval];
                end
                if sum(rep_pvals <=0.05) >= floor(length(rep_pvals)/2)
                    rep_pval = 0;
                else
                    rep_pval = 1;
                end
                runlength = mean(cell2mat(arrayfun(@(x) [x.([reps{n}]).runlength.percent],birdsummary.rep(ind),'unif',0)'),1);
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
                if isempty(find(ind))
                    continue
                end
                bout_pvals = [];
                for m = 1:length(ind)
                    bout_pvals = [bout_pvals;birdsummary.bout(ind(m)).([bouts{n}]).meansingingrate.pval];
                end
                if sum(bout_pvals <=0.05) >= floor(length(bout_pvals)/2)
                    bout_pvals = 0;
                else
                    bout_pvals = 1;
                end
                meansingingrate = mean(cell2mat(arrayfun(@(x) [x.([bouts{n}]).meansingingrate.percent],birdsummary.bout(ind),'unif',0)'),1);
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
