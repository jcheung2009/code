function jc_plotoptomotifvals(motifinfo,tbshift,motifparams,trialparams,fignum,fignum2,params);
%plot raw motif tempo values in motifstruct for script_plotdata
%for optogenetics experiments
motif = motifparams.motif;
removeoutliers = params.removeoutliers;

if isempty(fignum)
    fignum = input('figure number for plotting motif vals:');
end
if isempty(fignum2)
    fignum2 = input('figure for acorr:');
end

trig = [motifinfo(:).TRIG];
catchtrig = [motifinfo(:).CATCH];
trigind = find(trig==1 & (catchtrig==-1 | catchtrig==0));
catchind = setdiff([1:length(motifinfo)],trigind);

if ~isempty(trigind)
    trigmotifdur = [[motifinfo(trigind).datenm]',[motifinfo(trigind).motifdur]'];
    trigsylldur = [[motifinfo(trigind).datenm]',arrayfun(@(x) mean(x.durations),motifinfo(trigind))'];
    triggapdur = [[motifinfo(trigind).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo(trigind))'];
    trigfirstpeakdistance = [[motifinfo(trigind).datenm]' [motifinfo(trigind).firstpeakdistance]'];
end
catchmotifdur = [[motifinfo(catchind).datenm]',[motifinfo(catchind).motifdur]'];
catchsylldur = [[motifinfo(catchind).datenm]',arrayfun(@(x) mean(x.durations),motifinfo(catchind))'];
catchgapdur = [[motifinfo(catchind).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo(catchind))'];
catchfirstpeakdistance = [[motifinfo(catchind).datenm]' [motifinfo(catchind).firstpeakdistance]'];

if ~isempty(tbshift) 
    if ~isempty(trigind)
        trigmotifdur(:,1) = jc_tb(trigmotifdur(:,1),7,0)+(tbshift*24*3600);
        trigsylldur(:,1) = jc_tb(trigsylldur(:,1),7,0)+(tbshift*24*3600);
        triggapdur(:,1) = jc_tb(triggapdur(:,1),7,0)+(tbshift*24*3600);
        trigfirstpeakdistance(:,1) = jc_tb(trigfirstpeakdistance(:,1),7,0)+(tbshift*24*3600);
    end
    catchmotifdur(:,1) = jc_tb(catchmotifdur(:,1),7,0)+(tbshift*24*3600);
    catchsylldur(:,1) = jc_tb(catchsylldur(:,1),7,0)+(tbshift*24*3600);
    catchgapdur(:,1) = jc_tb(catchgapdur(:,1),7,0)+(tbshift*24*3600);
    catchfirstpeakdistance(:,1) = jc_tb(catchfirstpeakdistance(:,1),7,0)+(tbshift*24*3600);
end

if removeoutliers == 'y'
    nstd = 4;
    if ~isempty(trigind)
        trigmotifdur = jc_removeoutliers(trigmotifdur,nstd,1);
        trigsylldur = jc_removeoutliers(trigsylldur,nstd,1);
        triggapdur = jc_removeoutliers(triggapdur,nstd,1);
        trigfirstpeakdistance = jc_removeoutliers(trigfirstpeakdistance,nstd,1);
    end
    catchmotifdur = jc_removeoutliers(catchmotifdur,nstd,1);
    catchsylldur = jc_removeoutliers(catchsylldur,nstd,1);
    catchgapdur = jc_removeoutliers(catchgapdur,nstd,1);
    catchfirstpeakdistance = jc_removeoutliers(catchfirstpeakdistance,nstd,1);
end

%% motif duration
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigmotifdur(:,1),trigmotifdur(:,2),'r.');hold on
end
plot(catchmotifdur(:,1),catchmotifdur(:,2),'k.');hold on;
if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Duration (seconds)','fontweight','bold');
title([motif,': duration']);

%% syll duration
subtightplot(3,1,2,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigsylldur(:,1),trigsylldur(:,2),'r.');hold on
end
plot(catchsylldur(:,1),catchsylldur(:,2),'k.');hold on
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
if ~isempty(trigind)
    plot(triggapdur(:,1),triggapdur(:,2),'r.');hold on
end
plot(catchgapdur(:,1),catchgapdur(:,2),'k.');hold on
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
if ~isempty(trigind)
    plot(trigfirstpeakdistance(:,1),trigfirstpeakdistance(:,2),'r.');hold on;
end
plot(catchfirstpeakdistance(:,1),catchfirstpeakdistance(:,2),'k.');hold on;
if~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Duration (seconds)');
title([motif,':interval duration (autocorrelation)']);

%% amplitude env
if ~isempty(trialparams)
    trialname=trialparams.name;
    lightdur = trialparams.fbdur;
    fs = params.fs;
    trigsm = jc_getsm(motifinfo(trigind));
    catchsm = jc_getsm(motifinfo(catchind));
    trigtime = cell2mat(arrayfun(@(x) x.trigtime-x.ons,motifinfo(trigind),'unif',0)');
    trig_on_off = [mean(trigtime) mean(trigtime)+lightdur]./1e3;
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
    title([motif,':',trialname],'interpreter','none');
    set(gca,'fontweight','bold');
end