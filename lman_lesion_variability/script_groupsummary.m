
ff = load_batchf('batch');
pre_vs_post = struct('pitch',[],'spent',[],'entropyvar',[],'motif',[]);
feature = fieldnames(pre_vs_post);
for i = 1:length(fn)
    pre_vs_post.([fn{i}]) = struct('hour',[],'morn_to_night',[],'night_to_morn',[],'day_to_day',[]);
end
for i = 1:length(ff)
    birdnm = ff(i).name;
    load([birdnm,'/analysis/data_structures/summary_',birdnm])
    summary = eval(['summary_',birdnm]);
    for m = 1:length(feature)
        sylls = fieldnames(summary.([feature{m}]));
        for n = 1:length(sylls)
            hour_pre = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).hourly.pre)));
            hour_post = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).hourly.post)));
            morn_to_night_pre = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).morn_to_night.pre)));
            morn_to_night_post = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).morn_to_night.post)));
            night_to_morn_pre = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).night_to_morn.pre)));
            night_to_morn_post = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).night_to_morn.post)));
            day_to_day_pre = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).day_to_day.pre)));
            day_to_day_post = nanmean(cell2mat(struct2cell(summary.([feature{m}]).([sylls{n}]).day_to_day.post)));
            
            pre_vs_post.([feature{m}]).hour = [pre_vs_post.([feature{m}]).hour;[hour_pre hour_post]];
            pre_vs_post.([feature{m}]).morn_to_night = [pre_vs_post.([feature{m}]).morn_to_night;[morn_to_night_pre morn_to_night_post]];
            pre_vs_post.([feature{m}]).night_to_morn = [pre_vs_post.([feature{m}]).night_to_morn;[night_to_morn_pre night_to_morn_post]];
            pre_vs_post.([feature{m}]).day_to_day = [pre_vs_post.([feature{m}]).day_to_day;[day_to_day_pre day_to_day_post]];
        end
    end
end

offset = 
figure;hold on;
for m = 1:length(feature)
    h = subtightplot(length(feature),1,m,[0.07 0.05],0.08,0.12);
    cnd = fieldnames(pre_vs_post.([feature{m}]));
    xtck = [];
    for n = 1:length(cnd)
        plot(h,[n-offset n+offset],pre_vs_post.([feature{m}]).([cnd{n}]),'marker','o','linewidth',1,'color',[0.5 0.5 0.5]);hold on;
        xtck = [xtck;n-offset;n+offset];
    end
    set(h,'xlim',[0.5 length(cnd)+.75]);y=get(gca,'ylim');
    ylabel('percent change');title([feature{m}]);
    set(gca,'xtick',xtck,'xticklabel',{'pre','post'},'fontweight','bold');
    
