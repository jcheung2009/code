function bout = jc_plotboutsummary3(bout_sal, bout_cond,params,trialparams,fignum)
%plot summary for singing rate and num motifs/bout

conditions=params.conditions;
base = params.baseepoch;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));

%exclude wash-in and match time of day
tb_sal = jc_tb([bout_sal(:).datenm]',7,0);
tb_cond = jc_tb([bout_cond(:).datenm]',7,0);
if isempty(treattime)
    start_time = tb_cond(1)+3600;
else
    start_time = time2datenum(treattime) + 3600;%1 hr buffer
end
ind = find(tb_cond > start_time);
tb_cond=tb_cond(ind);
nummotifsperbout2 = [bout_cond(ind).nummotifs]';
if ~strcmp(base,'morn')
    ind = find(tb_sal >= tb_cond(1));
else
    ind = 1:length(tb_sal);
end
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
% figure;hold on;
% h1 = subtightplot(2,1,1,[0.07 0.05],0.08,0.12);
% h2 = subtightplot(2,1,2,[0.07 0.05],0.08,0.12);
h1 = '';h2 = '';
singingrate_pval = plot_distribution(h1,numsongs(:,2),numsongs2(:,2),linecolor,10);
nummotifs_pval = plot_distribution(h2,nummotifsperbout,nummotifsperbout2,linecolor,10);
% xlabel(h1,'number bouts per hour');
% xlabel(h2,'number of motifs per bout');
% title(h1,trialname,'interpreter','none');

%percent change
meansingingrate_perc = 100*(mean(numsongs2(:,2))-mean(numsongs(:,2)))/mean(numsongs(:,2));
maxsingingrate_perc = 100*(max(numsongs2(:,2))-max(numsongs(:,2)))/max(numsongs(:,2));
motifsperbout_perc = 100*(mean(nummotifsperbout2)-mean(nummotifsperbout))/mean(nummotifsperbout);

%absolute change
meansingingrate_abs = mean(numsongs2(:,2))-mean(numsongs(:,2));
maxsingingrate_abs = max(numsongs2(:,2))-max(numsongs(:,2));
motifsperbout_abs = mean(nummotifsperbout2)-mean(nummotifsperbout);

%summary plot
figure(fignum);hold on;
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
plot(xpt,maxsingingrate_perc,marker,'markersize',12);hold on;
plot([0.5 length(conditions)+0.5],[0 0],'color',[0.5 0.5 0.5]);hold on;
set(gca,'fontweight','bold','xlim',[0.5 length(conditions)+0.5],'xtick',1:length(conditions),...
    'xticklabel',conditions);
ylabel('percent change');
title('max singing rate');

bout.trialname = trialname;
bout.condition = trialparams.condition;
bout.meansingingrate.mean = [mean(numsongs(:,2)) mean(numsongs2(:,2))];
bout.meansingingrate.percent = meansingingrate_perc;
bout.meansingingrate.abs = meansingingrate_abs;
bout.meansingingrate.pval = singingrate_pval;
bout.maxsingingrate.max = [max(numsongs(:,2)) max(numsongs2(:,2))];
bout.maxsingingrate.percent = maxsingingrate_perc;
bout.maxsingingrate.abs = maxsingingrate_abs; 
bout.motifsperbout.mean = [mean(nummotifsperbout) mean(nummotifsperbout2)];
bout.motifsperbout.percent = motifsperbout_perc;
bout.motifsperbout.abs = motifsperbout_abs;
bout.motifsperbout.pval = nummotifs_pval;




