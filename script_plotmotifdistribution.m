%distribution by motif

ff = load_batchf('naspm_birds');

acorrdata = [];
motifdurdata = [];
sdurdata = [];
gdurdata = [];

acorrdata_sal = [];
motifdurdata_sal = [];
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

     acorrdata = [acorrdata; nanmean([x(:).macorr])];
     motifdurdata = [motifdurdata; nanmean([x(:).mdur])];
     sdurdata = [sdurdata; nanmean([x(:).sdur])];
     gdurdata = [gdurdata; nanmean([x(:).gdur])];
     
     acorrdata_sal = [acorrdata_sal; nanmean([y(:).macorr])];
     motifdurdata_sal = [motifdurdata_sal; nanmean([y(:).mdur])];
     sdurdata_sal = [sdurdata_sal; nanmean([y(:).sdur])];
     gdurdata_sal = [gdurdata_sal; nanmean([y(:).gdur])];    

end
         
figure;
h1 = subtightplot(4,1,1,0.07,0.08,0.1);
h2 = subtightplot(4,1,2,0.07,0.08,0.1);
h3 = subtightplot(4,1,3,0.07,0.08,0.1);
h4 = subtightplot(4,1,4,0.07,0.08,0.1);

axes(h1);hold(h1,'on');
[n b] = hist(acorrdata_sal,[-6:0.2:2]);stairs(h1,b,n/sum(n),'k','linewidth',2)
[n b] = hist(acorrdata,[-6:0.2:2]);stairs(h1,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(acorrdata,acorrdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h1);
hold(h1,'off');

axes(h2);hold(h2,'on');
[n b] = hist(motifdurdata_sal,[-6:0.2:2]);stairs(h2,b,n/sum(n),'k','linewidth',2)
[n b] = hist(motifdurdata,[-6:0.2:2]);stairs(h2,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(motifdurdata,motifdurdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h2);
hold(h2,'off');

axes(h3);hold(h3,'on');
[n b] = hist(sdurdata_sal,[-6:0.2:2]);stairs(h3,b,n/sum(n),'k','linewidth',2)
[n b] = hist(sdurdata,[-6:0.2:2]);stairs(h3,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(sdurdata,sdurdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h3);
hold(h3,'off');

axes(h4);hold(h4,'on');
[n b] = hist(gdurdata_sal,[-6:0.2:2]);stairs(h4,b,n/sum(n),'k','linewidth',2)
[n b] = hist(gdurdata,[-6:0.2:2]);stairs(h4,b,n/sum(n),'r','linewidth',2)
[p h stat] = signrank(gdurdata,gdurdata_sal);
str = {['stat = ',num2str(stat.signedrank),' ; p = ',num2str(p)]};
text(0,0,str,'Parent',h4);
hold(h4,'off');

set(h1,'fontweight','bold');
ylabel(h1,'probability');
xlabel(h1,'z-score');
title(h1,'motif acorr');

set(h2,'fontweight','bold');
ylabel(h2,'probability');
xlabel(h2,'z-score');
title(h2,'motif dur');

set(h3,'fontweight','bold');
ylabel(h3,'probability');
xlabel(h3,'z-score');
title(h3,'syll dur');

set(h4,'fontweight','bold');
ylabel(h4,'probability');
xlabel(h4,'z-score');
title(h4,'gap dur');