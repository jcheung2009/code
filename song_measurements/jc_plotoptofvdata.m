function jc_plotoptofvdata(fv,tbshift,noteparams,trialparams,fignum,params)
%plots raw spectral information from fvstruct in script_findwnote2/jc_findwnote5
%for optogenetics experiments
syllable = [noteparams.prenotes,upper(noteparams.syllable),noteparams.postnotes];
removeoutliers = params.removeoutliers;

if isempty(fignum)
    fignum = input('figure number for raw data:');
end

trig = [fv(:).TRIG]';
catchtrig = [fv(:).CATCH]';
trigind = find(trig==1 & catchtrig==0);
catchind = find(catchtrig==1);
%trigind = find(trig==1 & (catchtrig==-1 | catchtrig==0));
%catchind = setdiff([1:length(fv)],trigind);

if ~isempty(trigind)
    trigpitch = [[fv(trigind).datenm]',[fv(trigind).mxvals]'];
    trigvol = [[fv(trigind).datenm]',log([fv(trigind).maxvol]')];
    trigent = [[fv(trigind).datenm]',[fv(trigind).spent]'];
end
if ~isempty(catchind)
    catchpitch = [[fv(catchind).datenm]',[fv(catchind).mxvals]'];
    catchvol = [[fv(catchind).datenm]',log([fv(catchind).maxvol]')];
    catchent = [[fv(catchind).datenm]',[fv(catchind).spent]'];
end

if ~isempty(tbshift)
    if ~isempty(trigind)
        trigpitch(:,1) = jc_tb(trigpitch(:,1),7,0)+(tbshift*24*3600);
        trigvol(:,1) = jc_tb(trigvol(:,1),7,0)+(tbshift*24*3600);
        trigent(:,1) = jc_tb(trigent(:,1),7,0)+(tbshift*24*3600);
    end
    if ~isempty(catchind)
        catchpitch(:,1) = jc_tb(catchpitch(:,1),7,0)+(tbshift*24*3600);
        catchvol(:,1) = jc_tb(catchvol(:,1),7,0)+(tbshift*24*3600);
        catchent(:,1) = jc_tb(catchent(:,1),7,0)+(tbshift*24*3600);
    end
end

if removeoutliers == 'y'
    nstd = 4;
    if ~isempty(trigind)
        trigpitch = jc_removeoutliers(trigpitch,nstd,1);
        trigvol = jc_removeoutliers(trigvol,nstd,1);
        trigent = jc_removeoutliers(trigent,nstd,1);
    end
    if ~isempty(catchind)
        catchpitch = jc_removeoutliers(catchpitch,nstd,1);
        catchvol = jc_removeoutliers(catchvol,nstd,1);
        catchent = jc_removeoutliers(catchent,nstd,1);
    end
end

