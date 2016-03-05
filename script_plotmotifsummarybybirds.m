ff = load_batchf('apv_birds');
bcolor = hsv(length(ff));

barind = 1;
figure;hold on;
xlblcenter = [];
h1 = subtightplot(4,1,1,0.07,0.08,0.1);
h2 = subtightplot(4,1,2,0.07,0.08,0.1);
h3 = subtightplot(4,1,3,0.07,0.08,0.1);
h4 = subtightplot(4,1,4,0.07,0.08,0.1);
lname = {};
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
%      if exist(['motifnaspm_',ff(i).name])
%          x = eval(['motifnaspm_',ff(i).name]);
%      elseif exist(['motifiem_',ff(i).name]) 
%         x = eval(['motifiem_',ff(i).name]);
%      end
     if ~exist(['motifapv_',ff(i).name]);
         continue
     else
        x = eval(['motifapv_',ff(i).name]);
        lname = [lname;ff(i).name];
     end
     
     xlblcenter = [xlblcenter,barind];

     xdata = barind;
     ydata = [x(:).macorr];
     %ydata = 1000*([ydata(:).abs]);
     ydata = 100*([ydata(:).rel]-1);
     axes(h1);hold(h1,'on');
     createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
     plot(h1,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
     hold(h1,'off');

     ydata = [x(:).mdur];
     %ydata = 1000*([ydata(:).abs]);
     ydata = 100*([ydata(:).rel]-1);
     axes(h2);hold(h2,'on');
     createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
     plot(h2,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
     hold(h2,'off');

     ydata = [x(:).sdur];
     %ydata = 1000*([ydata(:).abs]);
     ydata = 100*([ydata(:).rel]-1);
     axes(h3);hold(h3,'on');
     createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
     plot(h3,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
     hold(h3,'off');

     ydata = [x(:).gdur];
     %ydata = 1000*([ydata(:).abs]);
     ydata = 100*([ydata(:).rel]-1);
     axes(h4);hold(h4,'on');
     createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
     plot(h4,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
     hold(h4,'off');

     barind = barind + 1;
    
end
xticklbl = lname;
set(h1,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h1,'percent change');
title(h1,'acorr');

set(h2,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h2,'percent change');
title(h2,'motif dur');

set(h3,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h3,'percent change');
title(h3,'syll dur');

set(h4,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h4,'percent change');
title(h4,'gap dur');