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
trigind = find(trig==1 & catchtrig==0);
catchind = find(catchtrig==1 | catchtrig==-1);
% trigind = find(trig==1 & (catchtrig==-1 | catchtrig==0));
% catchind = setdiff([1:length(motifinfo)],trigind);

if ~isempty(trigind)
    trigmotifdur = [[motifinfo(trigind).datenm]',[motifinfo(trigind).motifdur]'];
    trigsylldur = [[motifinfo(trigind).datenm]',arrayfun(@(x) mean(x.durations),motifinfo(trigind))'];
    triggapdur = [[motifinfo(trigind).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo(trigind))'];
    trigfirstpeakdistance = [[motifinfo(trigind).datenm]' [motifinfo(trigind).firstpeakdistance]'];
end
if ~isempty(catchind)
    catchmotifdur = [[motifinfo(catchind).datenm]',[motifinfo(catchind).motifdur]'];
    catchsylldur = [[motifinfo(catchind).datenm]',arrayfun(@(x) mean(x.durations),motifinfo(catchind))'];
    catchgapdur = [[motifinfo(catchind).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo(catchind))'];
    catchfirstpeakdistance = [[motifinfo(catchind).datenm]' [motifinfo(catchind).firstpeakdistance]'];
end

if ~isempty(tbshift) 
    if ~isempty(trigind)
        trigmotifdur(:,1) = jc_tb(trigmotifdur(:,1),7,0)+(tbshift*24*3600);
        trigsylldur(:,1) = jc_tb(trigsylldur(:,1),7,0)+(tbshift*24*3600);
        triggapdur(:,1) = jc_tb(triggapdur(:,1),7,0)+(tbshift*24*3600);
        trigfirstpeakdistance(:,1) = jc_tb(trigfirstpeakdistance(:,1),7,0)+(tbshift*24*3600);
    end
    if ~isempty(catchind)
        catchmotifdur(:,1) = jc_tb(catchmotifdur(:,1),7,0)+(tbshift*24*3600);
        catchsylldur(:,1) = jc_tb(catchsylldur(:,1),7,0)+(tbshift*24*3600);
        catchgapdur(:,1) = jc_tb(catchgapdur(:,1),7,0)+(tbshift*24*3600);
        catchfirstpeakdistance(:,1) = jc_tb(catchfirstpeakdistance(:,1),7,0)+(tbshift*24*3600);
    end
end

if removeoutliers == 'y'
    nstd = 4;
    if ~isempty(trigind)
        trigmotifdur = jc_removeoutliers(trigmotifdur,nstd,1);
        trigsylldur = jc_removeoutliers(trigsylldur,nstd,1);
        triggapdur = jc_removeoutliers(triggapdur,nstd,1);
        trigfirstpeakdistance = jc_removeoutliers(trigfirstpeakdistance,nstd,1);
    end
    if ~isempty(catchind)
        catchmotifdur = jc_removeoutliers(catchmotifdur,nstd,1);
        catchsylldur = jc_removeoutliers(catchsylldur,nstd,1);
        catchgapdur = jc_removeoutliers(catchgapdur,nstd,1);
        catchfirstpeakdistance = jc_removeoutliers(catchfirstpeakdistance,nstd,1);
    end
end

%% motif duration
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    plot(trigmotifdur(:,1),trigmotifdur(:,2),'r.');hold on
    [hi lo mn] = mBootstrapCI(trigmotifdur(:,2));
    plot(mean(trigmotifdur(:,1))+std(trigmotifdur(:,1)),mn,'o','color',[0.7 0.3 0.3],'markersize',8,'linewidth',4);hold on;
    plot([mean(trigmotifdur(:,1)) mean(trigmotifdur(:,1))]+std(trigmotifdur(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchmotifdur(:,1),catchmotifdur(:,2),'k.');hold on;
    [hi lo mn] = mBootstrapCI(catchmotifdur(:,2));
    plot(mean(catchmotifdur(:,1))-std(catchmotifdur(:,1)),mn,'o','color',[0.5 0.5 0.5],'markersize',8,'linewidth',4);hold on;
    plot([mean(catchmotifdur(:,1)) mean(catchmotifdur(:,1))]-std(catchmotifdur(:,1)),[hi lo],'k','linewidth',4);
end
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
    [hi lo mn] = mBootstrapCI(trigsylldur(:,2));
    plot(mean(trigsylldur(:,1))+std(trigsylldur(:,1)),mn,'o','color',[0.7 0.3 0.3],'markersize',8,'linewidth',4);hold on;
    plot([mean(trigsylldur(:,1)) mean(trigsylldur(:,1))]+std(trigsylldur(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchsylldur(:,1),catchsylldur(:,2),'k.');hold on
    [hi lo mn] = mBootstrapCI(catchsylldur(:,2));
    plot(mean(catchsylldur(:,1))-std(catchsylldur(:,1)),mn,'o','color',[0.5 0.5 0.5],'markersize',8,'linewidth',4);hold on;
    plot([mean(catchsylldur(:,1)) mean(catchsylldur(:,1))]-std(catchsylldur(:,1)),[hi lo],'k','linewidth',4);
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
if ~isempty(trigind)
    plot(triggapdur(:,1),triggapdur(:,2),'r.');hold on
    [hi lo mn] = mBootstrapCI(triggapdur(:,2));
    plot(mean(triggapdur(:,1))+std(triggapdur(:,1)),mn,'o','color',[0.7 0.3 0.3],'markersize',8,'linewidth',4);hold on;
    plot([mean(triggapdur(:,1)) mean(triggapdur(:,1))]+std(triggapdur(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchgapdur(:,1),catchgapdur(:,2),'k.');hold on
    [hi lo mn] = mBootstrapCI(catchgapdur(:,2));
    plot(mean(catchgapdur(:,1))-std(catchgapdur(:,1)),mn,'o','color',[0.5 0.5 0.5],'markersize',8,'linewidth',4);hold on;
    plot([mean(catchgapdur(:,1)) mean(catchgapdur(:,1))]-std(catchgapdur(:,1)),[hi lo],'k','linewidth',4);
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
if ~isempty(trigind)
    plot(trigfirstpeakdistance(:,1),trigfirstpeakdistance(:,2),'r.');hold on;
    [hi lo mn] = mBootstrapCI(trigfirstpeakdistance(:,2));
    plot(mean(trigfirstpeakdistance(:,1))+std(trigfirstpeakdistance(:,1)),mn,'o','color',[0.7 0.3 0.3],'markersize',8,'linewidth',4);hold on;
    plot([mean(trigfirstpeakdistance(:,1)) mean(trigfirstpeakdistance(:,1))]+std(trigfirstpeakdistance(:,1)),[hi lo],'r','linewidth',4);
end
if ~isempty(catchind)
    plot(catchfirstpeakdistance(:,1),catchfirstpeakdistance(:,2),'k.');hold on;
    [hi lo mn] = mBootstrapCI(catchfirstpeakdistance(:,2));
    plot(mean(catchfirstpeakdistance(:,1))-std(catchfirstpeakdistance(:,1)),mn,'o','color',[0.5 0.5 0.5],'markersize',8,'linewidth',4);hold on;
    plot([mean(catchfirstpeakdistance(:,1)) mean(catchfirstpeakdistance(:,1))]-std(catchfirstpeakdistance(:,1)),[hi lo],'k','linewidth',4);
end
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
    trigsm = jc_getsm(motifinfo(trigind),fs);
    trigtime = cell2mat(arrayfun(@(x) x.trigtime-x.ons,motifinfo(trigind),'unif',0)');
    trig_on_off = [mean(trigtime) mean(trigtime)+lightdur]./1e3;
    trigsm.tm = (trigsm.tm/fs)-0.016;%to account for buffer in findmotifs
    figure;hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2),'r');hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2)+nanstderr(log(trigsm.sm),2),'r');hold on;
    plot(trigsm.tm,nanmean(log(trigsm.sm),2)-nanstderr(log(trigsm.sm),2),'r');hold on;
    
    if ~isempty(catchind)
        catchsm = jc_getsm(motifinfo(catchind),fs);
        catchsm.tm = (catchsm.tm/fs)-0.016;%to account for buffer in findmotifs
        plot(catchsm.tm,nanmean(log(catchsm.sm),2),'k');hold on;
        plot(catchsm.tm,nanmean(log(catchsm.sm),2)+nanstderr(log(catchsm.sm),2),'k');hold on;
        plot(catchsm.tm,nanmean(log(catchsm.sm),2)-nanstderr(log(catchsm.sm),2),'k');hold on;
        text(0,1,[num2str(100*length(trigind)/(length(catchind)+length(trigind))),'%triggered'],'units','normalized');
    end
    y = get(gca,'ylim');
    plot(trig_on_off,[y(2) y(2)],'b','linewidth',4);hold on;
    xlabel('time (s)');ylabel('amplitude');
    title([motif,':',trialname],'interpreter','none');
    set(gca,'fontweight','bold');
end