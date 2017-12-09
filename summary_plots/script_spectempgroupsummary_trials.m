%group summary plotting each trial

%% extract information from each bird's spectemp summary
config;
conditions = params.conditions;
salinecomp = 'saline';

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
                    pitch = cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)');
                end
                
                vol_pvals = [];
                for m = 1:length(ind)
                    vol_pvals = [vol_pvals; birdsummary.spec(ind(m)).([sylls{n}]).vol.pval];
                    vol = cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)');
                end
                
                ent_pvals = [];
                for m = 1:length(ind)
                    ent_pvals = [ent_pvals; birdsummary.spec(ind(m)).([sylls{n}]).ent.pval];
                    ent = cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)');
                end
                
                pcv_pvals = [];
                for m = 1:length(ind)
                    pcv_pvals = [pcv_pvals; birdsummary.spec(ind(m)).([sylls{n}]).pitchcv.pval];
                    pitchcv = cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)');
                end

                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),salinecomp);
                pitch_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.spec(ind),'unif',0)'),1);
                vol_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.percent,birdsummary.spec(ind),'unif',0)'),1);
                ent_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.percent,birdsummary.spec(ind),'unif',0)'),1);
                pitchcv_sal = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.percent,birdsummary.spec(ind),'unif',0)'),1);
                
                group_pitch.(strrep(conditions{indcond},' ','_')){1} = [group_pitch.(strrep(conditions{indcond},' ','_')){1};repmat(pitch_sal,length(pitch),1) pitch];
                group_vol.(strrep(conditions{indcond},' ','_')){1} = [group_vol.(strrep(conditions{indcond},' ','_')){1};repmat(vol_sal,length(vol),1) vol];
                group_ent.(strrep(conditions{indcond},' ','_')){1} = [group_ent.(strrep(conditions{indcond},' ','_')){1};repmat(ent_sal,length(ent),1) ent];
                group_pcv.(strrep(conditions{indcond},' ','_')){1} = [group_pcv.(strrep(conditions{indcond},' ','_')){1};repmat(pitchcv_sal,length(pitchcv),1) pitchcv];
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
                ind_sal = strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),salinecomp);
                if isempty(ind)
                    continue
                end
                
                mdur_pvals = [];
                for m = 1:length(ind)
                    mdur_pvals = [mdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).motifdur.pval];
                    motifdur = cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind),'unif',0)');
                end

                motifdur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.percent,birdsummary.temp(ind_sal),'unif',0)'),1);
                group_motifdur.(strrep(conditions{indcond},' ','_')){1} = [group_motifdur.(strrep(conditions{indcond},' ','_')){1};repmat(motifdur_sal,length(motifdur),1) motifdur];
                
                numsylls = length(motifs{n});
                for syllind = 1:numsylls
                    sdur_pvals = [];
                    for m = 1:length(ind)
                        sdur_pvals = [sdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).sylldur.pval(syllind)];
                        sylldur = cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind),birdsummary.temp(ind),'unif',0)');
                    end
                   
                    sylldur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.percent(syllind)',birdsummary.temp(ind_sal),'unif',0)'),1);
                    group_sylldur.(strrep(conditions{indcond},' ','_')){1} = [group_sylldur.(strrep(conditions{indcond},' ','_')){1};repmat(sylldur_sal,length(sylldur),1) sylldur];
                end
                
                numgaps = numsylls-1;
                for gapind = 1:numgaps
                    gdur_pvals = [];
                    for m = 1:length(ind)
                        gdur_pvals = [gdur_pvals;birdsummary.temp(ind(m)).([motifs{n}]).gapdur.pval(gapind)];
                        gapdur = cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind),birdsummary.temp(ind),'unif',0)');
                    end
                    
                    gapdur_sal = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.percent(gapind)',birdsummary.temp(ind_sal),'unif',0)'),1);
                    group_gapdur.(strrep(conditions{indcond},' ','_')){1} = [group_gapdur.(strrep(conditions{indcond},' ','_')){1};repmat(gapdur_sal,length(gapdur),1) gapdur];
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