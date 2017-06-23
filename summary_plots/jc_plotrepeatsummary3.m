function rep = jc_plotrepeatsummary3(fv_rep_sal,fv_rep_cond,...
    repeat,params,trialparams,fignum)
%plot summary for repeats
conditions=params.conditions;
base = params.baseepoch;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));

%exclude wash-in and match time of day
tb_sal = jc_tb([fv_rep_sal(:).datenm]',7,0);
tb_cond = jc_tb([fv_rep_cond(:).datenm]',7,0);
if isempty(treattime)
    start_time = tb_cond(1)+3600;
else
    start_time = time2datenum(treattime) + 3600;%1 hr buffer
end
ind = find(tb_cond > start_time);
tb_cond=tb_cond(ind);
runlength2 = [fv_rep_cond(ind).runlength]';
acorr2 = [fv_rep_cond(ind).firstpeakdistance]';
meangapdur2 = arrayfun(@(x) mean(x.syllgaps),fv_rep_cond(ind))';
meansylldur2 = arrayfun(@(x) mean(x.sylldurations),fv_rep_cond(ind))';
if ~strcmp(base,'morn')
    ind = find(tb_sal >= tb_cond(1));
else
    ind = 1:length(tb_sal);
end
tb_sal = tb_sal(ind);
runlength = [fv_rep_sal(ind).runlength]';
acorr = [fv_rep_sal(ind).firstpeakdistance]';
meangapdur = arrayfun(@(x) mean(x.syllgaps),fv_rep_sal(ind))';
meansylldur = arrayfun(@(x) mean(x.sylldurations),fv_rep_sal(ind))';

%remove outliers
if strcmp(removeoutliers,'y')
    nstd = 4;
    acorr = jc_removeoutliers(acorr,nstd);
    acorr2 = jc_removeoutliers(acorr2,nstd);
    meangapdur = jc_removeoutliers(meangapdur,nstd);
    meangapdur2 = jc_removeoutliers(meangapdur2,nstd);
    meansylldur = jc_removeoutliers(meansylldur,nstd);
    meansylldur2 = jc_removeoutliers(meansylldur2,nstd);
end

%remove nan
acorr=jc_removenan(acorr);
acorr2 = jc_removenan(acorr2);
meangapdur=jc_removenan(meangapdur);
meangapdur2=jc_removenan(meangapdur2);
meansylldur=jc_removenan(meansylldur);
meansylldur2=jc_removenan(meansylldur2);

%distributions
% figure;hold on;
% h1 = subtightplot(4,1,1,[0.07 0.05],0.08,0.12);
% h2 = subtightplot(4,1,2,[0.07 0.05],0.08,0.12);
% h3 = subtightplot(4,1,3,[0.07 0.05],0.08,0.12);
% h4 = subtightplot(4,1,4,[0.07 0.05],0.08,0.12);
h1='';h2='';h3='';h4='';
runlength_pval = plot_distribution(h1,runlength,runlength2,linecolor);
if ~isempty(acorr) && ~isempty(acorr2)
    acorr_pval = plot_distribution(h2,acorr,acorr2,linecolor);
else
    acorr_pval = NaN;
end
meansylldur_pval = plot_distribution(h3,meansylldur,meansylldur2,linecolor);
meangapdur_pval = plot_distribution(h4,meangapdur,meangapdur2,linecolor);
% xlabel(h1,'repeat length');xlabel(h2,'interval duration (s)');
% xlabel(h3,'mean syllable duration (s)');xlabel(h4,'mean gap duration (s)');
% title(h1,[repeat,':',trialname],'interpreter','none');

%z-score and summary plot
runlengthn = (runlength2-mean(runlength))./std(runlength);
acorrn = (acorr2-mean(acorr))./std(acorr);
meansylldurn = (meansylldur2-mean(meansylldur))./std(meansylldur);
meangapdurn = (meangapdur2-mean(meangapdur))./std(meangapdur);
figure(fignum);hold on;
h1 = subtightplot(4,1,1,[0.07 0.05],0.08,0.15);
h2 = subtightplot(4,1,2,[0.07 0.05],0.08,0.15);
h3 = subtightplot(4,1,3,[0.07 0.05],0.08,0.15);
h4 = subtightplot(4,1,4,[0.07 0.05],0.08,0.15);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
runlength_zsc = plot_zscore_bootstrap(h1,xpt,runlengthn,marker,linecolor,conditions,'mn');
title(h1,'repeat length');
if ~isnan(acorrn)
    acorr_zsc = plot_zscore_bootstrap(h2,xpt,acorrn,marker,linecolor,conditions,'mn');
else
    acorr_zsc = NaN;
end
title(h2,'interval duration');
meansylldur_zsc = plot_zscore_bootstrap(h3,xpt,meansylldurn,marker,linecolor,conditions,'mn');
title(h3,'mean syllable duration');
meangapdur_zsc = plot_zscore_bootstrap(h4,xpt,meangapdurn,marker,linecolor,conditions,'mn');
title(h4,'mean gap duration');

%percent change
runlength_percent = 100*(mean(runlength2)-mean(runlength))/mean(runlength);
acorr_percent = 100*(mean(acorr2)-mean(acorr))/mean(acorr);
meansylldur_percent = 100*(mean(meansylldur2)-mean(meansylldur))/mean(meansylldur);
meangapdur_percent = 100*(mean(meangapdur2)-mean(meangapdur))/mean(meangapdur);

%absolute change
runlength_abs = mean(runlength2)-mean(runlength);
acorr_abs = mean(acorr2)-mean(acorr);
meansylldur_abs = mean(meansylldur2)-mean(meansylldur);
meangapdur_abs = mean(meangapdur2)-mean(meangapdur);

rep.trialname = trialname;
rep.condition = trialparams.condition;
rep.runlength.mean = [mean(runlength) mean(runlength2)];
rep.runlength.std = [std(runlength) std(runlength2)];
rep.runlength.abs = runlength_abs;
rep.runlength.percent = runlength_percent;
rep.runlength.zsc = runlength_zsc;
rep.runlength.pval = runlength_pval;
rep.acorr.mean = [mean(acorr) mean(acorr2)];
rep.acorr.std = [std(acorr) std(acorr2)];
rep.acorr.abs = acorr_abs;
rep.acorr.percent = acorr_percent;
rep.acorr.zsc = acorr_zsc;
rep.meansylldur.mean = [mean(meansylldur) mean(meansylldur2)];
rep.meansylldur.std = [std(meansylldur) std(meansylldur2)];
rep.meansylldur.abs = meansylldur_abs;
rep.meansylldur.percent = meansylldur_percent;
rep.meansylldur.zsc = meansylldur_zsc;
rep.meangapdur.mean = [mean(meangapdur) mean(meangapdur2)];
rep.meangapdur.std = [std(meangapdur) std(meangapdur2)];
rep.meangapdur.abs = meangapdur_abs;
rep.meangapdur.percent = meangapdur_percent;
rep.meangapdur.zsc = meangapdur_zsc;
