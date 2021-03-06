function spec = jc_plotfvsummary3(fv_syll_sal, fv_syll_cond,syllable,params,trialparams,fignum);
%summary plot of spectral features (z-score) and distribution plots
%stores summary changes in pitch, entropy, volume, and pitch cv

%parameters
conditions=params.conditions;
base = params.baseepoch;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));
if isfield(params,'detrend')
    detrend = params.detrend;
else
    detrend = 'n';
end
       
%exclude wash-in and match time of day
tb_sal = [fv_syll_sal(:).datenm]';
tb_cond = [fv_syll_cond(:).datenm]';
[ind1 ind2 tb_sal tb_cond] = restricttimewindow(tb_sal,tb_cond,...
    treattime,base,trialparams.condition);

pitch2 = [fv_syll_cond(ind2).mxvals]';
vol2 = log([fv_syll_cond(ind2).maxvol]');
ent2 = [fv_syll_cond(ind2).spent]';

pitch = [fv_syll_sal(ind1).mxvals]';
vol = log([fv_syll_sal(ind1).maxvol]');
ent = [fv_syll_sal(ind1).spent]';

%remove outliers
if strcmp(removeoutliers,'y')
    nstd=4;
    pitch = jc_removeoutliers([tb_sal pitch],nstd,1);
    vol = jc_removeoutliers(vol,nstd);
    ent = jc_removeoutliers(ent,nstd);
    pitch2 = jc_removeoutliers([tb_cond pitch2],nstd,1);
    vol2 = jc_removeoutliers(vol2,nstd);
    ent2 = jc_removeoutliers(ent2,nstd);
end

%remove nan
pitch=jc_removenan(pitch);
vol=jc_removenan(vol);
ent=jc_removenan(ent);
pitch2=jc_removenan(pitch2);
vol2=jc_removenan(vol2);
ent2=jc_removenan(ent2);
tb_sal = pitch(:,1);
tb_cond = pitch2(:,1);
pitch = pitch(:,2);
pitch2 = pitch2(:,2);

%distributions
% figure;hold on;
% h1 = subtightplot(3,1,1,[0.07 0.05],0.08,0.12);
% h2 = subtightplot(3,1,2,[0.07 0.05],0.08,0.12);
% h3 = subtightplot(3,1,3,[0.07 0.05],0.08,0.12);
h1='';h2='';h3='';
pitch_pval = plot_distribution(h1,pitch,pitch2,linecolor);
vol_pval= plot_distribution(h2,vol,vol2,linecolor);
ent_pval = plot_distribution(h3,ent,ent2,linecolor);
if strcmp(detrend,'n')
    [~,pcv_pval] = vartest2(pitch,pitch2);
else
    pch = jc_detrendpitch(pitch,tb_sal);
    pch2 = jc_detrendpitch(pitch2,tb_cond);
    [~,pcv_pval] = vartest2(pch,pch2);
end
% xlabel(h1,'frequency (hz)');xlabel(h2,'log amplitude');xlabel(h3,'entropy');
% title(h1,[syllable,':',trialname],'interpreter','none');

%z-score and summary plot
pitchn = (pitch2-mean(pitch))./std(pitch);
voln = (vol2-mean(vol))./std(vol);
entn = (ent2-mean(ent))./std(ent);
figure(fignum);hold on;
h1 = subtightplot(4,1,1,[0.07 0.05],0.08,0.15);
h2 = subtightplot(4,1,2,[0.07 0.05],0.08,0.15);
h3 = subtightplot(4,1,3,[0.07 0.05],0.08,0.15);
h4 = subtightplot(4,1,4,[0.07 0.05],0.08,0.15);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
pitch_zsc = plot_zscore_bootstrap(h1,xpt,pitchn,marker,linecolor,conditions,'mn');
title(h1,'pitch');
vol_zsc = plot_zscore_bootstrap(h2,xpt,voln,marker,linecolor,conditions,'mn');
title(h2,'volume');
ent_zsc = plot_zscore_bootstrap(h3,xpt,entn,marker,linecolor,conditions,'mn');
title(h3,'entropy');
if strcmp(detrend,'n')
    pcv_percent = plot_percent_bootstrapCV(h4,xpt,pitch,pitch2,marker,linecolor,conditions);
else
    pcv_percent = plot_percent_bootstrapCV(h4,xpt,pch,pch2,marker,linecolor,conditions);
end
title(h4,'pitch cv');

%percent change
pitch_percent = 100*(mean(pitch2)-mean(pitch))/mean(pitch);
vol_percent = 100*(mean(vol2)-mean(vol))/mean(abs(vol));
ent_percent = 100*(mean(ent2)-mean(ent))/mean(ent);

%absolute change
pitch_abs = mean(pitch2)-mean(pitch);
vol_abs = mean(vol2)-mean(vol);
ent_abs = mean(ent2)-mean(ent);

spec.trialname = trialname;
spec.condition = trialparams.condition;
spec.pitch.mean = [mean(pitch) mean(pitch2)];
spec.pitch.std = [std(pitch) std(pitch2)];
spec.pitch.abs = pitch_abs;
spec.pitch.percent = pitch_percent;
spec.pitch.zsc = pitch_zsc;
spec.pitch.pval = pitch_pval;
spec.vol.mean = [mean(vol) mean(vol2)];
spec.vol.std = [std(vol) std(vol2)];
spec.vol.abs = vol_abs;
spec.vol.percent = vol_percent;
spec.vol.zsc = vol_zsc;
spec.vol.pval = vol_pval;
spec.ent.mean = [mean(ent) mean(ent2)];
spec.ent.std = [std(ent) std(ent2)];
spec.ent.abs = ent_abs;
spec.ent.percent = ent_percent;
spec.ent.zsc = ent_zsc;
spec.ent.pval = ent_pval;
spec.pitchcv.cv = [cv(pitch) cv(pitch2)];
spec.pitchcv.percent = pcv_percent;
spec.pitchcv.pval = pcv_pval;

function [ind1 ind2 tb_sal tb_cond] = restricttimewindow(tb_sal,tb_cond,...
    treattime,base,condition);
%restrict and match the time window of analysis between conditions
%outputs the indices for data and time vectors 
    %get time vector for data in seconds relative to 7 AM 
    tb_sal = jc_tb(tb_sal,7,0);
    tb_cond = jc_tb(tb_cond,7,0);
    if isempty(treattime)
        start_time = tb_cond(1)+3600;
    else
        start_time = time2datenum(treattime) + 3600;%1 hr buffer
    end

    if ~strcmp(base,'morn') & ~strcmp(condition,'saline')%comparing drug in afternoon to saline in afternoon 
        ind2 = find(tb_cond > start_time);
        ind1 = find(tb_sal >= tb_cond(1));
    elseif ~strcmp(base,'morn') & strcmp(condition,'saline')%comparing saline to saline between days 
        ind2 = find(tb_cond > start_time);
        ind1 = find(tb_sal >= tb_cond(1));
    elseif strcmp(base,'morn') & ~strcmp(condition,'saline')%comparing drug in afternoon to saline in morning
        ind2 = find(tb_cond > start_time);
        ind1 = 1:length(tb_sal);
    elseif strcmp(base,'morn') & strcmp(condition,'saline')%comparing saline in afternoon to saline in morning
        ind2 = find(tb_cond >= 5*3600);
        ind1 = find(tb_sal < 5*3600);
    end
    tb_sal = tb_sal(ind1);
    tb_cond = tb_cond(ind2);
