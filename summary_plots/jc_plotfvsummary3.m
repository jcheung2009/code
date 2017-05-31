function [fv v et pcv] = jc_plotfvsummary3(fv_syll_sal, fv_syll_cond,marker,...
    linecolor,xpt,removeoutliers,params,fignum);
%summary plot of spectral features (z-score) and distribution plots
%generate summary changes in pitch, entropy, volume, and pitch cv

trialname=params.name;
treattime=params.treattime;
conditions=params.conditions;

%exclude wash-in
tb_sal = jc_tb([fv_syll_sal(:).datenm]',7,0);
tb_cond = jc_tb([fv_syll_cond(:).datenm]',7,0);
start_time = time2datenum(treattime) + 3600;%1 hr buffer
ind = find(tb_sal > start_time);
tb_sal=tb_sal(ind);
pitch = [fv_syll_sal(ind).mxvals];
vol = log([fv_syll_sal(ind).maxvol]);
ent = [fv_syll_sal(ind).spent];
ind = find(tb_cond > start_time);
tb_cond=tb_cond(ind);
pitch2 = [fv_syll_cond(ind).mxvals];
vol2 = log([fv_syll_cond(ind).maxvol]);
ent2 = [fv_syll_cond(ind).spent];

%match time of day
ind = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end));
tb_sal=tb_sal(ind);
pitch=pitch(ind);
vol=vol(ind);
ent=ent(ind);

%remove outliers
if strcmp(checkoutliers,'y')
    nstd=4;
    pitch = jc_removeoutliers(pitch,nstd);
    vol = jc_removeoutliers(vol,nstd);
    ent = jc_removeoutliers(ent,nstd);
    pitch2 = jc_removeoutliers(pitch2,nstd);
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

%distributions
figure;hold on;
h1 = subtightplot(3,1,1,[0.07 0.05],0.08,0.1);
h2 = subtightplot(3,1,2,[0.07 0.05],0.08,0.1);
h3 = subtightplot(3,1,3,[0.07 0.05],0.08,0.1);
pitch_pval = plot_distribution(h1,pitch,pitch2,linecolor);
vol_pval= = plot_distribution(h2,vol,vol2,linecolor);
ent_pval = plot_distribution(h3,ent,ent2,linecolor);
[~,pcv_pval] = vartest2(pitch,pitch2);
xlabel(h1,'frequency (hz)');xlabel(h2,'log amplitude');xlabel(h3,'entropy');
title(h1,trialname);

%z-score
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
plot_zscore_bootstrap(h1,xpt,pitchn,marker,linecolor,conditions,'mn');
title(h1,'pitch');
plot_zscore_bootstrap(h2,xpt,voln,marker,linecolor,conditions,'mn');
title(h1,'volume');
plot_zscore_bootstrap(h3,xpt,entn,marker,linecolor,conditions,'mn');
title(h1,'entropy');

 mn1 = mBootstrapCI_CV(pitch);
    [mn2 hi lo] = mBootstrapCI_CV(pitch2);
    mn3 = 100*(mn2-mn1)/mn1;
    hi = 100*(hi-mn1)/mn1;
    lo = 100*(lo-mn1)/mn1;
    plot(xpt,mn3,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0 3],[0 0],'c','linewidth',2);
    set(gca,'xlim',[0 3],'xtick',[0.5,1.5 2.5],'xticklabel',...
        {'saline','iem','iem+apv'},'fontweight','bold');
    ylabel('percent change');
    title('Change in pitch CV relative to saline');
    pcv = mn3;


