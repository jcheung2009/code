%DISTRIBUTION by motif by trial

ff = load_batchf('naspm_birds');

acorrdata = [];
% motifdurdata = [];
sdurdata = [];
gdurdata = [];

acorrdata_sal = [];
% motifdurdata_sal = [];
sdurdata_sal = [];
gdurdata_sal = [];
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['motifnaspm_',ff(i).name])
         x = eval(['motifnaspm_',ff(i).name]);
     elseif exist(['motifiem_',ff(i).name]) 
        x = eval(['motifiem_',ff(i).name]);
     end
     
     if exist(['motifsal_',ff(i).name])
         y = eval(['motifsal_',ff(i).name]);
     end
    
     acorr = [x(:).macorr];
%      motifdur = [x(:).mdur];
     sdur = [x(:).sdur];
     gdur = [x(:).gdur];
     
     acorrdata = [acorrdata; 100*([acorr(:).rel]'-1)];
%      motifdurdata = [motifdurdata; 100*([motifdur(:).rel]'-1)];
     sdurdata = [sdurdata; 100*([sdur(:).rel]'-1)];
     gdurdata = [gdurdata; 100*([gdur(:).rel]'-1)];
     
     acorr_sal = [y(:).macorr];
%      motifdur_sal = [y(:).mdur];
     sdur_sal = [y(:).sdur];
     gdur_sal = [y(:).gdur];
     
     acorrdata_sal = [acorrdata_sal; 100*([acorr_sal(:).rel]'-1)];
%      motifdurdata_sal = [motifdurdata_sal; 100*([motifdur_sal(:).rel]'-1)];
     sdurdata_sal = [sdurdata_sal; 100*([sdur_sal(:).rel]'-1)];
     gdurdata_sal = [gdurdata_sal; 100*([gdur_sal(:).rel]'-1)];    

end
         
figure;
h1 = subtightplot(4,1,1,0.07,0.08,0.15);
h2 = subtightplot(4,1,2,0.07,0.08,0.15);
h3 = subtightplot(4,1,3,0.07,0.08,0.15);
h4 = subtightplot(4,1,4,0.07,0.08,0.15);

axes(h1);hold(h1,'on');
[n b] = hist(acorrdata_sal,[-20:2:20]);stairs(h1,b,n/sum(n),'k','linewidth',2)
[n b] = hist(acorrdata,[-20:2:20]);stairs(h1,b,n/sum(n),'r','linewidth',2)
ylimits = get(h1,'ylim');
plot(h1,nanmean(acorrdata_sal),ylimits(2),'kV','markersize',8);
plot(h1,nanmean(acorrdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(acorrdata,acorrdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h1);
hold(h1,'off');

axes(h2);hold(h2,'on');
[n b] = hist(motifdurdata_sal,[-20:2:20]);stairs(h2,b,n/sum(n),'k','linewidth',2)
[n b] = hist(motifdurdata,[-20:2:20]);stairs(h2,b,n/sum(n),'r','linewidth',2)
ylimits = get(h2,'ylim');
plot(h2,mean(motifdurdata_sal),ylimits(2),'kV','markersize',8);
plot(h2,mean(motifdurdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(motifdurdata,motifdurdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h2);
hold(h2,'off');

axes(h3);hold(h3,'on');
[n b] = hist(sdurdata_sal,[-20:2:20]);stairs(h3,b,n/sum(n),'k','linewidth',2)
[n b] = hist(sdurdata,[-20:2:20]);stairs(h3,b,n/sum(n),'r','linewidth',2)
ylimits = get(h3,'ylim');
plot(h3,mean(sdurdata_sal),ylimits(2),'kV','markersize',8);
plot(h3,mean(sdurdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(sdurdata,sdurdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h3);
hold(h3,'off');

axes(h4);hold(h4,'on');
[n b] = hist(gdurdata_sal,[-20:2:20]);stairs(h4,b,n/sum(n),'k','linewidth',2)
[n b] = hist(gdurdata,[-20:2:20]);stairs(h4,b,n/sum(n),'r','linewidth',2)
ylimits = get(h4,'ylim');
plot(h4,mean(gdurdata_sal),ylimits(2),'kV','markersize',8);
plot(h4,mean(gdurdata),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(gdurdata,gdurdata_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str,'Parent',h4);
hold(h4,'off');

set(h1,'fontweight','bold');
ylabel(h1,'probability');
xlabel(h1,'percent change');
title(h1,'motif acorr');

set(h2,'fontweight','bold');
ylabel(h2,'probability');
xlabel(h2,'percent change');
title(h2,'motif dur');

set(h3,'fontweight','bold');
ylabel(h3,'probability');
xlabel(h3,'percent change');
title(h3,'syll dur');

set(h4,'fontweight','bold');
ylabel(h4,'probability');
xlabel(h4,'percent change');
title(h4,'gap dur');