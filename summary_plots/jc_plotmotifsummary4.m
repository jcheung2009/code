function temp = jc_plotmotifsummary4(motif_sal, motif_cond, ...
   motif,params,trialparams,fignum)
%summary plot of motif temporal features and distribution plots
conditions=params.conditions;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = strfind(conditions,trialparams.condition);xpt=xpt{1};

%exclude wash-in and match time of day
tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
start_time = time2datenum(treattime) + 3600;%1 hr buffer
ind = find(tb_cond > start_time);
tb_cond=tb_cond(ind);
motifdur2 = [motif_cond(ind).motifdur];
meansylldur2 = mean([motif_cond(ind).durations],1);
meangapdur2 = mean([motif_cond(ind).gaps],1);
motifacorr2 = [motif_cond(ind).firstpeakdistance];
sylldur2 = [motif_cond(ind).durations]';
gapdur2 = [motif_cond(ind).gaps]';
ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
tb_sal=tb_sal(ind);
motifdur = [motif_sal(ind).motifdur];
meansylldur = mean([motif_sal(ind).durations],1);
meangapdur = mean([motif_sal(ind).gaps],1);
motifacorr = [motif_sal(ind).firstpeakdistance];
sylldur = [motif_sal(ind).durations]';
gapdur = [motif_sal(ind).gaps]';

%remove outliers
if strcmp(removeoutliers,'y')
    nstd=4;
    motifdur = jc_removeoutliers(motifdur,nstd);
    meansylldur = jc_removeoutliers(meansylldur,nstd);
    meangapdur = jc_removeoutliers(meangapdur,nstd);
    motifacorr = jc_removeoutliers(motifacorr,nstd);
    sylldur = jc_removeoutliers(sylldur,nstd);
    gapdur = jc_removeoutliers(gapdur,nstd);
    motifdur2 = jc_removeoutliers(motifdur2,nstd);
    meansylldur2 = jc_removeoutliers(meansylldur2,nstd);
    meangapdur2 = jc_removeoutliers(meangapdur2,nstd);
    motifacorr2 = jc_removeoutliers(motifacorr2,nstd);
    sylldur2 = jc_removeoutliers(sylldur2,nstd);
    gapdur2 = jc_removeoutliers(gapdur2,nstd);
end

%remove nan
motifdur = jc_removenan(motifdur);
meansylldur = jc_removenan(meansylldur);
meangapdur = jc_removenan(meangapdur);
motifacorr = jc_removenan(motifacorr);
sylldur = jc_removenan(sylldur);
gapdur = jc_removenan(gapdur);
motifdur2 = jc_removenan(motifdur2);
meansylldur2 = jc_removenan(meansylldur2);
meangapdur2 = jc_removenan(meangapdur2);
motifacorr2 = jc_removenan(motifacorr2);
sylldur2 = jc_removenan(sylldur2);
gapdur2 = jc_removenan(gapdur2);

%distributions
figure;hold on;
h1 = subtightplot(4,1,1,[0.07 0.05],0.08,0.12);
h2 = subtightplot(4,1,2,[0.07 0.05],0.08,0.12);
h3 = subtightplot(4,1,3,[0.07 0.05],0.08,0.12);
h4 = subtightplot(4,1,4,[0.07 0.05],0.08,0.12);
motifdur_pval = plot_distribution(h1,motifdur,motifdur2,linecolor);
meansylldur_pval = plot_distribution(h2,meansylldur,meansylldur2,linecolor);
meangapdur_pval = plot_distribution(h3,meangapdur,meangapdur2,linecolor);
motifacorr_pval = plot_distribution(h4,motifacorr,motifacorr2,linecolor);
xlabel(h1,'motif duration (s)');
xlabel(h2,'mean syllable duration (s)');
xlabel(h3,'mean gap duration (s)');
xlabel(h4,'interval duration (s)');
title(h1,trialname,'interpreter','none');

figure;hold on;
numsylls = size(sylldur,2);
sylldur_pval=[];
for i = 1:numsylls
    h = subtightplot(numsylls,1,i,[0.07 0.05],0.08,0.12);
    pval = plot_distribution(h,sylldur(:,i),sylldur2(:,i),linecolor);
    sylldur_pval=[sylldur_pval;pval];
    xlabel(h,['syllable ',motif(i),' duration (s)']);
    if i == 1
        title(h,trialname,'interpreter','none');
    end
end
figure;hold on;
numgaps = size(sylldur,2)-1;
gapdur_pval=[];
for i = 1:numgaps
    h = subtightplot(numgaps,1,i,[0.07 0.05],0.08,0.12);
    pval = plot_distribution(h,gapdur(:,i),gapdur2(:,i),linecolor);
    gapdur_pval=[gapdur_pval;pval];
    xlabel(h,['gap ',num2str(i),' duration (s)']);
    if i == 1
        title(h,trialname,'interpreter','none');
    end
