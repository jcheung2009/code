%distribution of temporal features by repeat cases

ff = load_batchf('naspm_birds');

repdata = [];
% acorrdata = [];
% sdurdata = [];
% gdurdata = [];

repdata_sal = [];
% acorrdata_sal = [];
% sdurdata_sal = [];
% gdurdata_sal = [];
lname = {};
cmap = [];
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['repnaspm_',ff(i).name])
         x = eval(['repnaspm_',ff(i).name]);
     elseif exist(['repiem_',ff(i).name]) 
        x = eval(['repiem_',ff(i).name]);
     else
         continue
     end
     
     if exist(['repsal_',ff(i).name])
         y = eval(['repsal_',ff(i).name]);
     end
    
     repeats = fieldnames(x);
     rep = [];
     repsal = [];
     cmap = [cmap; repmat(rand(1,3),length(repeats),1)];
     for ii = 1:length(repeats)
         lname = [lname; {ff(i).name}];
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).rep];
         if i <=8
             ydata = 100*([ydata(:).rel]-1);
         else
             ydata = [ydata(:).rel];
         end
         rep = [rep;nanmean(ydata)];
         %repdata = [repdata; nanmean(ydata)];
         
%          ydata = [x(:).([repeats{ii}])];
%          ydata = [ydata(:).acorr];
%          ydata = 100*([ydata(:).rel]-1);
%          acorrdata = [acorrdata; nanmean(ydata)];
%          
%          ydata = [x(:).([repeats{ii}])];
%          ydata = [ydata(:).sdur];
%          ydata = 100*([ydata(:).rel]-1);
%          sdurdata = [sdurdata; nanmean(ydata)];
%          
%          ydata = [x(:).([repeats{ii}])];
%          ydata = [ydata(:).gdur];
%          ydata = 100*([ydata(:).rel]-1);
%          gdurdata = [gdurdata; nanmean(ydata)];

         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).rep];
         if i<=8
            ydata = 100*([ydata(:).rel]-1);
         else
             ydata = [ydata(:).rel];
         end
         repsal = [repsal; nanmean(ydata)];
         %repdata_sal = [repdata_sal; nanmean(ydata)];
         
%          ydata = [y(:).([repeats{ii}])];
%          ydata = [ydata(:).acorr];
%          ydata = 100*([ydata(:).rel]-1);
%          acorrdata_sal = [acorrdata_sal; nanmean(ydata)];
%          
%          ydata = [y(:).([repeats{ii}])];
%          ydata = [ydata(:).sdur];
%          ydata = 100*([ydata(:).rel]-1);
%          sdurdata_sal = [sdurdata_sal; nanmean(ydata)];
%          
%          ydata = [y(:).([repeats{ii}])];
%          ydata = [ydata(:).gdur];
%          ydata = 100*([ydata(:).rel]-1);
%          gdurdata_sal = [gdurdata_sal; nanmean(ydata)];
     end
    repdata = [repdata; nanmean(rep)];
    repdata_sal = [repdata_sal; nanmean(repsal)];
end
         
