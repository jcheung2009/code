function jc_plotmotifval_amp_vs_phase_segmentation(motifsegment,marker,tbshift,motif,removeoutliers,fignum,fignum2,fignum3);
%this function plots data in  motifsegment structure to compare phase and
%amplitude segmentation on duration and gaps

nstd = 4;
if isempty(fignum)
    fignum = input('figure number for plotting motif vals:');
end

motifdur = [[motifsegment(:).datenm]',[motifsegment(:).amp_motifdur]',[motifsegment(:).ph_motifdur]'];
sylldur = [[motifsegment(:).datenm]',arrayfun(@(x) mean(x.amp_durs),motifsegment)'...
    ,arrayfun(@(x) mean(x.ph_durs),motifsegment)'];
gapdur = [[motifsegment(:).datenm]',arrayfun(@(x) mean(x.amp_gaps),motifsegment)'...
    ,arrayfun(@(x) mean(x.ph_gaps),motifsegment)'];

if removeoutliers == 'y'
    motifdur = jc_removeoutliers(motifdur,nstd,1);
    sylldur = jc_removeoutliers(sylldur,nstd,1);
    gapdur = jc_removeoutliers(gapdur,nstd,1);
end

if ~isempty(tbshift) 
    motifdur(:,1) = jc_tb(motifdur(:,1),7,0)+(tbshift*24*3600);
    sylldur(:,1) = jc_tb(sylldur(:,1),7,0)+(tbshift*24*3600);
    gapdur(:,1) = jc_tb(gapdur(:,1),7,0)+(tbshift*24*3600);
end

%plot motif durations
figure(fignum);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(motifdur(:,1),motifdur(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(motifdur(:,1),motifdur(:,2),'.','color',marker);hold on
end
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title([motif,': Motif duration (amp)']);

subtightplot(2,1,2,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(motifdur(:,1),motifdur(:,3),marker);hold on
else
    marker = marker/max(marker);
    h = plot(motifdur(:,1),motifdur(:,3),'.','color',marker);hold on
end
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title([motif,': Motif duration (phase)']);

%plot syll durations
figure(fignum2);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(sylldur(:,1),sylldur(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(sylldur(:,1),sylldur(:,2),'.','color',marker);hold on
end
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title([motif,': Mean syll duration (amp)']);

subtightplot(2,1,2,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(sylldur(:,1),sylldur(:,3),marker);hold on
else
    marker = marker/max(marker);
    h = plot(sylldur(:,1),sylldur(:,3),'.','color',marker);hold on
end
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title([motif,': Mean syll duration (phase)']);

%plot gap durations
figure(fignum3);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(gapdur(:,1),gapdur(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(gapdur(:,1),gapdur(:,2),'.','color',marker);hold on
end
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title([motif,': Mean gap duration (amp)']);

subtightplot(2,1,2,0.07,0.08,0.15);hold on;
if isstr(marker)
    h = plot(gapdur(:,1),gapdur(:,3),marker);hold on
else
    marker = marker/max(marker);
    h = plot(gapdur(:,1),gapdur(:,3),'.','color',marker);hold on
end
dataob = get(gca,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel('');
ylabel('Duration (seconds)');
title([motif,': Mean gap duration (phase)']);


