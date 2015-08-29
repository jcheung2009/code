function jc_plotrawdata(fv,marker)
%fv from jc_findwnote5
pitchdat = [[fv(:).datenm]',[fv(:).mxvals]'];
voldat = [[fv(:).datenm]',log([fv(:).maxvol]')];
entdat = [[fv(:).datenm]',[fv(:).spent]'];

fignum = input('figure number for raw data:');
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.05,0.1);hold on;
h = plot(pitchdat(:,1),pitchdat(:,2),marker);hold on
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('standard devs:');
    delete(h)
    ind = jc_findoutliers(pitchdat(:,2),nstd);
    pitchdat(ind,:) = [];
    h = plot(pitchdat(:,1),pitchdat(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlabel('Time')
ylabel('Frequency (Hz)')

subtightplot(3,1,2,0.07,0.05,0.1);hold on;
h = plot(voldat(:,1),voldat(:,2),marker);hold on
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('standard devs:');
    delete(h)
    ind = jc_findoutliers(voldat(:,2),nstd);
    voldat(ind,:) = [];
    h = plot(voldat(:,1),voldat(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlabel('Time')
ylabel('Amplitude (log)')

subtightplot(3,1,3,0.07,0.05,0.1);hold on;
h = plot(entdat(:,1),entdat(:,2),marker);hold on
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('standard devs:');
    delete(h)
    ind = jc_findoutliers(entdat(:,2),nstd);
    entdat(ind,:) = [];
    h = plot(entdat(:,1),entdat(:,2),marker);hold on;
    removeoutliers = input('remove outliers?:','s');
end
xlabel('Time');
ylabel('Entropy');