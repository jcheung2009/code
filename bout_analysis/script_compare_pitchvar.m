%summary plots for pitch bout analysis

ff = load_batchf('batch');

%% extract pitch information from all birds
lname = {};
pcv = [];%each row is bird: [pitch cv of all renditions (pre), pitch cv bout controlled (pre), (post), (post)]
pcv_pattern_pre = {};%each cell is one bird: pitch cv at each bout position
pcv_pattern_post = {};
fv_pattern_pre = {};%each cell is one bird: average pitch at each bout position
fv_pattern_post = {};
firstpitch_vs_lngth_corr_post = [];%corr coeffs for each bird for pitch beginning vs bout length
lastpitch_vs_lngth_corr_post = [];%corr coeffs for each bird for pitch end vs bout length
for i = 1:length(ff)
    cd(ff(i).name);
    ff2 = load_batchf('batch');
    config
    for ii = 1:length(params.boutstructs)
        
        if params.boutinfo{ii} == 0 %ignore boutstructs with only tempo info
            continue
        end
        
        bout_pre = [];
        bout_post = [];
        for n = 1:length(ff2)
            load(['analysis/data_structures/',params.boutstructs{ii},ff2(n).name]);   
            if ~isempty(strfind(ff2(n).name,'pre'))
                bout_pre = [bout_pre eval([params.boutstructs{ii},ff2(n).name])];
            elseif ~isempty(strfind(ff2(n).name,'post'))
                bout_post = [bout_post eval([params.boutstructs{ii},ff2(n).name])];
            end
        end
        
        %each cell is a bout position containing all pitch values at that
        %position 
        pre_all = cell2mat(arrayfun(@(x) x.boutpitch,bout_pre,'unif',0)');
        maxmotifs = max(arrayfun(@(x) x.nummotifs,bout_pre));
        bout_pre = cell2mat(arrayfun(@(x) [x.boutpitch; NaN(maxmotifs-length(x.boutpitch),1)],bout_pre,'unif',0));
        pre_boutctrl = {};
        for nn = 1:maxmotifs
            if sum(~isnan(bout_pre(nn,:))) < 15
                continue
            else
                pre_boutctrl{nn} = bout_pre(nn,:);
                pre_boutctrl{nn} = pre_boutctrl{nn}(~isnan(pre_boutctrl{nn}));
            end
        end
       
        %corr coefficient for pitch at beginning vs bout length (for post
        %condition)
        pitch_vs_lngth = cell2mat(arrayfun(@(x) [x.nummotifs x.boutpitch(1,:)],bout_post,'unif',0)');
        removeind = jc_findoutliers(pitch_vs_lngth,3);
        pitch_vs_lngth(removeind,:) = [];
        removeind = find(isnan(pitch_vs_lngth(:,2)));
        pitch_vs_lngth(removeind,:) = [];
        [r p] = corr(pitch_vs_lngth(:,1),pitch_vs_lngth(:,2));
        firstpitch_vs_lngth_corr_post = [firstpitch_vs_lngth_corr_post; r];
        
        %corr coefficient for pitch at end vs bout length (for post
        %condition)
        pitch_vs_lngth = cell2mat(arrayfun(@(x) [x.nummotifs x.boutpitch(end,:) x.boutpitch(1,:)],bout_post,'unif',0)');
        removeind = jc_findoutliers(pitch_vs_lngth(:,2),3);
        pitch_vs_lngth(removeind,:) = [];
        removeind = jc_findoutliers(pitch_vs_lngth(:,3),3);
        pitch_vs_lngth(removeind,:) = [];
        removeind = find(isnan(pitch_vs_lngth(:,2)));
        pitch_vs_lngth(removeind,:) = [];
        removeind = find(isnan(pitch_vs_lngth(:,3)));
        pitch_vs_lngth(removeind,:) = [];
        [r p] = corr(pitch_vs_lngth(:,1),pitch_vs_lngth(:,2)./pitch_vs_lngth(:,3));%pitch end normalized by pitch beginning
        lastpitch_vs_lngth_corr_post = [lastpitch_vs_lngth_corr_post; r];
        
        %each cell is a bout position containing all pitch values at that
        %position
        post_all = cell2mat(arrayfun(@(x) x.boutpitch,bout_post,'unif',0)');
        maxmotifs = max(arrayfun(@(x) x.nummotifs,bout_post));
        bout_post = cell2mat(arrayfun(@(x) [x.boutpitch; NaN(maxmotifs-length(x.boutpitch),1)],bout_post,'unif',0));
        post_boutctrl = {};
        for nn = 1:maxmotifs
            if sum(~isnan(bout_post(nn,:))) < 15
                continue
            else
                post_boutctrl{nn} = bout_post(nn,:);
                post_boutctrl{nn} = post_boutctrl{nn}(~isnan(post_boutctrl{nn}));
            end
        end
        
        pre_boutctrl_cv = sum(cellfun(@(x) cv(x)*length(x)/sum(cellfun(@length,pre_boutctrl)),pre_boutctrl));%weighted average pitch cv 
        post_boutctrl_cv = sum(cellfun(@(x) cv(x)*length(x)/sum(cellfun(@length,post_boutctrl)),post_boutctrl));
        pcv = [pcv; cv(pre_all) pre_boutctrl_cv cv(post_all) post_boutctrl_cv]; %pitch cv for pre all, pre bout ctrl, post all, post bout ctrl
        pcv_pattern_pre = [pcv_pattern_pre; cellfun(@(x) cv(x),pre_boutctrl)];
        pcv_pattern_post = [pcv_pattern_post; cellfun(@(x) cv(x),post_boutctrl)];
        fv_pattern_pre = [fv_pattern_pre; cellfun(@(x) mean(x),pre_boutctrl)];
        fv_pattern_post = [fv_pattern_post; cellfun(@(x) mean(x),post_boutctrl)];
        lname = [lname ff(i).name];
        
    end
    cd ../
end
%% correlate pre-post bout change with pre-post pitch change (absolute)

%pre-post normalized bout change 
fv_pattern_pre_norm = cellfun(@(x) x./x(1),fv_pattern_pre,'unif',0);%normalize average pitch at each bout position by average pitch at first position
fv_pattern_post_norm = cellfun(@(x) x./x(1),fv_pattern_post,'unif',0);
pre_boutchange = cellfun(@(x) sum(diff(x)),fv_pattern_pre_norm);
post_boutchange = cellfun(@(x) sum(diff(x)),fv_pattern_post_norm);
pre_absfv = cellfun(@(x) x(1), fv_pattern_pre);
post_absfv = cellfun(@(x) x(1),fv_pattern_post);

figure;hold on;
plot(pre_boutchange-post_boutchange,pre_absfv-post_absfv,'ok','markersize',8);hold on;
[r p] = corr(pre_boutchange-post_boutchange,pre_absfv-post_absfv);
xlabel('pre - post bout change (normalized)');
ylabel('pre - post pitch (absolute)');
m = polyfit(pre_boutchange-post_boutchange, pre_absfv-post_absfv,1);
refline(m(1),m(2));hold on;
y = get(gca,'ylim');
x = get(gca,'xlim');
text(x(1),y(2),{['r=',num2str(r)];['p=',num2str(p)]});
set(gca,'fontweight','bold');

%pre-post absolute bout change
pre_boutchange = cellfun(@(x) sum(diff(x)),fv_pattern_pre);
post_boutchange = cellfun(@(x) sum(diff(x)),fv_pattern_post);
pre_absfv = cellfun(@mean, fv_pattern_pre);
post_absfv = cellfun(@mean,fv_pattern_post);

figure;hold on;
plot(pre_boutchange-post_boutchange,pre_absfv-post_absfv,'ok','markersize',8);hold on;
[r p] = corr(pre_boutchange-post_boutchange,pre_absfv-post_absfv);
xlabel('pre - post bout change (absolute)');
ylabel('pre - post pitch (absolute)');
m = polyfit(pre_boutchange-post_boutchange, (pre_absfv-post_absfv)./pre_absfv,1);
refline(m(1),m(2));hold on;
y = get(gca,'ylim');
x = get(gca,'xlim');
text(x(1),y(2),{['r=',num2str(r)];['p=',num2str(p)]});
set(gca,'fontweight','bold');

%% compare corr coeffs of pitch at beginning/end vs bout length
figure;hold on;
plot(1,firstpitch_vs_lngth_corr_post,'marker','o','markersize',8,'linewidth',2);hold on;
plot(2,lastpitch_vs_lngth_corr_post,'marker','o','markersize',8,'linewidth',2);hold on;
legend(lname);
y = get(gca,'ylim');
[p h] = signrank(firstpitch_vs_lngth_corr_post);
text(1,y(2),{['p=',num2str(p)]});
[p h] = signrank(lastpitch_vs_lngth_corr_post);
text(2,y(2),{['p=',num2str(p)]});
plot([0 3],[0 0],'c','linewidth',2);hold on;
ylabel('pitch vs bout length correlation');
set(gca,'fontweight','bold','xtick',[1:2],'xticklabel',{'first','last'});
title('post');

%% plot pitch cv total vs bout controlled 
pcv_norm = pcv./pcv(:,1);
figure;hold on;
plot([1:4],pcv_norm,'marker','o','markersize',8,'linewidth',2);hold on;
legend(lname);
bar([1:4],mean(pcv_norm),'facecolor','none','edgecolor','k','linewidth',1.5);hold on;
y = get(gca,'ylim');
[p h] = signrank(pcv_norm(:,3),pcv_norm(:,4));
text(4,y(2),{['p=',num2str(p)]});
ylabel('normalized pitch cv');
set(gca,'fontweight','bold','xtick',[1:4],'xticklabel',{'pre all','pre bout ctrl','post all','post bout ctrl'});

%% plot pitch var bout pattern
minmotif = min(cellfun(@(x) length(x),pcv_pattern_pre));
pcv_pattern_pre = cell2mat(cellfun(@(x) x(1:minmotif),pcv_pattern_pre,'unif',0));
pcv_pattern_pre = pcv_pattern_pre./pcv_pattern_pre(:,1);
figure;hold on;
plot(1:minmotif,pcv_pattern_pre,'marker','o','markersize',8,'linewidth',2);hold on;
legend(lname);
bar([1:minmotif],mean(pcv_pattern_pre),'facecolor','none','edgecolor','k','linewidth',1.5);hold on;
y = get(gca,'ylim');
for i = 1:minmotif-1
    [p h] = signrank(pcv_pattern_pre(:,i),pcv_pattern_pre(:,i+1));
    text(i+1,y(2),{['p=',num2str(p)]});
end
ylabel('normalized pitch cv');
xlabel('bout position');
set(gca,'fontweight','bold','xtick',[1:minmotif]);
title('pre');

minmotif = min(cellfun(@(x) length(x),pcv_pattern_post));
pcv_pattern_post = cell2mat(cellfun(@(x) x(1:minmotif),pcv_pattern_post,'unif',0));
pcv_pattern_post = pcv_pattern_post./pcv_pattern_post(:,1);
figure;hold on;
plot(1:minmotif,pcv_pattern_post,'marker','o','markersize',8,'linewidth',2);hold on;
legend(lname);
bar([1:minmotif],mean(pcv_pattern_post),'facecolor','none','edgecolor','k','linewidth',1.5);hold on;
y = get(gca,'ylim');
for i = 1:minmotif-1
    [p h] = signrank(pcv_pattern_post(:,i),pcv_pattern_post(:,i+1));
    text(i+1,y(2),{['p=',num2str(p)]});
end
ylabel('normalized pitch cv');
xlabel('bout position');
set(gca,'fontweight','bold','xtick',[1:minmotif]);
title('post');

%% plot pitch bout pattern
minmotif = min(cellfun(@(x) length(x),fv_pattern_pre));
fv_pattern_pre2 = cell2mat(cellfun(@(x) x(1:minmotif),fv_pattern_pre,'unif',0));
fv_pattern_pre2 = fv_pattern_pre2./fv_pattern_pre2(:,1);
figure;hold on;
plot(1:minmotif,fv_pattern_pre2,'marker','o','markersize',8,'linewidth',2);hold on;
legend(lname);
bar([1:minmotif],mean(fv_pattern_pre2),'facecolor','none','edgecolor','k','linewidth',1.5);hold on;
ylim([0.95 1]);
y = get(gca,'ylim');
for i = 1:minmotif-1
    [p h] = signrank(fv_pattern_pre2(:,i),fv_pattern_pre2(:,i+1));
    text(i+1,y(2),{['p=',num2str(p)]});
end
ylabel('normalized pitch');
xlabel('bout position');
set(gca,'fontweight','bold','xtick',[1:minmotif]);
title('pre');
        
minmotif = min(cellfun(@(x) length(x),fv_pattern_post));
fv_pattern_post2 = cell2mat(cellfun(@(x) x(1:minmotif),fv_pattern_post,'unif',0));
fv_pattern_post2 = fv_pattern_post2./fv_pattern_post2(:,1);
figure;hold on;
plot(1:minmotif,fv_pattern_post2,'marker','o','markersize',8,'linewidth',2);hold on;
legend(lname);
bar([1:minmotif],mean(fv_pattern_post2),'facecolor','none','edgecolor','k','linewidth',1.5);hold on;
ylim([0.95 1]);
y = get(gca,'ylim');
for i = 1:minmotif-1
    [p h] = signrank(fv_pattern_post2(:,i),fv_pattern_post2(:,i+1));
    text(i+1,y(2),{['p=',num2str(p)]});
end
ylabel('normalized pitch');
xlabel('bout position');
set(gca,'fontweight','bold','xtick',[1:minmotif]);
title('post');

fv_pattern_pre = cell2mat(cellfun(@(x) x(1:minmotif),fv_pattern_pre,'unif',0));
fv_pattern_post = cell2mat(cellfun(@(x) x(1:minmotif),fv_pattern_post,'unif',0));
