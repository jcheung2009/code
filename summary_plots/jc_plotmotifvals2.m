function jc_plotmotifvals2(motifinfo,motif,marker,tbshift,fignum,fignum2,removeoutliers,varargin);
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

if ~isempty(varargin)
    runavg = 'y';
    color = varargin{1};
else
    runavg = 'n';
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
    nstd = 3;
    motifdur = jc_removeoutliers(motifdur,nstd,1);
    sylldur = jc_removeoutliers(sylldur,nstd,1);
    gapdur = jc_removeoutliers(gapdur,nstd,1);
    firstpeakdistance = jc_removeoutliers(firstpeakdistance,nstd,1);
end

%running average 
if strcmp(runavg,'y')
    numseconds = motifdur(end,1)-motifdur(1,1);
    timewindow = 3600; % hr in seconds
    jogsize = 900;%15 minutes
    numtimewindows = floor(numseconds/jogsize)-(timewindow/jogsize)/2;%2*floor(numseconds/timewindow)-1;
    if numtimewindows <= 0
        numtimewindows = 1;
    end
    timept1 = motifdur(1,1);
    mdur_avg = [];sdur_avg = [];gdur_avg = [];
    for p = 1:numtimewindows
        timept2 = timept1+timewindow;
        ind = find(motifdur(:,1) >= timept1 & motifdur(:,1) < timept2);
        mdur_avg = [mdur_avg;timept1 nanmean(motifdur(ind,2))];
        ind = find(sylldur(:,1) >= timept1 & sylldur(:,1) < timept2);
        sdur_avg = [sdur_avg; timept1 nanmean(sylldur(ind,2))];
        ind = find(gapdur(:,1) >= timept1 & gapdur(:,1) < timept2);
        gdur_avg = [gdur_avg; timept1 nanmean(gapdur(ind,2))];
        timept1 = timept1+jogsize;
    end
    ind = isnan(mdur_avg(:,2));
    t = 1:length(mdur_avg);
    mdur_avg(ind,2) = interp1(t(~ind),mdur_avg(~ind,2),t(ind));
    ind = isnan(sdur_avg(:,2));
    t = 1:length(sdur_avg);
    sdur_avg(ind,2) = interp1(t(~ind),sdur_avg(~ind,2),t(ind));
    ind = isnan(gdur_avg(:,2));
    t = 1:length(gdur_avg);
    gdur_avg(ind,2) = interp1(t(~ind),gdur_avg(~ind,2),t(ind));
end


%% motif duration
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(motifdur(:,1),motifdur(:,2),marker);hold on
else
    h = plot(motifdur(:,1),motifdur(:,2),'.','color',marker);hold on
end
if strcmp(runavg,'y')
    plot(mdur_avg(:,1),mdur_avg(:,2),'color',color,'linewidth',2);
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
    h = plot(sylldur(:,1),sylldur(:,2),'.','color',marker);hold on
end
if strcmp(runavg,'y')
    plot(sdur_avg(:,1),sdur_avg(:,2),'color',color,'linewidth',2);
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
    h = plot(gapdur(:,1),gapdur(:,2),'.','color',marker);hold on
end
if strcmp(runavg,'y')
    plot(gdur_avg(:,1),gdur_avg(:,2),'color',color,'linewidth',2);
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