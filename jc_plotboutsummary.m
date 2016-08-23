function singingrate = jc_plotboutsummary(bout_sal, bout_cond, marker,linecolor,...
    xpt,excludewashin,startpt,matchtm,fignum)
%bout_sal from jc_findboutvals
%generate summary plots for changes in motif number and singing rate
%for saline morn vs drug noon

tb_sal = jc_tb([bout_sal(:).datenm]',7,0);
tb_cond = jc_tb([bout_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    tb_cond(ind) = [];
    bout_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    bout_cond(ind) = [];
    tb_cond(ind) = [];
end

if matchtm == 1
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    tb_sal = tb_sal(indsal);
end 

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


%change in peak singing rate
singingrate = max(numsongs2(:,2))/max(numsongs(:,2));

figure(fignum);hold on;
jitter = (-1+2*rand)/10;
xpt = xpt + jitter;
plot(xpt,singingrate,marker,'markersize',12);hold on;
plot([0 3],[1 1],'c','linewidth',2);
    set(gca,'xlim',[0 3],'xtick',[0.5,1.5 2.5],'xticklabel',...
        {'saline','iem','iem+apv'},'fontweight','bold');
ylabel('Change in peak singing rate');
title('Singing rate');