figure;h1 = gca;
% h1 = subtightplot(4,1,1,[0.1 0.05],0.08,0.3);
% h2 = subtightplot(4,1,2,[0.1 0.05],0.08,0.3);
% h3 = subtightplot(4,1,3,[0.1 0.05],0.08,0.3);
% h4 = subtightplot(4,1,4,[0.1 0.05],0.08,0.3);
axes(h1);hold(h1,'on');
plot(h1,repmat([0.5 1.5]',1,length(repdata)),[repdata_sal repdata]',...
    'marker','o','markersize',8,'linewidth',2);hold on;
plot(h1,[0 2],[0 0],'c','linewidth',2);hold on;
[p h stat] = signrank(repdata,repdata_sal);
str = {['repeat length'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
title(h1,str);
hold(h1,'off');
xlim(h1,[0 2]);
legend(h1,{ff(:).name});
set(h1,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
ylabel(h1,'percent change');


% axes(h1);hold(h1,'on');
% set(h1,'ColorOrder',cmap,'NextPlot','replacechildren');
% plot(h1,repmat([0.5 1.5]',1,length(repdata)),[repdata_sal repdata]',...
%     'marker','o','markersize',8,'linewidth',2);hold on;
% plot(h1,[0 2],[0 0],'c','linewidth',2);hold on;
% [p h stat] = signrank(repdata,repdata_sal);
% str = {['repeat length'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% title(h1,str);
% hold(h1,'off');
% xlim(h1,[0 2]);
% legend(h1,lname);
% set(h1,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
% ylabel(h1,'percent change');

% axes(h2);hold(h2,'on');
% set(h2,'ColorOrder',cmap,'NextPlot','replacechildren');
% plot(h2,repmat([0.5 1.5]',1,length(acorrdata)),[acorrdata_sal acorrdata]',...
%     'marker','o','markersize',8,'linewidth',2);hold on;
% plot(h2,[0 2],[0 0],'c','linewidth',2);hold on;
% [p h stat] = signrank(acorrdata,acorrdata_sal);
% str = {['acorr'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% title(h2,str);
% hold(h2,'off');
% xlim(h2,[0 2]);
% set(h2,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
% ylabel(h2,'percent change');
% 
% axes(h3);hold(h3,'on');
% set(h3,'ColorOrder',cmap,'NextPlot','replacechildren');
% plot(h3,repmat([0.5 1.5]',1,length(sdurdata)),[sdurdata_sal sdurdata]',...
%     'marker','o','markersize',8,'linewidth',2);hold on;
% plot(h3,[0 2],[0 0],'c','linewidth',2);hold on;
% [p h stat] = signrank(sdurdata,sdurdata_sal);
% str = {['syll duration'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% title(h3,str);
% hold(h3,'off');
% xlim(h3,[0 2]);
% set(h3,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
% ylabel(h3,'percent change');
% 
% axes(h4);hold(h4,'on');
% set(h4,'ColorOrder',cmap,'NextPlot','replacechildren');
% plot(h4,repmat([0.5 1.5]',1,length(gdurdata)),[gdurdata_sal gdurdata]',...
%     'marker','o','markersize',8,'linewidth',2);hold on;
% plot(h4,[0 2],[0 0],'c','linewidth',2);hold on;
% [p h stat] = signrank(gdurdata,gdurdata_sal);
% str = {['gap duration'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% title(h4,str);
% hold(h4,'off');
% xlim(h4,[0 2]);
% set(h4,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
% ylabel(h4,'percent change');




% axes(h1);hold(h1,'on');
% [n b] = hist(repdata_sal,[-3:0.2:3]);stairs(h1,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(repdata,[-6:0.2:2]);stairs(h1,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h1,'ylim');
% plot(h1,mean(repdata_sal),ylimits(2),'kV','markersize',8);
% plot(h1,mean(repdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(repdata,repdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h1);
% hold(h1,'off');
% 
% axes(h2);hold(h2,'on');
% [n b] = hist(acorrdata_sal,[-3:0.2:3]);stairs(h2,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(acorrdata,[-6:0.2:2]);stairs(h2,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h2,'ylim');
% plot(h2,mean(acorrdata_sal),ylimits(2),'kV','markersize',8);
% plot(h2,mean(acorrdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(acorrdata,acorrdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h2);
% hold(h2,'off');
% 
% axes(h3);hold(h3,'on');
% [n b] = hist(sdurdata_sal,[-3:0.2:3]);stairs(h3,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(sdurdata,[-3:0.2:3]);stairs(h3,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h3,'ylim');
% plot(h3,mean(sdurdata_sal),ylimits(2),'kV','markersize',8);
% plot(h3,mean(sdurdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(sdurdata,sdurdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h3);
% hold(h3,'off');
% 
% axes(h4);hold(h4,'on');
% [n b] = hist(gdurdata_sal,[-3:0.2:3]);stairs(h4,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(gdurdata,[-3:0.2:3]);stairs(h4,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h4,'ylim');
% plot(h4,mean(gdurdata_sal),ylimits(2),'kV','markersize',8);
% plot(h4,mean(gdurdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(gdurdata,gdurdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h4);
% hold(h4,'off');
% 
% set(h1,'fontweight','bold');
% ylabel(h1,'probability');
% xlabel(h1,'z-score');
% title(h1,'repeat length');
% 
% set(h2,'fontweight','bold');
% ylabel(h2,'probability');
% xlabel(h2,'z-score');
% title(h2,'acorr');
% 
% set(h3,'fontweight','bold');
% ylabel(h3,'probability');
% xlabel(h3,'z-score');
% title(h3,'syll dur');
% 
% set(h4,'fontweight','bold');
% ylabel(h4,'probability');
% xlabel(h4,'z-score');
% title(h4,'gap dur');