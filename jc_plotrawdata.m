function jc_plotrawdata(fv,marker,tbshift,fignum,removeoutliers)
%fv from jc_findwnote5
pitchdat = [[fv(:).datenm]',[fv(:).mxvals]'];
voldat = [[fv(:).datenm]',log([fv(:).maxvol]')];
entdat = [[fv(:).datenm]',[fv(:).spent]'];


if ~isempty(tbshift)
    pitchdat(:,1) = jc_tb(pitchdat(:,1),7,0)+(tbshift*24*3600);
    voldat(:,1) = jc_tb(voldat(:,1),7,0)+(tbshift*24*3600);
    entdat(:,1) = jc_tb(entdat(:,1),7,0)+(tbshift*24*3600);
end

if isempty(fignum)
    fignum = input('figure number for raw data:');
end
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
h = plot(pitchdat(:,1),pitchdat(:,2),marker);hold on
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard devs:');
    delete(h)
    ind = jc_findoutliers(pitchdat(:,2),nstd);
    pitchdat(ind,:) = [];
    h = plot(pitchdat(:,1),pitchdat(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
if ~isempty(tbshift)
    xlim = get(gca,'xlim');
    xtick = [xlim(1):4*3600:xlim(2)];
    xticklabel = round(xtick/3600);
    set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
    xlabel('','fontweight','bold');
else
   xlabel('Time','fontweight','bold') 
end

ylabel('Frequency (Hz)','fontweight','bold')

subtightplot(3,1,2,0.07,0.08,0.15);hold on;
h = plot(voldat(:,1),voldat(:,2),marker);hold on
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard devs:');
    delete(h)
    ind = jc_findoutliers(voldat(:,2),nstd);
    voldat(ind,:) = [];
    h = plot(voldat(:,1),voldat(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
if ~isempty(tbshift)
    xlim = get(gca,'xlim');
    xtick = [xlim(1):4*3600:xlim(2)];
    xticklabel = round(xtick/3600);
    set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
    xlabel('','fontweight','bold')
else
    xlabel('Time','fontweight','bold');
end
ylabel('Amplitude (log)','fontweight','bold')

subtightplot(3,1,3,0.07,0.08,0.15);hold on;
h = plot(entdat(:,1),entdat(:,2),marker);hold on
if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end
while removeoutliers == 'y'
    nstd = input('standard devs:');
    delete(h)
    ind = jc_findoutliers(entdat(:,2),nstd);
    entdat(ind,:) = [];
    h = plot(entdat(:,1),entdat(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
if ~isempty(tbshift)
    xlim = get(gca,'xlim');
    xtick = [xlim(1):4*3600:xlim(2)];
    xticklabel = round(xtick/3600);
    set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
    xlabel('Time in hours since 7 AM','fontweight','bold');
else
    xlabel('','fontweight','bold');
end
ylabel('Entropy','fontweight','bold');