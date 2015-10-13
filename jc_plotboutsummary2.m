function [singingrate timebins] = jc_plotboutsummary2(bout_sal, bout_cond,marker,linecolor)
%for blocked design to compare matched time 


tb_sal = jc_tb([bout_sal(:).datenm]',7,0);
tb_cond = jc_tb([bout_cond(:).datenm]',7,0);

halfwinsize = 0.5;
jogsize = 0.5;
timebins = halfwinsize:jogsize:14-halfwinsize;
singingrate = NaN(size(timebins));
for i = 1:length(timebins)
    ind1 = find(tb_sal/3600 >= (timebins(i)-halfwinsize) & tb_sal/3600 < (timebins(i)+halfwinsize));
    ind2 = find(tb_cond/3600 >= (timebins(i)-halfwinsize) & tb_cond/3600 < (timebins(i)+halfwinsize));
    if isempty(ind1)
        continue
    end
    singingrate(i) = length(ind2)/length(ind1);
end

fignum = input('figure number for plotting singing rate summary:');
figure(fignum);hold on;
jitter = (-1+2*rand)/10;
xpt = 0.5+jitter;
plot(xpt,nanmean(singingrate),marker,'markersize',15);hold on;
set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'NASPM','saline'});
ylabel('Change in singing rate relative to saline');
title('Singing rate');
singingrate = nanmean(singingrate);