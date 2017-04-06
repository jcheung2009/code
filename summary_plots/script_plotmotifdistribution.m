%distribution of temporal features by motif cases

ff = load_batchf('naspm_birds');

acorrdata = [];
% motifdurdata = [];
sdurdata = [];
gdurdata = [];

acorrdata_sal = [];
% motifdurdata_sal = [];
sdurdata_sal = [];
gdurdata_sal = [];
lname = {};
for i = 1:length(ff)
    try
     load([ff(i).name,'/analysis/data_structures/summary']);
    catch
     load(['deaf_and_naspm/',ff(i).name,'/analysis/data_structures/summary']);
    end
     
     if exist(['motifnaspm_',ff(i).name])
         x = eval(['motifnaspm_',ff(i).name]);
     elseif exist(['motifiem_',ff(i).name]) 
        x = eval(['motifiem_',ff(i).name]);
     end
     if ~exist(['motifsal_',ff(i).name])
         continue
     end
     lname = [lname; ff(i).name];
     y = eval(['motifsal_',ff(i).name]);
%      x = eval(['motifapv_',ff(i).name]);
%      if exist(['motifsal_',ff(i).name])
%          y = eval(['motifsal_',ff(i).name]);
%      end
    
     acorr = [x(:).macorr];
%      motifdur = [x(:).mdur];
     sdur = [x(:).sdur];
     gdur = [x(:).gdur];
     
     acorrdata = [acorrdata; nanmean([acorr(:).rel]')];
%      motifdurdata = [motifdurdata; nanmean(100*([motifdur(:).rel]'-1))];
     sdurdata = [sdurdata; nanmean([sdur(:).rel]')];
     gdurdata = [gdurdata; nanmean([gdur(:).rel]')];
     
     acorr_sal = [y(:).macorr];
%      motifdur_sal = [y(:).mdur];
     sdur_sal = [y(:).sdur];
     gdur_sal = [y(:).gdur];
     
     acorrdata_sal = [acorrdata_sal; nanmean([acorr_sal(:).rel]')];
%      motifdurdata_sal = [motifdurdata_sal; nanmean(100*([motifdur_sal(:).rel]'-1))];
     sdurdata_sal = [sdurdata_sal; nanmean([sdur_sal(:).rel]')];
     gdurdata_sal = [gdurdata_sal; nanmean([gdur_sal(:).rel]')];  
       

end
         
figure;
h1 = subtightplot(3,1,1,[0.1 0.05],0.08,0.3);
h2 = subtightplot(3,1,2,[0.1 0.05],0.08,0.3);
h3 = subtightplot(3,1,3,[0.1 0.05],0.08,0.3);



axes(h1);hold(h1,'on');
plot(h1,repmat([0.5 1.5]',1,length(acorrdata)),[acorrdata_sal acorrdata]',...
    'marker','o','markersize',8,'linewidth',2);hold on;
plot(h1,[0 2],[0 0],'c','linewidth',2);hold on;
[p h stat] = signrank(acorrdata,acorrdata_sal);
str = {['motif acorr'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
title(h1,str);
hold(h1,'off');
xlim(h1,[0 2]);
legend(h1,lname);
set(h1,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
ylabel(h1,'percent change');

% axes(h2);hold(h2,'on');
% plot(h2,repmat([0.5 1.5]',1,length(motifdurdata)),[motifdurdata_sal motifdurdata]',...
%     'marker','o','markersize',8,'linewidth',2);hold on;
% plot(h2,[0 2],[0 0],'c','linewidth',2);hold on;
% [p h stat] = signrank(motifdurdata,motifdurdata_sal);
% str = {['motif duration'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% title(h2,str);
% hold(h2,'off');
% xlim(h2,[0 2]);
% set(h2,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
% ylabel(h2,'percent change');

axes(h2);hold(h2,'on');
plot(h2,repmat([0.5 1.5]',1,length(sdurdata)),[sdurdata_sal sdurdata]',...
    'marker','o','markersize',8,'linewidth',2);hold on;
plot(h2,[0 2],[0 0],'c','linewidth',2);hold on;
[p h stat] = signrank(sdurdata,sdurdata_sal);
str = {['syll duration'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
title(h2,str);
hold(h2,'off');
xlim(h2,[0 2]);
set(h2,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
ylabel(h2,'percent change');

axes(h3);hold(h3,'on');
plot(h3,repmat([0.5 1.5]',1,length(gdurdata)),[gdurdata_sal gdurdata]',...
    'marker','o','markersize',8,'linewidth',2);hold on;
plot(h3,[0 2],[0 0],'c','linewidth',2);hold on;
[p h stat] = signrank(gdurdata,gdurdata_sal);
str = {['gap duration'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
title(h3,str);
hold(h3,'off');
xlim(h3,[0 2]);
set(h3,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
ylabel(h3,'percent change');


% axes(h1);hold(h1,'on');
% [n b] = hist(acorrdata_sal,[-20:5:10]);stairs(h1,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(acorrdata,[-20:5:10]);stairs(h1,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h1,'ylim');
% plot(h1,mean(acorrdata_sal),ylimits(2),'kV','markersize',8);
% plot(h1,mean(acorrdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(acorrdata,acorrdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h1);
% hold(h1,'off');
% 
% axes(h2);hold(h2,'on');
% [n b] = hist(h2_sal,[-20:5:10]);stairs(h2,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(motifdurdata,[-20:5:10]);stairs(h2,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h2,'ylim');
% plot(h2,mean(motifdurdata_sal),ylimits(2),'kV','markersize',8);
% plot(h2,mean(motifdurdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(motifdurdata,motifdurdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h2);
% hold(h2,'off');
% 
% axes(h3);hold(h3,'on');
% [n b] = hist(sdurdata_sal,[-20:5:10]);stairs(h3,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(sdurdata,[-20:5:10]);stairs(h3,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h3,'ylim');
% plot(h3,mean(sdurdata_sal),ylimits(2),'kV','markersize',8);
% plot(h3,mean(sdurdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(sdurdata,sdurdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h3);
% hold(h3,'off');
% 
% axes(h4);hold(h4,'on');
% [n b] = hist(gdurdata_sal,[-20:5:10]);stairs(h4,b,n/sum(n),'k','linewidth',2)
% [n b] = hist(gdurdata,[-20:5:10]);stairs(h4,b,n/sum(n),'r','linewidth',2)
% ylimits = get(h4,'ylim');
% plot(h4,mean(gdurdata_sal),ylimits(2),'kV','markersize',8);
% plot(h4,mean(gdurdata),ylimits(2),'rV','markersize',8);
% [p h stat] = signrank(gdurdata,gdurdata_sal);
% str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
% text(0,0,str,'Parent',h4);
% hold(h4,'off');

% set(h1,'fontweight','bold');
% ylabel(h1,'probability');
% xlabel(h1,'percent change');
% title(h1,'motif acorr');
% 
% set(h2,'fontweight','bold');
% ylabel(h2,'probability');
% xlabel(h2,'percent change');
% title(h2,'motif dur');
% 
% set(h3,'fontweight','bold');
% ylabel(h3,'probability');
% xlabel(h3,'percent change');
% title(h3,'syll dur');
% 
% set(h4,'fontweight','bold');
% ylabel(h4,'probability');
% xlabel(h4,'percent change');
% title(h4,'gap dur');