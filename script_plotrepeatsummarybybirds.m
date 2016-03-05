ff = load_batchf('naspm_birds');
bcolor = hsv(length(ff));

barind = 1;
figure;
h1 = subtightplot(4,1,1,0.07,0.08,0.1);
h2 = subtightplot(4,1,2,0.07,0.08,0.1);
h3 = subtightplot(4,1,3,0.07,0.08,0.1);
h4 = subtightplot(4,1,4,0.07,0.08,0.1);
hold off;
xlblcenter = [];
xticklbl = {};
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['repnaspm_',ff(i).name])
         x = eval(['repnaspm_',ff(i).name]);
     elseif exist(['repiem_',ff(i).name]) 
        x = eval(['repiem_',ff(i).name]);
     else
         continue
     end
     xticklbl = [xticklbl,{ff(i).name}];
     
     repeats = fieldnames(x);
     numbars = length(repeats);
     xlblcenter = [xlblcenter,mean([barind:barind+numbars-1])];
     for ii = 1:numbars
         xdata = barind;
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).rep];
         ydata = [ydata(:).abs];
         %ydata = 100*(([ydata(:).rel])-1);
         axes(h1);hold(h1,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h1,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h1,'off');
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).acorr];
         ydata = [ydata(:).abs];
         %ydata = 100*(([ydata(:).rel])-1);
         axes(h2);hold(h2,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h2,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h2,'off');
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).sdur];
         ydata = [ydata(:).abs];
         %ydata = 100*(([ydata(:).rel])-1);
         axes(h3);hold(h3,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h3,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h3,'off');
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).gdur];
         ydata = [ydata(:).abs];
         %ydata = 100*(([ydata(:).rel])-1);
         axes(h4);hold(h4,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h4,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h4,'off');
         
         barind = barind + 1;
     end
end

set(h1,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h1,'absolute change');
title(h1,'repeat length');

set(h2,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h2,'absolute change');
title(h2,'acorr');

set(h3,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h3,'absolute change');
title(h3,'syll dur');

set(h4,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h4,'absolute change');
title(h4,'gap dur');