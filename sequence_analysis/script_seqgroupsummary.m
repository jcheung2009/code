config;
conditions = params.conditions;

batch = uigetfile;
ff = load_batchf(batch);

group_seq = struct();
for n = 1:length(conditions)
    group_seq = setfield(group_seq,strrep(conditions{n},' ','_'),cell(2,1));
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
    
    if isfield(birdsummary,'seq')
        numts = length(fieldnames(birdsummary.seq));
        ts = fieldnames(birdsummary.seq);
        for indcond = 1:length(conditions)
            for n = 1:numts
                tsdata = birdsummary.seq(arrayfun(@(x) ~isempty(x.([ts{n}])),birdsummary.seq));
                ind = find(strcmp(arrayfun(@(x) x.([ts{n}]).condition,tsdata,'unif',0),conditions{indcond}));
                if isempty(ind)
                    continue
                end
                
                seqpvals = [];
                for m = 1:length(ind)
                    seqpvals = [seqpvals; tsdata(ind(m)).([ts{n}]).ts_pval];
                end
                if sum(seqpvals <= 0.05) > floor(length(seqpvals)/2)
                    seqpval = 0;
                else
                    seqpval = 1;
                end
                seqbase = arrayfun(@(x) x.([ts{n}]).seq_entropy_base(1),tsdata(ind),'un',1);
                seqcond = arrayfun(@(x) x.([ts{n}]).seq_entropy_cond(1),tsdata(ind),'un',1);
                seqvals = 100*mean((seqcond-seqbase)./seqbase);
                
                ind = find(strcmp(arrayfun(@(x) x.([ts{n}]).condition,tsdata,'unif',0),'saline'));
                seqbase = arrayfun(@(x) x.([ts{n}]).seq_entropy_base(1),tsdata(ind),'un',1);
                seqcond = arrayfun(@(x) x.([ts{n}]).seq_entropy_cond(1),tsdata(ind),'un',1);
                seqvals_sal = 100*mean((seqcond-seqbase)./seqbase);
                
                group_seq.(strrep(conditions{indcond},' ','_')){1} = ...
                    [group_seq.(strrep(conditions{indcond},' ','_')){1};seqvals_sal seqvals];
                group_seq.(strrep(conditions{indcond},' ','_')){2} = ...
                    [group_seq.(strrep(conditions{indcond},' ','_')){2}; {ff(i).name}];
            end
        end
    end
end
                
%% plot summary for sequence entropy changes

figure;h1 = gca;
dat = [];
for n = 1:length(conditions)
    dat = [dat;mean(group_seq.(conditions{n}){1}(:,1)) mean(group_seq.(conditions{n}){1}(:,2))];
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
    plot(h1,[n-offset n+offset],group_seq.(conditions{n}){1}','color',[0.5 0.5 0.5],'marker','o');hold on;
    p = signrank(group_seq.(conditions{n}){1}(:,1),group_seq.(conditions{n}){1}(:,2));
    if p <= 0.05
        text((n-0.5)/(length(conditions)),0.95,'*','fontsize',14,'units','normalized');
    end
end
ylabel('percent change');
set(h1,'xtick',1:length(conditions),'xticklabel',conditions,'fontweight','bold');
title(h1,'sequence entropy');