end

%z-score 
motifdurn = (motifdur2-mean(motifdur))./std(motifdur);
meansylldurn = (meansylldur2-mean(meansylldur))./std(meansylldur);
meangapdurn = (meangapdur2-mean(meangapdur))./std(meangapdur);
motifacorrn = (motifacorr2-mean(motifacorr))./std(motifacorr);
sylldurn = (sylldur2-mean(sylldur,1))./std(sylldur,1);
gapdurn = (gapdur2-mean(gapdur,1))./std(gapdur,1);
figure(fignum);hold on;
h1 = subtightplot(3,2,1,[0.07 0.05],0.08,0.12);
h2 = subtightplot(3,2,2,[0.07 0.05],0.08,0.12);
h3 = subtightplot(3,2,3,[0.07 0.05],0.08,0.12);
h4 = subtightplot(3,2,4,[0.07 0.05],0.08,0.12);
h5 = subtightplot(3,2,5,[0.07 0.05],0.08,0.12);
h6 = subtightplot(3,2,6,[0.07 0.05],0.08,0.12);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
motifdur_zsc = plot_zscore_bootstrap(h1,xpt,motifdurn,marker,linecolor,conditions,'mn');
title(h1,'motif duration');
meansylldur_zsc = plot_zscore_bootstrap(h2,xpt,meansylldurn,marker,linecolor,conditions,'mn');
title(h2,'mean syllable duration');
meangapdur_zsc = plot_zscore_bootstrap(h3,xpt,meangapdurn,marker,linecolor,conditions,'mn');
title(h3,'mean gap duration');
motifacorr_zsc = plot_zscore_bootstrap(h4,xpt,motifacorrn,marker,linecolor,conditions,'mn');
title(h4,'interval duration');
sylldur_zsc=[];
for i = 1:numsylls
    zsc = plot_zscore_bootstrap(h5,xpt,sylldurn(:,i),marker,linecolor,conditions,'mn');hold on;
    sylldur_zsc = [sylldur_zsc;zsc];
end
title(h5,'syllable duration');
gapdur_zsc=[];
for i = 1:numgaps
    zsc = plot_zscore_bootstrap(h6,xpt,gapdurn(:,i),marker,linecolor,conditions,'mn');hold on;
    gapdur_zsc = [gapdur_zsc;zsc];
end
title(h6,'gap duration');
motifdur_zsc = plot_zscore_bootstrap(h1,xpt,motifdurn,marker,linecolor,conditions,'mn');
title(h1,'motif duration');

%percent change
motifdur_percent = 100*(mean(motifdur2)-mean(motifdur))/mean(motifdur);
meansylldur_percent = 100*(mean(meansylldur2)-mean(meansylldur))/mean(meansylldur);
meangapdur_percent = 100*(mean(meangapdur2)-mean(meangapdur))/mean(meangapdur);
motifacorr_percent = 100*(mean(motifacorr2)-mean(motifacorr))/mean(motifacorr);
sylldur_percent= 100*(mean(sylldur2,1)-mean(sylldur,1))./mean(sylldur,1);
gapdur_percent= 100*(mean(gapdur2,1)-mean(gapdur,1))./mean(gapdur,1);

%absolute change
motifdur_abs = mean(motifdur2)-mean(motifdur);
meansylldur_abs = mean(meansylldur2)-mean(meansylldur);
meangapdur_abs = mean(meangapdur2)-mean(meangapdur);
motifacorr_abs = mean(motifacorr2)-mean(motifacorr);
sylldur_abs = mean(sylldur2,1)-mean(sylldur,1);
gapdur_abs = mean(gapdur2,1)-mean(gapdur,1);

temp.trialname = trialname;
temp.condition = trialparams.condition;
temp.motifdur.abs = motifdur_abs;
temp.motifdur.percent = motifdur_percent;
temp.motifdur.zsc = motifdur_zsc;
temp.meansylldur.abs = meansylldur_abs;
temp.meansylldur.percent = meansylldur_percent;
temp.meansylldur.zsc = meansylldur_zsc;
temp.meangapdur.abs = meangapdur_abs;
temp.meangapdur.percent = meangapdur_percent;
temp.meangapdur.zsc = meangapdur_zsc;
temp.motifacorr.abs = motifacorr_abs;
temp.motifacorr.percent = motifacorr_percent;
temp.motifacorr.zsc = motifacorr_zsc;
temp.sylldur.abs = sylldur_abs;
temp.sylldur.percent = sylldur_percent;
temp.sylldur.zsc = sylldur_zsc;
temp.gapdur.abs = gapdur_abs;
temp.gapdur.percent = gapdur_percent;
temp.gapdur.zsc = gapdur_zsc;

    
    
   