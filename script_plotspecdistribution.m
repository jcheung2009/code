%distribution of spectral features by syllables

ff = load_batchf('apv_birds');

fvdata = [];
voldata = [];
entdata = [];
pcvdata = [];

fvdata_sal = [];
voldata_sal = [];
entdata_sal = [];
pcvdata_sal = [];
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['fvnaspm_',ff(i).name])
         x = eval(['fvnaspm_',ff(i).name]);
     elseif exist(['fviem_',ff(i).name]) 
        x = eval(['fviem_',ff(i).name]);
     end
     y = eval(['fvsal_',ff(i).name]);
%      x = eval(['fvapv_',ff(i).name]);
%      if exist(['fvsal_',ff(i).name])
%          y = eval(['fvsal_',ff(i).name]);
%      end
     
     syllables = fieldnames(x);
     for ii = 1:length(syllables)
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).fv];
         ydata = 100*[ydata(:).rel];
         fvdata = [fvdata; nanmean(ydata)];
         
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).vol];
         ydata = 100*[ydata(:).rel];
         voldata = [voldata; nanmean(ydata)];
         
         ydata = [x(:).([syllables{ii}])];
         ydata = [ydata(:).ent];
         ydata = 100*[ydata(:).rel];
         entdata = [entdata; nanmean(ydata)];
         
         ydata = [x(:).([syllables{ii}])];
         pcvdata = [pcvdata; 100*nanmean([ydata(:).pcv]-1)];
         
         ydata = [y(:).([syllables{ii}])];
         ydata = [ydata(:).fv];
         ydata = 100*[ydata(:).rel];
         fvdata_sal = [fvdata_sal; nanmean(ydata)];
         
         ydata = [y(:).([syllables{ii}])];
         ydata = [ydata(:).vol];
         ydata = 100*[ydata(:).rel];
         voldata_sal = [voldata_sal; nanmean(ydata)];
         
         ydata = [y(:).([syllables{ii}])];
         ydata = [ydata(:).ent];
         ydata = 100*[ydata(:).rel];
         entdata_sal = [entdata_sal; nanmean(ydata)];
         
         ydata = [y(:).([syllables{ii}])];
         pcvdata_sal = [pcvdata_sal; 100*nanmean([ydata(:).pcv]-1)];    
     end
end
         
figure;
h1 = subtightplot(4,1,1,0.07,0.08,0.15);
h2 = subtightplot(4,1,2,0.07,0.08,0.15);
h3 = subtightplot(4,1,3,0.07,0.08,0.15);
h4 = subtightplot(4,1,4,0.07,0.08,0.15);

axes(h1);hold(h1,'on');
[n b] = hist(fvdata_sal,[-10:2:20]);stairs(h1,b,n/sum(n),'k','linewidth',2)
[n b] = hist(fvdata,[-10:2:20]);stairs(h1,b,n/sum(n),'r','linewidth',2)
ylimits = get(h1,'ylim');
plot(h1,mean(fvdata_sal),ylimits(2),'kV','markersize',8);
plot(h1,mean(fvdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest(fvdata,fvdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h1);
hold(h1,'off');

axes(h2);hold(h2,'on');
[n b] = hist(voldata_sal,[-10:2:20]);stairs(h2,b,n/sum(n),'k','linewidth',2)
[n b] = hist(voldata,[-10:2:20]);stairs(h2,b,n/sum(n),'r','linewidth',2)
ylimits = get(h2,'ylim');
plot(h2,mean(voldata_sal),ylimits(2),'kV','markersize',8);
plot(h2,mean(voldata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest(voldata,voldata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h2);
hold(h2,'off');

axes(h3);hold(h3,'on');
[n b] = hist(entdata_sal,[-10:2:20]);stairs(h3,b,n/sum(n),'k','linewidth',2)
[n b] = hist(entdata,[-10:2:20]);stairs(h3,b,n/sum(n),'r','linewidth',2)
ylimits = get(h1,'ylim');
plot(h3,mean(entdata_sal),ylimits(2),'kV','markersize',8);
plot(h3,mean(entdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest(entdata,entdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h3);
hold(h3,'off');

axes(h4);hold(h4,'on');
[n b] = hist(pcvdata_sal,[-100:10:100]);stairs(h4,b,n/sum(n),'k','linewidth',2)
[n b] = hist(pcvdata,[-100:10:100]);stairs(h4,b,n/sum(n),'r','linewidth',2)
ylimits = get(h4,'ylim');
plot(h4,mean(pcvdata_sal),ylimits(2),'kV','markersize',8);
plot(h4,mean(pcvdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest(pcvdata,pcvdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h4);
hold(h4,'off');

set(h1,'fontweight','bold');
ylabel(h1,'probability');
xlabel(h1,'percent change');
title(h1,'pitch');

set(h2,'fontweight','bold');
ylabel(h2,'probability');
xlabel(h2,'percent change');
title(h2,'volume');

set(h3,'fontweight','bold');
ylabel(h3,'probability');
xlabel(h3,'percent change');
title(h3,'entropy');

set(h4,'fontweight','bold');
ylabel(h4,'probability');
xlabel(h4,'percent change');
title(h4,'pitch CV');
     