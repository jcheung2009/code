ff = load_batchf('naspm_birds');
bcolor = hsv(length(ff));

barind = 1;
figure;hold on;
ax = gca;
xlblcenter = [];
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['boutnaspm_',ff(i).name])
         x = eval(['boutnaspm_',ff(i).name]);
     elseif exist(['boutiem_',ff(i).name]) 
        x = eval(['boutiem_',ff(i).name]);
     end
     
     xlblcenter = [xlblcenter,barind];

     xdata = barind;
     ydata = 100*([x(:).singrate]-1);
     hold(ax,'on');
     createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
     plot(ax,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
     
     barind = barind + 1;
    
end
xticklbl = {ff(:).name};
set(ax,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel('percent change');
title('peak singing rate');
