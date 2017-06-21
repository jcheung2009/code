function err = jc_ploterrorsummary(fv_pre,fv_post,syllable,params,trialparams,fignum);
%summary plot of pitch on morning before drug and morning after 

conditions=params.conditions;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));

%exclude wash-in and match time of day
tb_pre = jc_tb([fv_pre(:).datenm]',7,0)/3600;
tb_post = jc_tb([fv_post(:).datenm]',7,0)/3600;
ind = find(tb_pre <= 5);%before noon
tb_pre=tb_pre(ind);
pitch_pre = [fv_pre(ind).mxvals]';
ind = find(tb_post <= 5);
tb_post = tb_post(ind);
pitch_post = [fv_post(ind).mxvals]';
if isempty(tb_pre) | isempty(tb_post)
    err.trialname = trialname;
    err.condition = trialparams.condition;
    err.pitch.mean = NaN;
    err.pitch.std = NaN;
    err.pitch.abs = NaN;
    err.pitch.percent = NaN;
    err.pitch.zsc = NaN; 
    err.pitch.pval = NaN;
    return
end

%remove outliers
if strcmp(removeoutliers,'y')
    nstd=4;
    pitch_pre = jc_removeoutliers(pitch_pre,nstd);
    pitch_post = jc_removeoutliers(pitch_post,nstd);
end

%remove nan
pitch_pre =jc_removenan(pitch_pre);
pitch_post =jc_removenan(pitch_post);

%distribution
% figure;hold on;ax = gca;
ax = '';
pitch_pval = plot_distribution(ax,pitch_pre,pitch_post,linecolor);

%z-score and summary plot
pitch_postn = (pitch_post-mean(pitch_pre))./std(pitch_pre);
figure(fignum);hold on;
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
pitch_zsc = plot_zscore_bootstrap(gca,xpt,pitch_postn,marker,linecolor,conditions,'mn');
title(gca,'pitch');

%percent change
pitch_percent = 100*(mean(pitch_post)-mean(pitch_pre))./mean(pitch_pre);

%absolute chnage
pitch_abs = mean(pitch_post)-mean(pitch_pre);

err.trialname = trialname;
err.condition = trialparams.condition;
err.pitch.mean = [mean(pitch_pre) mean(pitch_post)];
err.pitch.std = [std(pitch_pre) std(pitch_post)];
err.pitch.abs = pitch_abs;
err.pitch.percent = pitch_percent;
err.pitch.zsc = pitch_zsc; 
err.pitch.pval = pitch_pval;
