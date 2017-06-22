%plots pitch error morning before and after for naspm 
%summary structs are from script_ploterrorsummary

%% extract information from each bird's summary
config;
conditions = params.conditions;

batch = uigetfile;
ff = load_batchf(batch);

group = [];
for n = 1:length(conditions)
    group = setfield(group,conditions{n},cell(2,1));
end

for i = 1:length(ff)
    if ~exist(ff(i).name)
        load([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    else
        load([ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    end
    
    birdsummary = eval(['summary_',ff(i).name]);
    if isfield(birdsummary,'error')
        numsylls = length(fieldnames(birdsummary.error));
        sylls = fieldnames(birdsummary.error);
        for indcond = 1:length(conditions)
            for n = 1:numsylls
                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.error,'unif',0),conditions{indcond});
                if isempty(find(ind))
                    continue
                end
                ind_sal = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.error,'unif',0),'saline');
                pitchchange = nanmean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.error(ind),'unif',0)'),1);
                pitchchange_sal = nanmean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.percent,birdsummary.error(ind_sal),'unif',0)'),1);
                group.(conditions{indcond}){1} = [group.(conditions{indcond}){1}; pitchchange_sal pitchchange];
                group.(conditions{indcond}){2} = [group.(conditions{indcond}){2};{ff(i).name}];
            end
        end
    end
end
%% plot group results 

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    if ~isempty(group.(conditions{n}){1})
        dat = [dat;mean(group.(conditions{n}){1}(:,1)) mean(group.(conditions{n}){1}(:,2))];
    end
end

b = bar(h1,dat);
b(1).FaceColor = 'none';b(1).LineWidth = 2;
b(2).FaceColor = 'none';b(2).EdgeColor = 'r';b(2).LineWidth=2;
offset = b(2).XOffset;
set(h1,'xlim',[0.5 length(conditions)+0.5]);
axes(h1);hold on;
for n = 1:length(conditions)
    if ~isempty(group.(conditions{n}){1})
        plot(h1,[n-offset n+offset],group.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
        p = signrank(group.(conditions{n}){1}(:,1),group.(conditions{n}){1}(:,2));
        if p <= 0.05
            text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
        end
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'pitch');
                    
%% extract effect during naspm with effect on morning pitch

group_cov = [];
for n = 1:length(conditions)
    group_cov = setfield(group_cov,conditions{n},cell(2,1));
end

for i = 1:length(ff)
    if ~exist(ff(i).name)
        load([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    else
        load([ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    end
    
    birdsummary = eval(['summary_',ff(i).name]);
    if isfield(birdsummary,'error')
        numsylls = length(fieldnames(birdsummary.error));
        sylls = fieldnames(birdsummary.error);
        for indcond = 1:length(conditions)
            for n = 1:numsylls
                ind = find(strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.error,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                for m = 1:length(ind)
                    trialname = birdsummary.error(ind(m)).([sylls{n}]).trialname;
                    ind2 = find(strcmp(arrayfun(@(x) x.([sylls{n}]).trialname,birdsummary.spec,'unif',0),trialname));
                    pitch_cond_change = birdsummary.spec(ind2).([sylls{n}]).pitch.percent;
                    pitchchange = birdsummary.error(ind(m)).([sylls{n}]).pitch.percent;
                    group_cov.(conditions{indcond}){1} = [group_cov.(conditions{indcond}){1}; pitch_cond_change pitchchange];
                end
                group_cov.(conditions{indcond}){2} = [group_cov.(conditions{indcond}){2};{ff(i).name}];
            end
        end
    end
end
figure;hold on;
plot(group_cov.naspm{1}(:,1),group_cov.naspm{1}(:,2),'k.');hold on;
x=get(gca,'xlim');y=get(gca,'ylim');
plot(x,[0 0],'--','color',[0.5 0.5 0.5]);hold on;
plot([0 0],y,'--','color',[0.5 0.5 0.5]);hold on;
set(gca,'fontweight','bold');
xlabel('\Delta NASPM (percent)');ylabel('\Delta pre vs post (percent)');
title('pitch');