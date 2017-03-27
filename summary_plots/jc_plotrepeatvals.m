function jc_plotrepeatvals(fv_rep,marker,tbshift,fignum,fignum2,removeoutliers)
%fv_rep from jc_findrepeat2 or jc_findrepeat3
%does not plot spectral values in repeat
%use jc_repeatanalysis2 for spectral measurements


%plot repeat length
if isempty(fignum)
    fignum = input('figure for repeat measurements:');
end

figure(fignum);hold on;
replength = [jc_tb([fv_rep(:).datenm]',7,0) [fv_rep(:).runlength]'];
 if ~isempty(tbshift)
        replength(:,1) = replength(:,1)+(tbshift*24*3600);
 end

subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    plot(replength(:,1),replength(:,2),marker);
else
    marker = marker/max(marker);
    plot(replength(:,1),replength(:,2),'.','color',marker);
end
ylabel({'Repeat Length', '(number of syllables)'});
title('Number of syllables in repeat');
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');

%plot average syllable and gap duration
sylldur = [];
gapdur = [];
firstpeakdistance = [[fv_rep(:).datenm]',[fv_rep(:).firstpeakdistance]'];
tb_sylldur = jc_tb([fv_rep(:).datenm]',7,0);
tb_gapdur = jc_tb([fv_rep(:).datenm]',7,0);
firstpeakdistance(:,1) = jc_tb(firstpeakdistance(:,1),7,0);

if ~isempty(tbshift)
        tb_sylldur = tb_sylldur+(tbshift*24*3600);
        tb_gapdur = tb_gapdur+(tbshift*24*3600);
        firstpeakdistance(:,1) = firstpeakdistance(:,1)+(tbshift*24*3600);
end

for i = 1:length(fv_rep)
    sylldur = [sylldur; nanmean(fv_rep(i).sylldurations)];
    gapdur = [gapdur; nanmean(fv_rep(i).syllgaps)];
end

subtightplot(3,1,2,0.07,0.08,0.15);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
if removeoutliers == 'y'
    nstd = 4;
    ind = jc_findoutliers(sylldur,nstd);
    tb_sylldur(ind) = [];
    sylldur(ind) = [];
end
if isstr(marker)
    plot(tb_sylldur,sylldur,marker);
else
    marker = marker/max(marker);
    plot(tb_sylldur,sylldur,'.','color',marker);
end

ylabel('Syllable duration (s)');
title('Average syllable duration in repeat');
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');


subtightplot(3,1,3,0.07,0.08,0.15);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
if removeoutliers == 'y'
    nstd = 4;
    ind = jc_findoutliers(gapdur,nstd);
    tb_gapdur(ind) = [];
    gapdur(ind) = [];
end
if isstr(marker)
    plot(tb_gapdur,gapdur,marker);
else
    marker = marker/max(marker);
    plot(tb_gapdur,gapdur,'.','color',marker);
end
title('Average gap duration (s)');
xlabel('Time (hours since 7 AM)');
ylabel('Gap duration (s)');
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');

if isempty(fignum2)
    fignum2 = input('figure number for acorr:');
end
figure(fignum2);hold on;
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
if removeoutliers == 'y'
    nstd = 4;
    ind = jc_findoutliers(firstpeakdistance,nstd);
    firstpeakdistance(ind,:) = [];
end
if isstr(marker)
    plot(firstpeakdistance(:,1),firstpeakdistance(:,2),marker);
else
    marker = marker/max(marker);
    plot(firstpeakdistance(:,1),firstpeakdistance(:,2),'.','color',marker);
end
title('Average syllable-gap duration (autocorrelation)');
xlabel('Time (hours since 7 AM)');
ylabel('Duration (s)');
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');