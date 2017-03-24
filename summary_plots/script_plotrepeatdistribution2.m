%distribution of temporal features by repeat by trial

ff = load_batchf('naspm_birds');

repdata = [];
acorrdata = [];
sdurdata = [];
gdurdata = [];

repdata_sal = [];
acorrdata_sal = [];
sdurdata_sal = [];
gdurdata_sal = [];
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
     for ii = 1:length(repeats)
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).rep];
         repdata = [repdata; ydata'];
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).acorr];
         acorrdata = [acorrdata; ydata'];
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).sdur];
         sdurdata = [sdurdata; ydata'];
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).gdur];
         gdurdata = [gdurdata; ydata'];

         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).rep];
         repdata_sal = [repdata_sal; ydata'];
         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).acorr];
         acorrdata_sal = [acorrdata_sal; ydata'];
         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).sdur];
         sdurdata_sal = [sdurdata_sal; ydata'];
         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).gdur];
         gdurdata_sal = [gdurdata_sal; ydata'];
     end

end
         
figure;
h1 = subtightplot(4,1,1,0.07,0.08,0.1);
h2 = subtightplot(4,1,2,0.07,0.08,0.1);
h3 = subtightplot(4,1,3,0.07,0.08,0.1);
h4 = subtightplot(4,1,4,0.07,0.08,0.1);

axes(h1);hold(h1,'on');
[n b] = hist(repdata_sal,[-3:0.2:3]);stairs(h1,b,n/sum(n),'k','linewidth',2)
[n b] = hist(repdata,[-6:0.2:2]);stairs(h1,b,n/sum(n),'r','linewidth',2)
ylimits = get(h1,'ylim');
plot(h1,mean(repdata_sal),ylimits(2),'kV','markersize',8);
plot(h1,mean(repdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(repdata,repdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h1);
hold(h1,'off');

axes(h2);hold(h2,'on');
[n b] = hist(acorrdata_sal,[-3:0.2:3]);stairs(h2,b,n/sum(n),'k','linewidth',2)
[n b] = hist(acorrdata,[-6:0.2:2]);stairs(h2,b,n/sum(n),'r','linewidth',2)
ylimits = get(h2,'ylim');
plot(h2,mean(acorrdata_sal),ylimits(2),'kV','markersize',8);
plot(h2,mean(acorrdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(acorrdata,acorrdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h2);
hold(h2,'off');

axes(h3);hold(h3,'on');
[n b] = hist(sdurdata_sal,[-3:0.2:3]);stairs(h3,b,n/sum(n),'k','linewidth',2)
[n b] = hist(sdurdata,[-3:0.2:3]);stairs(h3,b,n/sum(n),'r','linewidth',2)
ylimits = get(h3,'ylim');
plot(h3,mean(sdurdata_sal),ylimits(2),'kV','markersize',8);
plot(h3,mean(sdurdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(sdurdata,sdurdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h3);
hold(h3,'off');

axes(h4);hold(h4,'on');
[n b] = hist(gdurdata_sal,[-3:0.2:3]);stairs(h4,b,n/sum(n),'k','linewidth',2)
[n b] = hist(gdurdata,[-3:0.2:3]);stairs(h4,b,n/sum(n),'r','linewidth',2)
ylimits = get(h4,'ylim');
plot(h4,mean(gdurdata_sal),ylimits(2),'kV','markersize',8);
plot(h4,mean(gdurdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(gdurdata,gdurdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h4);
hold(h4,'off');

set(h1,'fontweight','bold');
ylabel(h1,'probability');
xlabel(h1,'z-score');
title(h1,'repeat length');

set(h2,'fontweight','bold');
ylabel(h2,'probability');
xlabel(h2,'z-score');
title(h2,'acorr');

set(h3,'fontweight','bold');
ylabel(h3,'probability');
xlabel(h3,'z-score');
title(h3,'syll dur');

set(h4,'fontweight','bold');
ylabel(h4,'probability');
xlabel(h4,'z-score');
title(h4,'gap dur');