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
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['fvnaspm_',ff(i).name])
         x = eval(['fvnaspm_',ff(i).name]);
     elseif exist(['fviem_',ff(i).name]) 
        x = eval(['fviem_',ff(i).name]);
     end
     
     syllables = fieldnames(x);
     numbars = length(syllables);
     xlblcenter = [xlblcenter,mean([barind:barind+numbars-1])];
     for ii = 1:numbars
         xdata = barind;
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).fv];
         axes(h1);hold(h1,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h1,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h1,'off');
         
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).vol];
         axes(h2);hold(h2,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h2,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h2,'off');
         
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).ent];
         axes(h3);hold(h3,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h3,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h3,'off');
         
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).pcv]-1;
         axes(h4);hold(h4,'on');
         createPatches(xdata,nanmean(ydata),0.45,bcolor(i,:),0.5);
         plot(h4,xdata,ydata,'color',bcolor(i,:),'marker','o','markersize',8);
         hold(h4,'off');
         
         barind = barind + 1;
     end
end
xticklbl = {ff(:).name};
set(h1,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h1,'z-score');
title(h1,'pitch');

set(h2,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h2,'z-score');
title(h2,'volume');

set(h3,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h3,'z-score');
title(h3,'entropy');

set(h4,'xtick',xlblcenter,'xticklabel',xticklbl,'fontweight','bold');
ylabel(h4,'percent change');
title(h4,'pitch CV');
     