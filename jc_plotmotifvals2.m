function jc_plotmotifvals2(motifinfo,marker,tbshift);

fignum = input('figure number for plotting:');


motifdur = [[motifinfo(:).datenm]',[motifinfo(:).motifdur]']
sylldur = [[motifinfo(:).datenm]',arrayfun(@(x) mean(x.durations),motifinfo)'];
gapdur = [[motifinfo(:).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo)'];

if tbshift == -1
    motifdur(:,1) = jc_tb(motifdur(:,1),7,0)-(24*3600);
    sylldur(:,1) = jc_tb(sylldur(:,1),7,0)-(24*3600);
    gapdur(:,1) = jc_tb(gapdur(:,1),7,0)-(24*3600);
    xticklabel = [-24:4:38];
elseif tbshift == 1
    motifdur(:,1) = jc_tb(motifdur(:,1),7,0)+(24*3600);
    sylldur(:,1) = jc_tb(sylldur(:,1),7,0)+(24*3600);
    gapdur(:,1) = jc_tb(gapdur(:,1),7,0)+(24*3600);
    xticklabel = [-24:4:38];
elseif tbshift == 0
    motifdur(:,1) = jc_tb(motifdur(:,1),7,0);
    sylldur(:,1) = jc_tb(sylldur(:,1),7,0);
    gapdur(:,1) = jc_tb(gapdur(:,1),7,0);
    xticklabel = [-24:4:38];
end
xtick = xticklabel*3600;
xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);
    
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
h = plot(motifdur(:,1),motifdur(:,2),marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(motifdur(:,2),nstd);
    motifdur(ind,:) = [];
    h = plot(motifdur(:,1),motifdur(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
xlabel('');
ylabel('Duration (seconds)');
title('Motif duration');

subtightplot(3,1,2,0.07,0.08,0.15);hold on;
h = plot(sylldur(:,1),sylldur(:,2),marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(sylldur(:,2),nstd);
    sylldur(ind,:) = [];
    h = plot(sylldur(:,1),sylldur(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
xlabel('');
ylabel('Duration (seconds)');
title('Syllable duration');

subtightplot(3,1,3,0.07,0.08,0.15);hold on;
h = plot(gapdur(:,1),gapdur(:,2),marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('standard dev:');
    delete(h);
    ind = jc_findoutliers(gapdur(:,2),nstd);
    gapdur(ind,:) = [];
    h = plot(gapdur(:,1),gapdur(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
xlabel('Time (hours since 7 AM on Day 0)');
ylabel('Duration (seconds)');
title('Gap duration');