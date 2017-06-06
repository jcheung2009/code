function jc_plotmotifvals2(motifinfo,motif,marker,tbshift,fignum,fignum2,removeoutliers);
%plot raw motif tempo values in motifstruct for script_plotdata

if isempty(fignum)
    fignum = input('figure number for plotting motif vals:');
end
if isempty(fignum2)
    fignum2 = input('figure for acorr:');
end
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
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
if removeoutliers == 'y'
    nstd = 4;
    motifdur = jc_removeoutliers(motifdur,nstd,1);
    sylldur = jc_removeoutliers(sylldur,nstd,1);
    gapdur = jc_removeoutliers(gapdur,nstd,1);
    firstpeakdistance = jc_removeoutliers(firstpeakdistance,nstd,1);
end

%% motif duration
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(motifdur(:,1),motifdur(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(motifdur(:,1),motifdur(:,2),'.','color',marker);hold on
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Duration (seconds)','fontweight','bold');
title([motif,' motif duration']);

%% syll duration
subtightplot(3,1,2,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(sylldur(:,1),sylldur(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(sylldur(:,1),sylldur(:,2),'.','color',marker);hold on
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Duration (seconds)');
title('Syllable duration');

%% gap duration
subtightplot(3,1,3,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(gapdur(:,1),gapdur(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(gapdur(:,1),gapdur(:,2),'.','color',marker);hold on
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Duration (seconds)');
title('Gap duration');

%% tempo acorr
figure(fignum2);hold on;
if isstr(marker)
    h = plot(firstpeakdistance(:,1),firstpeakdistance(:,2),marker);hold on;
else
    marker = marker/max(marker);
    h = plot(firstpeakdistance(:,1),firstpeakdistance(:,2),'.','color',marker);hold on;
end

if~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Duration (seconds)');
title([motif, ' Interval duration']);