function [singingrate timebins] = jc_plotboutsummary2(bout_sal, bout_cond,marker,linecolor,xpt)
%for blocked design to compare matched time 


tb_sal = jc_tb([bout_sal(:).datenm]',7,0);
tb_cond = jc_tb([bout_cond(:).datenm]',7,0);

%singing rate for sal
numseconds = tb_sal(end)-tb_sal(1);
timewindow = 1800;
jogsize = 900;
numtimewindows = 2*floor(numseconds/timewindow)-1;
if numtimewindows < 0
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
timewindow = 1800;
jogsize = 900;
numtimewindows = 2*floor(numseconds/timewindow)-1;
if numtimewindows < 0
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


% halfwinsize = 0.5;
% jogsize = 0.5;
% timebins = halfwinsize:jogsize:14-halfwinsize;
% singingrate = NaN(size(timebins));
% for i = 1:length(timebins)
%     ind1 = find(tb_sal/3600 >= (timebins(i)-halfwinsize) & tb_sal/3600 < (timebins(i)+halfwinsize));
%     ind2 = find(tb_cond/3600 >= (timebins(i)-halfwinsize) & tb_cond/3600 < (timebins(i)+halfwinsize));
%     if isempty(ind1)
%         continue
%     end
%     singingrate(i) = length(ind2)/length(ind1);
% end

fignum = input('figure number for plotting singing rate summary:');
figure(fignum);hold on;
jitter = (-1+2*rand)/10;
xpt = xpt+jitter;
plot(xpt,singingrate,marker,'markersize',12);hold on;
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',{'probe 1','probe 2','probe 3','probe 4'});
ylabel('Change in peak singing rate relative to saline');
title('Singing rate');