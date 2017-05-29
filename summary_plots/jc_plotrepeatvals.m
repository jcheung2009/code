function jc_plotrepeatvals(fv_rep,marker,tbshift,fignum,fignum2,removeoutliers)
%plots raw repeat vals in repstruct for script_plotdata 
%does not plot spectral values in repeat
%use jc_repeatanalysis2 for spectral measurements

if isempty(fignum)
    fignum = input('figure for repeat measurements:');
end
if isempty(fignum2)
    fignum2 = input('figure number for acorr:');
end

sylldur = [];gapdur = [];
for i = 1:length(fv_rep)
    sylldur = [sylldur; nanmean(fv_rep(i).sylldurations)];
    gapdur = [gapdur; nanmean(fv_rep(i).syllgaps)];
end
sylldur = [[fv_rep(:).datenm]',sylldur];
gapdur = [[fv_rep(:).datenm]',gapdur];
replength = [[fv_rep(:).datenm]',[fv_rep(:).runlength]'];
firstpeakdistance = [[fv_rep(:).datenm]',[fv_rep(:).firstpeakdistance]'];

if ~isempty(tbshift)
    sylldur(:,1) = jc_tb(sylldur(:,1),7,0)+(tbshift*24*3600);
    gapdur(:,1) = jc_tb(gapdur(:,1),7,0)+(tbshift*24*3600);
    replength(:,1) = jc_tb(replength(:,1),7,0)+(tbshift*24*3600);
    firstpeakdistance(:,1) = jc_tb(firstpeakdistance(:,1),7,0)+(tbshift*24*3600);
end
if removeoutliers == 'y'
    nstd = 4;
    sylldur = jc_removeoutliers(sylldur,nstd,1);
    gapdur = jc_removeoutliers(gapdur,nstd,1);
    firstpeakdistance = jc_removeoutliers(firstpeakdistance,nstd,1);
end

%% repeat length
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    plot(replength(:,1),replength(:,2),marker);
else
    marker = marker/max(marker);
    plot(replength(:,1),replength(:,2),'.','color',marker);
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel({'Repeat Length', '(number of syllables)'});


%% average syllable duration
subtightplot(3,1,2,0.07,0.08,0.15);hold on;
if isstr(marker)
    plot(sylldur(:,1),sylldur(:,2),marker);
else
    marker = marker/max(marker);
    plot(sylldur(:,1),sylldur(:,2),'.','color',marker);
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Average syllable duration (s)');

%% average gap duration
subtightplot(3,1,3,0.07,0.08,0.15);hold on;
if isstr(marker)
    plot(gapdur(:,1),gapdur(:,2),marker);
else
    marker = marker/max(marker);
    plot(gapdur(:,1),gapdur(:,2),'.','color',marker);
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Average gap duration (s)');

%% tempo acorr
figure(fignum2);hold on;
if isstr(marker)
    plot(firstpeakdistance(:,1),firstpeakdistance(:,2),marker);
else
    marker = marker/max(marker);
    plot(firstpeakdistance(:,1),firstpeakdistance(:,2),'.','color',marker);
end
if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
title('Average syllable-gap duration (autocorrelation)');
ylabel('Duration (s)');