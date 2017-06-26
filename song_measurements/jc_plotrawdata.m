function jc_plotrawdata(fv,syllable,marker,tbshift,fignum,removeoutliers)
%plots raw spectral information from fvstruct in script_findwnote2/jc_findwnote5
if isempty(fignum)
    fignum = input('figure number for raw data:');
end

if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
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

%% pitch
figure(fignum);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(pitchdat(:,1),pitchdat(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(pitchdat(:,1),pitchdat(:,2),'.','color',marker);hold on
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
    marker = marker/max(marker);
    h = plot(voldat(:,1),voldat(:,2),'.','color',marker);hold on
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