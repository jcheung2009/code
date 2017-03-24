%distribution of spectral features by syllables trials

ff = load_batchf('naspm_birds');

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
     
     if exist(['fvsal_',ff(i).name])
         y = eval(['fvsal_',ff(i).name]);
     end
     
     syllables = fieldnames(x);
     for ii = 1:length(syllables)
         ydata = [x(:).([syllables{ii}])];
         fvdata = [fvdata; [ydata(:).fv]'];
         
         ydata = [x(:).([syllables{ii}])];
         voldata = [voldata; [ydata(:).vol]'];
         
         ydata = [x(:).([syllables{ii}])];
         entdata = [entdata; [ydata(:).ent]'];
         
         ydata = [x(:).([syllables{ii}])];
         pcvdata = [pcvdata; [ydata(:).pcv]'-1];
         
         ydata = [y(:).([syllables{ii}])];
         fvdata_sal = [fvdata_sal; [ydata(:).fv]'];
         
         ydata = [y(:).([syllables{ii}])];
         voldata_sal = [voldata_sal; [ydata(:).vol]'];
         
         ydata = [y(:).([syllables{ii}])];
         entdata_sal = [entdata_sal; [ydata(:).ent]'];
         
         ydata = [y(:).([syllables{ii}])];
         pcvdata_sal = [pcvdata_sal; [ydata(:).pcv]'-1];    
     end
end
         
figure;
h1 = subtightplot(4,1,1,0.07,0.08,0.1);
h2 = subtightplot(4,1,2,0.07,0.08,0.1);
h3 = subtightplot(4,1,3,0.07,0.08,0.1);
h4 = subtightplot(4,1,4,0.07,0.08,0.1);

axes(h1);hold(h1,'on');
[n b] = hist(fvdata_sal,[-4:0.2:4]);stairs(h1,b,n/sum(n),'k','linewidth',2)
[n b] = hist(fvdata,[-4:0.2:4]);stairs(h1,b,n/sum(n),'r','linewidth',2)
ylimits = get(h1,'ylim');
plot(h1,mean(fvdata_sal),ylimits(2),'kV','markersize',8);
plot(h1,mean(fvdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(fvdata,fvdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h1);
hold(h1,'off');

axes(h2);hold(h2,'on');
[n b] = hist(voldata_sal,[-4:0.2:4]);stairs(h2,b,n/sum(n),'k','linewidth',2)
[n b] = hist(voldata,[-4:0.2:4]);stairs(h2,b,n/sum(n),'r','linewidth',2)
ylimits = get(h2,'ylim');
plot(h2,mean(voldata_sal),ylimits(2),'kV','markersize',8);
plot(h2,mean(voldata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(voldata,voldata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h2);
hold(h2,'off');

axes(h3);hold(h3,'on');
[n b] = hist(entdata_sal,[-4:0.2:4]);stairs(h3,b,n/sum(n),'k','linewidth',2)
[n b] = hist(entdata,[-4:0.2:4]);stairs(h3,b,n/sum(n),'r','linewidth',2)
ylimits = get(h1,'ylim');
plot(h3,mean(entdata_sal),ylimits(2),'kV','markersize',8);
plot(h3,mean(entdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(entdata,entdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h3);
hold(h3,'off');

axes(h4);hold(h4,'on');
[n b] = hist(pcvdata_sal,[-1:0.2:1]);stairs(h4,b,n/sum(n),'k','linewidth',2)
[n b] = hist(pcvdata,[-1:0.2:1]);stairs(h4,b,n/sum(n),'r','linewidth',2)
ylimits = get(h4,'ylim');
plot(h4,mean(pcvdata_sal),ylimits(2),'kV','markersize',8);
plot(h4,mean(pcvdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(pcvdata,pcvdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h4);
hold(h4,'off');

set(h1,'fontweight','bold');
ylabel(h1,'probability');
xlabel(h1,'z-score');
title(h1,'pitch');

set(h2,'fontweight','bold');
ylabel(h2,'probability');
xlabel(h2,'z-score');
title(h2,'volume');

set(h3,'fontweight','bold');
ylabel(h3,'probability');
xlabel(h3,'z-score');
title(h3,'entropy');

set(h4,'fontweight','bold');
ylabel(h4,'probability');
xlabel(h4,'percent change');
title(h4,'pitch CV');
     