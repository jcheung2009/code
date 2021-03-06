function jc_plotrawdata(fv,syllable,marker,tbshift,fignum,removeoutliers,varargin)
%plots raw spectral information from fvstruct in script_findwnote2/jc_findwnote5
if isempty(fignum)
    fignum = input('figure number for raw data:');
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

pitchdat = [[fv(:).datenm]',[fv(:).mxvals]'];
voldat = [[fv(:).datenm]',log([fv(:).maxvol]')];
entdat = [[fv(:).datenm]',[fv(:).spent]'];

if ~isempty(tbshift)
    pitchdat(:,1) = jc_tb(pitchdat(:,1),7,0)+(tbshift*24*3600);
    voldat(:,1) = jc_tb(voldat(:,1),7,0)+(tbshift*24*3600);
    entdat(:,1) = jc_tb(entdat(:,1),7,0)+(tbshift*24*3600);
end

if removeoutliers == 'y'
    nstd = 4;
    pitchdat = jc_removeoutliers(pitchdat,nstd,1);
    voldat = jc_removeoutliers(voldat,nstd,1);
    entdat = jc_removeoutliers(entdat,nstd,1);
end

%running average 
if strcmp(runavg,'y')
    numseconds = pitchdat(end,1)-pitchdat(1,1);
    timewindow = 3600; % hr in seconds
    jogsize = 900;%15 minutes
    numtimewindows = floor(numseconds/jogsize)-(timewindow/jogsize)/2;%2*floor(numseconds/timewindow)-1;
    if numtimewindows <= 0
        numtimewindows = 1;
    end
    timept1 = pitchdat(1,1);
    fv_avg = [];vol_avg = [];ent_avg = [];
    for p = 1:numtimewindows
        timept2 = timept1+timewindow;
        ind = find(pitchdat(:,1) >= timept1 & pitchdat(:,1) < timept2);
        fv_avg = [fv_avg;timept1 nanmean(pitchdat(ind,2))];
        ind = find(voldat(:,1) >= timept1 & voldat(:,1) < timept2);
        vol_avg = [vol_avg; timept1 nanmean(voldat(ind,2))];
        ind = find(entdat(:,1) >= timept1 & entdat(:,1) < timept2);
        ent_avg = [ent_avg; timept1 nanmean(entdat(ind,2))];
        timept1 = timept1+jogsize;
    end
    ind = isnan(fv_avg(:,2));
    t = 1:length(fv_avg);
    fv_avg(ind,2) = interp1(t(~ind),fv_avg(~ind,2),t(ind));
    ind = isnan(vol_avg(:,2));
    t = 1:length(vol_avg);
    vol_avg(ind,2) = interp1(t(~ind),vol_avg(~ind,2),t(ind));
    ind = isnan(ent_avg(:,2));
    t = 1:length(ent_avg);
    ent_avg(ind,2) = interp1(t(~ind),ent_avg(~ind,2),t(ind));
end
        
%% pitch
figure(fignum);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(pitchdat(:,1),pitchdat(:,2),marker);hold on
else
    h = plot(pitchdat(:,1),pitchdat(:,2),'.','color',marker);hold on
end
if strcmp(runavg,'y')
    plot(fv_avg(:,1),fv_avg(:,2),'color',color,'linewidth',2);
end
if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
   xlabel('Time','fontweight','bold') 
end
ylabel('Frequency (Hz)','fontweight','bold')
title(syllable);
%% volume
subtightplot(2,1,2,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(voldat(:,1),voldat(:,2),marker);hold on
else
    h = plot(voldat(:,1),voldat(:,2),'.','color',marker);hold on
end
if strcmp(runavg,'y')
    plot(vol_avg(:,1),vol_avg(:,2),'color',color,'linewidth',2);
end
if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold')
else
    xlabel('Time','fontweight','bold');
end
ylabel('Log Amplitude','fontweight','bold')

%% entropy
% subtightplot(3,1,3,0.07,0.08,0.15);hold on;
% if isstr(marker)
%     h = plot(entdat(:,1),entdat(:,2),marker);hold on
% else
%     marker = marker/max(marker);
%     h = plot(entdat(:,1),entdat(:,2),'.','color',marker);hold on
% end
% 
% if ~isempty(tbshift)
%     xscale_hours_to_days(gca);
%     xlabel('Days','fontweight','bold');
% else
%     xlabel('Time','fontweight','bold');
% end
% ylabel('Entropy','fontweight','bold');