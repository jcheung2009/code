function jc_plotrepeatvals(fv_rep,marker,tbshift)
%fv_rep from jc_findrepeat2 or jc_findrepeat3
%does not plot spectral values in repeat
%use jc_repeatanalysis2 for spectral measurements


%plot repeat length
fignum = input('figure for repeat measurements:');
figure(fignum);hold on;
replength = [jc_tb([fv_rep(:).datenm]',7,0) [fv_rep(:).runlength]'];
 if tbshift == -1
        replength(:,1) = replength(:,1) - (24*3600);
        xticklabel = [-24:4:38];
 elseif tbshift == 1
     replength(:,1) = replength(:,1)+(24*3600);
      xticklabel = [-24:4:38];
 elseif tbshift == 0
     xticklabel = [-24:4:12];
 end
 xtick = xticklabel*3600;
 xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);

subtightplot(3,1,1,0.07,0.08,0.15);hold on;
plot(replength(:,1),replength(:,2),marker);
ylabel({'Repeat Length', '(number of syllables)'});
%xlabel('Time (hours since 7 AM)');
title('Number of syllables in repeat');
set(gca,'xtick',xtick,'xticklabel',xticklabel);

%plot average syllable and gap duration
sylldur = [];
gapdur = [];
firstpeakdistance = [[fv_rep(:).datenm]',[fv_rep(:).firstpeakdistance]'];
tb_sylldur = jc_tb([fv_rep(:).datenm]',7,0);
tb_gapdur = jc_tb([fv_rep(:).datenm]',7,0);
firstpeakdistance(:,1) = jc_tb(firstpeakdistance(:,1),7,0);

if tbshift == -1
        tb_sylldur = tb_sylldur - (24*3600);
        tb_gapdur = tb_gapdur-(24*3600);
        firstpeakdistance(:,1) = firstpeakdistance(:,1) - (24*3600);
        xticklabel = [-24:4:38];
 elseif tbshift == 1
     tb_sylldur = tb_sylldur + (24*3600);
        tb_gapdur = tb_gapdur+(24*3600);
        firstpeakdistance(:,1) = firstpeakdistance(:,1)+(24*3600);
      xticklabel = [-24:4:38];
 elseif tbshift == 0
     xticklabel = [-24:4:38];
 end
 xtick = xticklabel*3600;
 xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);



for i = 1:length(fv_rep)
    sylldur = [sylldur; nanmean(fv_rep(i).sylldurations)];
    gapdur = [gapdur; nanmean(fv_rep(i).syllgaps)];
end

subtightplot(3,1,2,0.07,0.08,0.15);hold on;
h = plot(tb_sylldur,sylldur,marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('use nstd:');
    delete(h);
    ind = jc_findoutliers(sylldur,nstd);
    tb_sylldur(ind) = [];
    sylldur(ind) = [];
    h = plot(tb_sylldur, sylldur,marker);
    removeoutliers = input('remove outliers?:','s');
end
ylabel('Syllable duration (s)');
%xlabel('Time (hours since 7 AM)');
title('Average syllable duration in repeat');
set(gca,'xtick',xtick,'xticklabel',xticklabel);

subtightplot(3,1,3,0.07,0.08,0.15);hold on;
h = plot(tb_gapdur,gapdur,marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('use nstd:');
    delete(h);
    ind = jc_findoutliers(gapdur,nstd);
    tb_gapdur(ind) = [];
    gapdur(ind) = [];
    h = plot(tb_gapdur, gapdur,marker);
    removeoutliers = input('remove outliers?:','s');
end
title('Average gap duration (s)');
xlabel('Time (hours since 7 AM)');
ylabel('Gap duration (s)');
set(gca,'xtick',xtick,'xticklabel',xticklabel);

fignum2 = input('figure number for acorr:');
figure(fignum2);hold on;
h = plot(firstpeakdistance(:,1),firstpeakdistance(:,2),marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('use nstd:');
    delete(h);
    ind = jc_findoutliers(firstpeakdistance,nstd);
    firstpeakdistance(ind,:) = [];
    h = plot(firstpeakdistance(:,1), firstpeakdistance(:,2),marker);
    removeoutliers = input('remove outliers?:','s');
end
title('Average syllable-gap duration (autocorrelation)');
xlabel('Time (hours since 7 AM)');
ylabel('Duration (s)');
set(gca,'xtick',xtick,'xticklabel',xticklabel);
