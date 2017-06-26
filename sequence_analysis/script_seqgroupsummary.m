%% extract information from each bird's spectemp summary
config;
conditions = params.conditions;

batch = uigetfile;
ff = load_batchf(batch);

group_seqent = struct();
for n = 1:length(conditions)
    group_seqent = setfield(group_seqent,conditions{n},cell(2,1));
end
for i = 1:length(ff)
    if ~exist(ff(i).name)
        load([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    else
        load([ff(i).name,'/analysis/data_structures/summary_',ff(i).name]);
    end
    birdsummary = eval(['summary_',ff(i).name]);
    if isfield(birdsummary,'seq')
        numtrans = length(fieldnames(birdsummary.seq));
        trans = fieldnames(birdsummary.seq);
        for indcond = 1:length(conditions)
            for n = 1:numtrans
                ind = find(strcmp(arrayfun(@(x) x.([trans{n}]).condition,birdsummary.seq,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
               seqent = arrayfun(@(x) 100*(x.([trans{n}]).seq_entropy_cond(1)-x.([trans{n}]).seq_entropy_base(1))...
                   /x.([trans{n}]).seq_entropy_base(1),birdsummary.seq(ind));
               seqent = mean(seqent(~isinf(seqent)));
               
               ind = strcmp(arrayfun(@(x) x.([trans{n}]).condition,birdsummary.seq,'unif',0),'saline');
               seqent_sal = arrayfun(@(x) 100*(x.([trans{n}]).seq_entropy_cond(1)-x.([trans{n}]).seq_entropy_base(1))...
                   /x.([trans{n}]).seq_entropy_base(1),birdsummary.seq(ind));
               seqent_sal = mean(seqent_sal(~isinf(seqent)));
           
               group_seqent.(conditions{indcond}){1} = [group_seqent.(conditions{indcond}){1};seqent_sal seqent];
               group_seqent.(conditions{indcond}){2} = [group_seqent.(conditions{indcond}){2};{ff(i).name}];
            end
        end
    end
end

%% plot summary for sequence entropy changes

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_seqent.(conditions{n}){1}(:,1)) mean(group_seqent.(conditions{n}){1}(:,2))];
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
    plot(h1,[n-offset n+offset],group_seqent.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_seqent.(conditions{n}){1}(:,1),group_seqent.(conditions{n}){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'sequence entropy');