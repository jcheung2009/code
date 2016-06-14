function jc_plotmotifvals2(motifinfo,marker,tbshift,fignum,fignum2,removeoutliers);
if isempty(fignum)
    fignum = input('figure number for plotting motif vals:');
end


motifdur = [[motifinfo(:).datenm]',[motifinfo(:).motifdur]'];
sylldur = [[motifinfo(:).datenm]',arrayfun(@(x) mean(x.durations),motifinfo)'];
gapdur = [[motifinfo(:).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo)'];
firstpeakdistance = [[motifinfo(:).datenm]' [motifinfo(:).firstpeakdistance]'];

if ~isempty(tbshift) 
    motifdur(:,1) = jc_tb(motifdur(:,1),7,0)+(tbshift*24*3600);
    sylldur(:,1) = jc_tb(sylldur(:,1),7,0)+(tbshift*24*3600);
    gapdur(:,1) = jc_tb(gapdur(:,1),7,0)+(tbshift*24*3600);
    firstpeakdistance(:,1) = jc_tb(firstpeakdistance(:,1),7,0)+(tbshift*24*3600);
end
    
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
h = plot(motifdur(:,1),motifdur(:,2),marker);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(motifdur(:,2),nstd);
    motifdur(ind,:) = [];
    h = plot(motifdur(:,1),motifdur(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlim = get(gca,'xlim');
xtick = [xlim(1):4*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title('Motif duration');

subtightplot(3,1,2,0.07,0.08,0.15);hold on;
h = plot(sylldur(:,1),sylldur(:,2),marker);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(sylldur(:,2),nstd);
    sylldur(ind,:) = [];
    h = plot(sylldur(:,1),sylldur(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlim = get(gca,'xlim');
xtick = [xlim(1):4*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title('Syllable duration');

subtightplot(3,1,3,0.07,0.08,0.15);hold on;
h = plot(gapdur(:,1),gapdur(:,2),marker);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(gapdur(:,2),nstd);
    gapdur(ind,:) = [];
    h = plot(gapdur(:,1),gapdur(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlim = get(gca,'xlim');
xtick = [xlim(1):4*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('Time (hours since 7 AM on Day 0)');
ylabel('Duration (seconds)');
title('Gap duration');

if isempty(fignum2)
    fignum2 = input('figure for acorr:');
end
figure(fignum2);hold on;
h = plot(firstpeakdistance(:,1),firstpeakdistance(:,2),marker);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(firstpeakdistance(:,2),nstd);
    firstpeakdistance(ind,:) = [];
    h = plot(firstpeakdistance(:,1),firstpeakdistance(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlim = get(gca,'xlim');
xtick = [xlim(1):4*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('Time (hours since 7 AM on Day 0)');
ylabel('Duration (seconds)');
title('Average syllable-gap duration (autocorrelation)');