%% pitch
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigpitch(:,1),trigpitch(:,2),'r.');hold on
    [hi lo mn] = mBootstrapCI(trigpitch(:,2));
    plot(mean(trigpitch(:,1))+std(trigpitch(:,1)),mn,'or','markersize',8,'linewidth',4);hold on;
    plot([mean(trigpitch(:,1)) mean(trigpitch(:,1))]+std(trigpitch(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchpitch(:,1),catchpitch(:,2),'k.');hold on
    [hi lo mn] = mBootstrapCI(catchpitch(:,2));
    plot(mean(catchpitch(:,1))-std(catchpitch(:,1)),mn,'ok','markersize',8,'linewidth',4);hold on;
    plot([mean(catchpitch(:,1)) mean(catchpitch(:,1))]-std(catchpitch(:,1)),[hi lo],'k','linewidth',4);
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
subtightplot(3,1,2,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigvol(:,1),trigvol(:,2),'r.');hold on
    [hi lo mn] = mBootstrapCI(trigvol(:,2));
    plot(mean(trigvol(:,1))+std(trigvol(:,1)),mn,'or','markersize',8,'linewidth',4);hold on;
    plot([mean(trigvol(:,1)) mean(trigvol(:,1))]+std(trigvol(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchvol(:,1),catchvol(:,2),'k.');hold on
    [hi lo mn] = mBootstrapCI(catchvol(:,2));
    plot(mean(catchvol(:,1))-std(catchvol(:,1)),mn,'ok','markersize',8,'linewidth',4);hold on;
    plot([mean(catchvol(:,1)) mean(catchvol(:,1))]-std(catchvol(:,1)),[hi lo],'k','linewidth',4);
end
if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold')
else
    xlabel('Time','fontweight','bold');
end
ylabel('Log Amplitude','fontweight','bold')

%% entropy
subtightplot(3,1,3,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigent(:,1),trigent(:,2),'r.');hold on
    [hi lo mn] = mBootstrapCI(trigent(:,2));
    plot(mean(trigent(:,1))+std(trigent(:,1)),mn,'or','markersize',8,'linewidth',4);hold on;
    plot([mean(trigent(:,1)) mean(trigent(:,1))]+std(trigent(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchent(:,1),catchent(:,2),'k.');hold on
    [hi lo mn] = mBootstrapCI(catchent(:,2));
    plot(mean(catchent(:,1))-std(catchent(:,1)),mn,'ok','markersize',8,'linewidth',4);hold on;
    plot([mean(catchent(:,1)) mean(catchent(:,1))]-std(catchent(:,1)),[hi lo],'k','linewidth',4);
end

if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Entropy','fontweight','bold');

%% pitch contours
if ~isempty(trigind)
    fs = params.fs;
    trialname = trialparams.name;
    lightdur = trialparams.fbdur;
    trigpc = jc_getpc(fv(trigind));
    trigtime = cell2mat(arrayfun(@(x) x.trigtime-x.ons,fv(trigind),'unif',0)');
    trig_on_off = [mean(trigtime) mean(trigtime)+lightdur]./1e3;
    figure;hold on;
    plot(trigpc.tm,nanmean(trigpc.pc,2),'r');hold on;
    plot(trigpc.tm,nanmean(trigpc.pc,2)+nanstderr(trigpc.pc,2),'r');hold on;
    plot(trigpc.tm,nanmean(trigpc.pc,2)-nanstderr(trigpc.pc,2),'r');hold on;
    
    if ~isempty(catchind)
        catchpc = jc_getpc(fv(catchind));
        plot(catchpc.tm,nanmean(catchpc.pc,2),'k');hold on;
        plot(catchpc.tm,nanmean(catchpc.pc,2)+nanstderr(catchpc.pc,2),'k');hold on;
        plot(catchpc.tm,nanmean(catchpc.pc,2)-nanstderr(catchpc.pc,2),'k');hold on;
        text(0,1,[num2str(100*length(trigind)/(length(catchind)+length(trigind))),'%triggered'],'units','normalized');
    end
    
    y = get(gca,'ylim');
    plot(trig_on_off,[y(2) y(2)],'b','linewidth',4);hold on;
    xlabel('time (s)');ylabel('frequency (hz)');
    title([syllable,':',trialname],'interpreter','none');
    set(gca,'fontweight','bold');
    
    trigsm = jc_getsm(fv(trigind));
    trigsm.tm = (trigsm.tm/fs)-0.016;%to account for buffer in findmotifs
    figure;hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2),'r');hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2)+nanstderr(log(trigsm.sm),2),'r');hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2)-nanstderr(log(trigsm.sm),2),'r');hold on;
    
    if ~isempty(catchind)
        catchsm = jc_getsm(fv(catchind));
        catchsm.tm = (catchsm.tm/fs)-0.016;%to account for buffer in findmotifs
        plot(catchsm.tm,nanmean(log(catchsm.sm),2),'k');hold on;
        plot(catchsm.tm,nanmean(log(catchsm.sm),2)+nanstderr(log(catchsm.sm),2),'k');hold on;
        plot(catchsm.tm,nanmean(log(catchsm.sm),2)-nanstderr(log(catchsm.sm),2),'k');hold on;
        text(0,1,[num2str(100*length(trigind)/(length(catchind)+length(trigind))),'%triggered'],'units','normalized');
    end
    y = get(gca,'ylim');
    plot(trig_on_off,[y(2) y(2)],'b','linewidth',4);hold on;
    xlabel('time (s)');ylabel('amplitude');
    title([syllable,':',trialname],'interpreter','none');
    set(gca,'fontweight','bold');
    
end
