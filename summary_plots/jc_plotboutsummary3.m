function bout = jc_plotboutsummary3(bout_sal, bout_cond,params,trialparams,fignum)
%plot summary for singing rate and num motifs/bout

conditions=params.conditions;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));

%exclude wash-in and match time of day
tb_sal = jc_tb([bout_sal(:).datenm]',7,0);
tb_cond = jc_tb([bout_cond(:).datenm]',7,0);
start_time = time2datenum(treattime) + 3600;%1 hr buffer
ind = find(tb_cond > start_time);
tb_cond=tb_cond(ind);
nummotifsperbout2 = [bout_cond(ind).nummotifs]';
ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
tb_sal = tb_sal(ind);
nummotifsperbout = [bout_sal(ind).nummotifs]';

%singing rate for sal
numseconds = tb_sal(end)-tb_sal(1);
timewindow = 3600;
jogsize = 900;
numtimewindows = floor(numseconds/jogsize)-(timewindow/jogsize)/2;
if numtimewindows <= 0
    numtimewindows = 1;
end

timept1 = tb_sal(1);
numsongs = [];
for i = 1:numtimewindows
    timept2 = timept1+timewindow;
    numsongs(i,:) = [timept1+jogsize length(find(tb_sal>= timept1 & tb_sal < timept2))];
    timept1 = timept1+jogsize;
end
if numtimewindows == 1
    numsongs = [numsongs; timept1+jogsize 0];
end

%singing rate for cond
numseconds = tb_cond(end)-tb_cond(1);
timewindow = 3600;
jogsize = 900;
numtimewindows = floor(numseconds/jogsize)-(timewindow/jogsize)/2;
if numtimewindows <= 0
    numtimewindows = 1;
end

timept1 = tb_cond(1);
numsongs2 = [];
for i = 1:numtimewindows
    timept2 = timept1+timewindow;
    numsongs2(i,:) = [timept1+jogsize length(find(tb_cond>= timept1 & tb_cond < timept2))];
    timept1 = timept1+jogsize;
end
if numtimewindows == 1
    numsongs2 = [numsongs2; timept1+jogsize 0];
end

%distribution
figure;hold on;
h1 = subtightplot(2,1,1,[0.07 0.05],0.08,0.12);
h2 = subtightplot(2,1,2,[0.07 0.05],0.08,0.12);
singingrate_pval = plot_distribution(h1,numsongs(:,2),numsongs2(:,2),linecolor,10);
nummotifs_pval = plot_distribution(h2,nummotifsperbout,nummotifsperbout2,linecolor,10);
xlabel(h1,'number bouts per hour');
xlabel(h2,'number of motifs per bout');
title(h1,trialname,'interpreter','none');

%percent change
meansingingraten = 100*(numsongs2(:,2)-mean(numsongs(:,2)))/mean(numsongs(:,2));
nummotifsperboutn = 100*(nummotifsperbout2-mean(nummotifsperbout))/mean(nummotifsperbout);
figure(fignum);hold on;
h1 = subtightplot(2,1,1,[0.07 0.05],0.08,0.12);
h2 = subtightplot(2,1,2,[0.07 0.05],0.08,0.12);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
meansingingrate_percent = plot_percent_bootstrap(h1,xpt,meansingingraten,marker,linecolor,conditions,'mn');
title(h1,'mean singing rate');
motifsperbout_percent = plot_percent_bootstrap(h2,xpt,nummotifsperboutn,marker,linecolor,conditions,'mn');
title(h2,'number of motifs per bout');

%absolute change
meansingingrate_abs = mean(numsongs2(:,2))-mean(numsongs(:,2));
motifsperbout_abs = mean(nummotifsperbout2)-mean(nummotifsperbout);

bout.trialname = trialname;
bout.condition = trialparams.condition;
bout.meansingingrate.mean = [mean(numsongs(:,2)) mean(numsongs2(:,2))];
bout.meansingingrate.percent = meansingingrate_percent;
bout.motifsperbout.mean = [mean(nummotifsperbout) mean(nummotifsperbout2)];
bout.motifsperbout.percent = motifsperbout_percent;
bout.maxsingingrate.percent = 100*(max(numsongs2(:,2))-max(numsongs(:,2)))/max(numsongs(:,2));
bout.meansingingrate.abs = meansingingrate_abs;
bout.motifsperbout.abs = motifsperbout_abs;
bout.maxsingingrate.abs = max(numsongs2(:,2))-max(numsongs(:,2));



