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
trigind = find(trig==1 & (catchtrig==-1 | catchtrig==0));
catchind = setdiff([1:length(fv)],trigind);

if ~isempty(trigind)
    trigpitch = [[fv(trigind).datenm]',[fv(trigind).mxvals]'];
    trigvol = [[fv(trigind).datenm]',log([fv(trigind).maxvol]')];
    trigent = [[fv(trigind).datenm]',[fv(trigind).spent]'];
end
catchpitch = [[fv(catchind).datenm]',[fv(catchind).mxvals]'];
catchvol = [[fv(catchind).datenm]',log([fv(catchind).maxvol]')];
catchent = [[fv(catchind).datenm]',[fv(catchind).spent]'];

if ~isempty(tbshift)
    if ~isempty(trigind)
        trigpitch(:,1) = jc_tb(trigpitch(:,1),7,0)+(tbshift*24*3600);
        trigvol(:,1) = jc_tb(trigvol(:,1),7,0)+(tbshift*24*3600);
        trigent(:,1) = jc_tb(trigent(:,1),7,0)+(tbshift*24*3600);
    end
    catchpitch(:,1) = jc_tb(catchpitch(:,1),7,0)+(tbshift*24*3600);
    catchvol(:,1) = jc_tb(catchvol(:,1),7,0)+(tbshift*24*3600);
    catchent(:,1) = jc_tb(catchent(:,1),7,0)+(tbshift*24*3600);
end

if removeoutliers == 'y'
    nstd = 4;
    if ~isempty(trigind)
        trigpitch = jc_removeoutliers(trigpitch,nstd,1);
        trigvol = jc_removeoutliers(trigvol,nstd,1);
        trigent = jc_removeoutliers(trigent,nstd,1);
    end
    catchpitch = jc_removeoutliers(catchpitch,nstd,1);
    catchvol = jc_removeoutliers(catchvol,nstd,1);
    catchent = jc_removeoutliers(catchent,nstd,1);
end

%% pitch
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigpitch(:,1),trigpitch(:,2),'r.');hold on
end
plot(catchpitch(:,1),catchpitch(:,2),'k.');hold on
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
end
plot(catchvol(:,1),catchvol(:,2),'k.');hold on
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
end
plot(catchent(:,1),catchent(:,2),'k.');hold on

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
    catchpc = jc_getpc(fv(catchind));
    trigtime = cell2mat(arrayfun(@(x) x.trigtime-x.ons,fv(trigind),'unif',0)');
    trig_on_off = [mean(trigtime) mean(trigtime)+lightdur]./1e3;
    
    figure;hold on;
    plot(catchpc.tm,nanmean(catchpc.pc,2),'k');hold on;
    plot(catchpc.tm,nanmean(catchpc.pc,2)+nanstderr(catchpc.pc,2),'k');hold on;
    plot(catchpc.tm,nanmean(catchpc.pc,2)-nanstderr(catchpc.pc,2),'k');hold on;
    plot(trigpc.tm,nanmean(trigpc.pc,2),'r');hold on;
    plot(trigpc.tm,nanmean(trigpc.pc,2)+nanstderr(trigpc.pc,2),'r');hold on;
    plot(trigpc.tm,nanmean(trigpc.pc,2)-nanstderr(trigpc.pc,2),'r');hold on;
    y = get(gca,'ylim');
    plot(trig_on_off,[y(2) y(2)],'b','linewidth',4);hold on;
    xlabel('time (s)');ylabel('frequency (hz)');
    title([syllable,':',trialname],'interpreter','none');
    set(gca,'fontweight','bold');
    
    trigsm = jc_getsm(fv(trigind));
    catchsm = jc_getsm(fv(catchind));
    trigsm.tm = (trigsm.tm/fs)-0.016;%to account for buffer in findmotifs
    catchsm.tm = (catchsm.tm/fs)-0.016;%to account for buffer in findmotifs
    figure;hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2),'r');hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2)+nanstderr(log(trigsm.sm),2),'r');hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2)-nanstderr(log(trigsm.sm),2),'r');hold on;
    plot(catchsm.tm,nanmean(log(catchsm.sm),2),'k');hold on;
    plot(catchsm.tm,nanmean(log(catchsm.sm),2)+nanstderr(log(catchsm.sm),2),'k');hold on;
    plot(catchsm.tm,nanmean(log(catchsm.sm),2)-nanstderr(log(catchsm.sm),2),'k');hold on;
    y = get(gca,'ylim');
    plot(trig_on_off,[y(2) y(2)],'b','linewidth',4);hold on;
    xlabel('time (s)');ylabel('amplitude');
    title([syllable,':',trialname],'interpreter','none');
    set(gca,'fontweight','bold');
    
end
