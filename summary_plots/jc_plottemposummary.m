function jc_plottemposummary(motifinfo_sal, motifinfo_cond,marker,linecolor);
%fv_syll from jc_findmotif

motifdur = [motifinfo_sal(:).motifdur];
sylldurations = arrayfun(@(x) mean(x.durations),motifinfo_sal);
gapdurations = arrayfun(@(x) mean(x.gaps),motifinfo_sal);

tb_sal = jc_tb([motifinfo_sal(:).datenm]',7,0);
tb_cond = jc_tb([motifinfo_cond(:).datenm]',7,0);
ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 

motifdur2 = [motifinfo_cond(:).motifdur];
sylldurations2 = arrayfun(@(x) mean(x.durations),motifinfo_cond);
gapdurations2 = arrayfun(@(x) mean(x.gaps),motifinfo_cond);
% motifdur2(ind) = [];
% sylldurations2(ind) = [];
% gapdurations2(ind) = [];


fignum = input('figure number for fv summary:');
figure(fignum);
subtightplot(2,3,1,0.07,0.04,0.1);hold on;
[hi lo mn1] = mBootstrapCI(motifdur);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(motifdur2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel('Duration (seconds)');
title('Motif Duration');


subtightplot(2,3,2,0.07,0.04,0.1);hold on;
[hi lo mn1] = mBootstrapCI(sylldurations);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(sylldurations2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel('Duration (seconds)');
title('Mean Syllable Duration');

subtightplot(2,3,3,0.07,0.04,0.1);hold on;
[hi lo mn1] = mBootstrapCI(gapdurations);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(gapdurations2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel('Duration (seconds)');
title('Mean Gap Duration');

motifdur2 = motifdur2/mean(motifdur);
motifdur = motifdur/mean(motifdur);
sylldurations2 = sylldurations2/mean(sylldurations);
sylldurations = sylldurations/mean(sylldurations);
gapdurations2 = gapdurations2/mean(gapdurations);
gapdurations = gapdurations/mean(gapdurations);

subtightplot(2,3,4,0.07,0.04,0.1);hold on;
[hi lo mn1] = mBootstrapCI(motifdur);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(motifdur2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel({'Change in motif duration', 'relative to saline'});
title('Normalized motif duration changes');

subtightplot(2,3,5,0.07,0.04,0.1);hold on;
[hi lo mn1] = mBootstrapCI(sylldurations);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(sylldurations2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel({'Change in syllable duration', 'relative to saline'});
title('Normalized syllable duration changes');

subtightplot(2,3,6,0.07,0.04,0.1);hold on;
[hi lo mn1] = mBootstrapCI(gapdurations);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(gapdurations2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel({'Change in gap durations', 'relative to saline'});
title('Normalized entropy changes');
