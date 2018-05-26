
ff = load_batchf('batch');
pre_vs_post = struct('pitch',[],'spent',[],'entropyvar',[],'motif',[]);
feature = fieldnames(pre_vs_post);
for i = 1:length(feature)
    pre_vs_post.([feature{i}]) = struct('hour',[],'morn_to_night',[],'night_to_morn',[],'day_to_day',[]);
end
for i = 1:length(ff)
    birdnm = ff(i).name;
    if ~exist(['summary_',birdnm])
        load([birdnm,'/analysis/data_structures/summary_',birdnm])
    end
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
            
            pre_vs_post.([feature{m}]).hour = [pre_vs_post.([feature{m}]).hour;abs([hour_pre hour_post])];
            pre_vs_post.([feature{m}]).morn_to_night = [pre_vs_post.([feature{m}]).morn_to_night;abs([morn_to_night_pre morn_to_night_post])];
            pre_vs_post.([feature{m}]).night_to_morn = [pre_vs_post.([feature{m}]).night_to_morn;abs([night_to_morn_pre night_to_morn_post])];
            pre_vs_post.([feature{m}]).day_to_day = [pre_vs_post.([feature{m}]).day_to_day;abs([day_to_day_pre day_to_day_post])];
        end
    end
end

%plot epoch changes in spectral features (line plots)
offset = 0.1429;
figure;hold on;
for m = 1:length(feature)
    h = subtightplot(length(feature),1,m,[0.07 0.05],0.08,0.12);
    cnd = fieldnames(pre_vs_post.([feature{m}]));
    plot(h,[1-0.5 length(cnd)+0.5],[0 0],'--','color','k');hold on;
    xtck = [];
    sgn = NaN(length(cnd),1);
    for n = 1:length(cnd)
        plot(h,[n-offset n+offset],pre_vs_post.([feature{m}]).([cnd{n}]),'marker','o','linewidth',1,'color',[0.5 0.5 0.5]);hold on;
        xtck = [xtck;n-offset;n+offset];
        p = signrank(pre_vs_post.([feature{m}]).([cnd{n}])(:,1),pre_vs_post.([feature{m}]).([cnd{n}])(:,2));
        sgn(n) = p;
    end
    for n = 1:length(cnd)
        if sgn(n) <= 0.05
            text((n-0.5)/4,0.95,'*','fontsize',12,'units','normalized');
        end
        text((n-0.5)/4,-0.15,strrep(cnd{n},'_',' '),'HorizontalAlignment','center','fontweight','bold','units','normalized');
    end
    ylabel('percent change');title([feature{m}]);
    set(h,'xtick',xtck,'xticklabel',{'pre','post'},'fontweight','bold');
end

%% pairwise pitch covariance
pre_vs_post.covar = struct('pitch',[],'spent',[],'entvar',[]);
feature = fieldnames(pre_vs_post.covar);
for i = 1:length(ff)
    birdnm = ff(i).name;
    summary = eval(['summary_',birdnm,'.covar']);
    for m = 1:length(feature)
        syllpairs = fieldnames(summary.([feature{m}]));
        for n = 1:length(syllpairs)
            pre_cov = summary.([feature{m}]).([syllpairs{n}]).pre;
            post_cov = summary.([feature{m}]).([syllpairs{n}]).post;
            pre_vs_post.covar.([feature{m}]) = [pre_vs_post.covar.([feature{m}]);[pre_cov post_cov]];
        end
    end
end

%plot change in spectral covariance
offset = 0.1429;
figure;hold on;
xtck = [];sgn = NaN(length(feature),1);
plot(gca,[1-0.5 length(feature)+0.5],[0 0],'--','color','k');hold on;
for m = 1:length(feature)
    plot(gca,[m-offset m+offset],pre_vs_post.covar.([feature{m}])(:,[1 3]),'marker','o','linewidth',1,'color',[0.5 0.5 0.5]);hold on;
        xtck = [xtck;m-offset;m+offset];
        p = signrank(pre_vs_post.covar.([feature{m}])(:,1),pre_vs_post.covar.([feature{m}])(:,3));
        sgn(m) = p;
