function jc_plotrawdata(fv,marker,tbshift)
%fv from jc_findwnote5
pitchdat = [[fv(:).datenm]',[fv(:).mxvals]'];
voldat = [[fv(:).datenm]',log([fv(:).maxvol]')];
entdat = [[fv(:).datenm]',[fv(:).spent]'];

changetb = input('change time to seconds from day start:','s');
if changetb == 'y'
    if tbshift == -1
        pitchdat(:,1) = jc_tb(pitchdat(:,1),7,0)-(24*3600);
        voldat(:,1) = jc_tb(voldat(:,1),7,0)-(24*3600);
        entdat(:,1) = jc_tb(entdat(:,1),7,0)-(24*3600);
        xticklabel = [-24:4:38];
    elseif tbshift == 1
        pitchdat(:,1) = jc_tb(pitchdat(:,1),7,0)+(24*3600);
        voldat(:,1) = jc_tb(voldat(:,1),7,0)+(24*3600);
        entdat(:,1) = jc_tb(entdat(:,1),7,0)+(24*3600);
        xticklabel = [-24:4:38];
    elseif tbshift == 0
        pitchdat(:,1) = jc_tb(pitchdat(:,1),7,0);
        voldat(:,1) = jc_tb(voldat(:,1),7,0);
        entdat(:,1) = jc_tb(entdat(:,1),7,0);
        xticklabel = [-24:4:38];
    end
    xtick = xticklabel*3600;
    xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);
end

fignum = input('figure number for raw data:');
figure(fignum);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
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
if changetb == 'y'
    set(gca,'xtick',xtick,'xticklabel',xticklabel);
    xlabel('');
else
   xlabel('Time') 
end

ylabel('Frequency (Hz)')

subtightplot(2,1,2,0.07,0.08,0.15);hold on;
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
if changetb == 'y'
    set(gca,'xtick',xtick,'xticklabel',xticklabel);
    xlabel('')
else
    xlabel('Time');
end
ylabel('Amplitude (log)')

% subtightplot(3,1,3,0.07,0.08,0.15);hold on;
% h = plot(entdat(:,1),entdat(:,2),marker);hold on
% removeoutliers = input('remove outliers?:','s');
% while removeoutliers == 'y'
%     nstd = input('standard devs:');
%     delete(h)
%     ind = jc_findoutliers(entdat(:,2),nstd);
%     entdat(ind,:) = [];
%     h = plot(entdat(:,1),entdat(:,2),marker);hold on;
%     removeoutliers = input('remove outliers?:','s');
% end
% if changetb == 'y'
%     set(gca,'xtick',xtick,'xticklabel',xticklabel);
%     xlabel('Time in hours since 7 AM');
% else
%     xlabel('');
% end
% ylabel('Entropy');