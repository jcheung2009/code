%distribution by repeat

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
         repdata = [repdata; nanmean(ydata)];
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).acorr];
         acorrdata = [acorrdata; nanmean(ydata)];
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).sdur];
         sdurdata = [sdurdata; nanmean(ydata)];
         
         ydata = [x(:).([repeats{ii}])];
         ydata = [ydata(:).gdur];
         gdurdata = [gdurdata; nanmean(ydata)];

         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).rep];
         repdata_sal = [repdata_sal; nanmean(ydata)];
         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).acorr];
         acorrdata_sal = [acorrdata_sal; nanmean(ydata)];
         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).sdur];
         sdurdata_sal = [sdurdata_sal; nanmean(ydata)];
         
         ydata = [y(:).([repeats{ii}])];
         ydata = [ydata(:).gdur];
         gdurdata_sal = [gdurdata_sal; nanmean(ydata)];
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
[p h stat] = signrank(repdata,repdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h1);
hold(h1,'off');

axes(h2);hold(h2,'on');
[n b] = hist(acorrdata_sal,[-3:0.2:3]);stairs(h2,b,n/sum(n),'k','linewidth',2)
[n b] = hist(acorrdata,[-6:0.2:2]);stairs(h2,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(acorrdata,acorrdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h2);
hold(h2,'off');

axes(h3);hold(h3,'on');
[n b] = hist(sdurdata_sal,[-3:0.2:3]);stairs(h3,b,n/sum(n),'k','linewidth',2)
[n b] = hist(sdurdata,[-3:0.2:3]);stairs(h3,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(sdurdata,sdurdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h3);
hold(h3,'off');

axes(h4);hold(h4,'on');
[n b] = hist(gdurdata_sal,[-3:0.2:3]);stairs(h4,b,n/sum(n),'k','linewidth',2)
[n b] = hist(gdurdata,[-3:0.2:3]);stairs(h4,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(gdurdata,gdurdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
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