end
for n = 1:length(feature)
    if sgn(n) <= 0.05
        text((n-0.5)/3,0.95,'*','fontsize',12,'units','normalized');
    end
    text((n-0.5)/3,-0.1,feature{n},'HorizontalAlignment','center','fontweight','bold','units','normalized');
end
ylabel('correlation');
set(gca,'xtick',xtck,'xticklabel',{'pre','post'},'fontweight','bold');

%% plot change in pitch autocorrelation
pre_vs_post_xcorr = [];
for i = 1:length(ff)
    birdnm = ff(i).name;
    summary = eval(['summary_',birdnm,'.pitch_autocorr']);
    syllables = fieldnames(summary);
    for m = 1:length(syllables)
            pre_xcorr = summary.([syllables{m}]).pre;
            post_xcorr = summary.([syllables{m}]).post;
            pre_vs_post_xcorr = [pre_vs_post_xcorr;[mean(pre_xcorr) mean(post_xcorr)]];
    end
end

%plot change in xcorr
figure;hold on;
plot([0 2],[0 0],'--','color','k');hold on;
plot([0.5 1.5],(pre_vs_post_xcorr),'marker','o','linewidth',1,'color',[0.5 0.5 0.5]);hold on;
p = signrank((pre_vs_post_xcorr(:,1)),(pre_vs_post_xcorr(:,2)));
ylabel('xcorr integral');
text(0,1,['p=',num2str(p)],'units','normalized','verticalalignment','top');

pre_vs_post_pitchcv = [];
for i = 1:length(ff)
    birdnm = ff(i).name;
    summary = eval(['summary_',birdnm,'.pitch_cv']);
    syllables = fieldnames(summary);
    for m = 1:length(syllables)
            pre_cv = summary.([syllables{m}]).pre;
            post_cv = summary.([syllables{m}]).post;
            pre_vs_post_pitchcv = [pre_vs_post_pitchcv;[mean(pre_cv) mean(post_cv)]];
    end
end

figure;hold on;
plot(pre_vs_post_pitchcv(:,2)./pre_vs_post_pitchcv(:,1),(pre_vs_post_xcorr(:,2)-pre_vs_post_xcorr(:,1)),'k.')

%% plot xcorr tc
pre_vs_post_xcorr_tc = [];
for i = 1:length(ff)
    birdnm = ff(i).name;
    summary = eval(['summary_',birdnm,'.pitch_autocorr']);
    syllables = fieldnames(summary);
    for m = 1:length(syllables)
            pre_xcorr_tc = summary.([syllables{m}]).pre_tc;
            post_xcorr_tc = summary.([syllables{m}]).post_tc;
            pre_vs_post_xcorr_tc = [pre_vs_post_xcorr_tc;[nanmean(pre_xcorr_tc) nanmean(post_xcorr_tc)]];
    end
end    

figure;hold on;
plot([0 2],[0 0],'--','color','k');hold on;
plot([0.5 1.5],[pre_vs_post_xcorr_tc(:,1) pre_vs_post_xcorr_tc(:,3)],'marker','o','linewidth',1,'color',[0.5 0.5 0.5]);hold on;
p = signrank(pre_vs_post_xcorr_tc(:,1),pre_vs_post_xcorr_tc(:,3));
ylabel('xcorr tc1');
text(0,1,['p=',num2str(p)],'units','normalized','verticalalignment','top');
figure;hold on;
plot([0 2],[0 0],'--','color','k');hold on;
plot([0.5 1.5],[pre_vs_post_xcorr_tc(:,2) pre_vs_post_xcorr_tc(:,4)],'marker','o','linewidth',1,'color',[0.5 0.5 0.5]);hold on;
p = signrank(pre_vs_post_xcorr_tc(:,2),pre_vs_post_xcorr_tc(:,4));
ylabel('xcorr tc2');
text(0,1,['p=',num2str(p)],'units','normalized','verticalalignment','top');

figure;hold on;
plot(pre_vs_post_pitchcv(:,2)./pre_vs_post_pitchcv(:,1),(pre_vs_post_xcorr_tc(:,3)-pre_vs_post_xcorr_tc(:,1)),'k.')