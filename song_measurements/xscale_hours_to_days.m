function xscale_hours_to_days(axes);
%xlabel for figure axes to transfer from hours to days 

dataob = get(axes,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600/24);
set(gca,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');