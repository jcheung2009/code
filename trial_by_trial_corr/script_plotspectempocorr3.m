%pairwise correlation across birds, each point = bird 

ff = load_batchf('naspm_birds');

motif_fv = [];
motif_vol = [];
motif_ent = [];
motif_pcv = [];

motif_fv_sal = [];
motif_vol_sal = [];
motif_ent_sal = [];
motif_pcv_sal = [];

sdur_fv = [];
sdur_vol = [];
sdur_ent = [];
sdur_pcv = [];

sdur_fv_sal = [];
sdur_vol_sal = [];
sdur_ent_sal = [];
sdur_pcv_sal = [];

gdur_fv = [];
gdur_vol = [];
gdur_ent = [];
gdur_pcv = [];

gdur_fv_sal = [];
gdur_vol_sal = [];
gdur_ent_sal = [];
gdur_pcv_sal = [];

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
     
     if exist(['motifnaspm_',ff(i).name])
         x2 = eval(['motifnaspm_',ff(i).name]);
     elseif exist(['motifiem_',ff(i).name]) 
        x2 = eval(['motifiem_',ff(i).name]);
     end
     
     if exist(['motifsal_',ff(i).name])
         y2 = eval(['motifsal_',ff(i).name]);
     end
     
     numtrials = length(x);
     fv = [];fv_sal = [];
     vol = [];vol_sal = [];
     ent = [];ent_sal = [];
     pcv = [];pcv_sal = [];
     for ii = 1:numtrials
         xdata = x(ii);
         fv = [fv; nanmean(structfun(@(x) x.fv, xdata))];
         vol = [vol; nanmean(structfun(@(x) x.vol,xdata))];
         ent = [ent; nanmean(structfun(@(x) x.ent,xdata))];
         pcv = [pcv; nanmean(structfun(@(x) x.pcv,xdata))-1]; 
     end
    
     numtrials = length(y);
     for ii = 1:numtrials
         ydata = y(ii);
         fv_sal = [fv_sal; nanmean(structfun(@(x) x.fv, xdata))];
         vol_sal = [vol_sal; nanmean(structfun(@(x) x.vol,xdata))];
         ent_sal = [ent_sal; nanmean(structfun(@(x) x.ent,xdata))];
         pcv_sal = [pcv_sal; nanmean(structfun(@(x) x.pcv,xdata))-1];
     end
     
     x2data = nanmean([x2(:).macorr]');
     y2data =nanmean([y2(:).macorr]');
     fv = nanmean(fv); fv_sal = nanmean(fv_sal);
     vol = nanmean(vol); vol_sal = nanmean(vol_sal);
     ent = nanmean(ent); ent_sal = nanmean(ent_sal);
     pcv = nanmean(pcv); pcv_sal = nanmean(pcv_sal);
        
     motif_fv = [motif_fv; [x2data fv]];
     motif_fv_sal = [motif_fv_sal; [y2data fv_sal]];
     motif_vol = [motif_vol; [x2data vol]];
     motif_vol_sal = [motif_vol_sal; [y2data vol_sal]];
     motif_ent = [motif_ent; [x2data ent]];
     motif_ent_sal = [motif_ent_sal; [y2data ent_sal]];
     motif_pcv = [motif_pcv; [x2data pcv]];
     motif_pcv_sal = [motif_pcv_sal; [y2data pcv_sal]];

     x2data = nanmean([x2(:).sdur]');
     y2data =nanmean([y2(:).sdur]');
     sdur_fv = [sdur_fv; [x2data fv]];
     sdur_fv_sal = [sdur_fv_sal; [y2data fv_sal]];
     sdur_vol = [sdur_vol; [x2data vol]];
     sdur_vol_sal = [sdur_vol_sal; [y2data vol_sal]];
     sdur_ent = [sdur_ent; [x2data ent]];
     sdur_ent_sal = [sdur_ent_sal; [y2data ent_sal]];
     sdur_pcv = [sdur_pcv; [x2data pcv]];
     sdur_pcv_sal = [sdur_pcv_sal; [y2data pcv_sal]];

     x2data = nanmean([x2(:).gdur]');
     y2data =nanmean([y2(:).gdur]');
     gdur_fv = [gdur_fv; [x2data fv]];
     gdur_fv_sal = [gdur_fv_sal; [y2data fv_sal]];
     gdur_vol = [gdur_vol; [x2data vol]];
     gdur_vol_sal = [gdur_vol_sal; [y2data vol_sal]];
     gdur_ent = [gdur_ent; [x2data ent]];
     gdur_ent_sal = [gdur_ent_sal; [y2data ent_sal]];
     gdur_pcv = [gdur_pcv; [x2data pcv]];
     gdur_pcv_sal = [gdur_pcv_sal; [y2data pcv_sal]]; 
     
end

figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,motif_fv(:,1),motif_fv(:,2),'or','markersize',8);
[r p] = corrcoef(motif_fv(:,1),motif_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'motif acorr');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,motif_vol(:,1),motif_vol(:,2),'or','markersize',8);
[r p] = corrcoef(motif_vol(:,1),motif_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'motif acorr');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,motif_ent(:,1),motif_ent(:,2),'or','markersize',8);
[r p] = corrcoef(motif_ent(:,1),motif_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'motif acorr');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,motif_pcv(:,1),motif_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(motif_pcv(:,1),motif_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'motif acorr');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,motif_fv_sal(:,1),motif_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(motif_fv_sal(:,1),motif_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'motif acorr');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,motif_vol_sal(:,1),motif_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(motif_vol_sal(:,1),motif_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'motif acorr');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,motif_ent_sal(:,1),motif_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(motif_ent_sal(:,1),motif_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'motif acorr');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,motif_pcv_sal(:,1),motif_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(motif_pcv_sal(:,1),motif_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'motif acorr');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,sdur_fv(:,1),sdur_fv(:,2),'or','markersize',8);
[r p] = corrcoef(sdur_fv(:,1),sdur_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'syll dur');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,sdur_vol(:,1),sdur_vol(:,2),'or','markersize',8);
[r p] = corrcoef(sdur_vol(:,1),sdur_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'syll dur');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,sdur_ent(:,1),sdur_ent(:,2),'or','markersize',8);
[r p] = corrcoef(sdur_ent(:,1),sdur_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'syll dur');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,sdur_pcv(:,1),sdur_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(sdur_pcv(:,1),sdur_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'syll dur');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,sdur_fv_sal(:,1),sdur_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(sdur_fv_sal(:,1),sdur_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'syll dur');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,sdur_vol_sal(:,1),sdur_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(sdur_vol_sal(:,1),sdur_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'syll dur');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,sdur_ent_sal(:,1),sdur_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(sdur_ent_sal(:,1),sdur_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'syll dur');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,sdur_pcv_sal(:,1),sdur_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(sdur_pcv_sal(:,1),sdur_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'syll dur');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,gdur_fv(:,1),gdur_fv(:,2),'or','markersize',8);
[r p] = corrcoef(gdur_fv(:,1),gdur_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'gap dur');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,gdur_vol(:,1),gdur_vol(:,2),'or','markersize',8);
[r p] = corrcoef(gdur_vol(:,1),gdur_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'gap dur');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,gdur_ent(:,1),gdur_ent(:,2),'or','markersize',8);
[r p] = corrcoef(gdur_ent(:,1),gdur_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'gap dur');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,gdur_pcv(:,1),gdur_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(gdur_pcv(:,1),gdur_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'gap dur');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,gdur_fv_sal(:,1),gdur_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(gdur_fv_sal(:,1),gdur_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'gap dur');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,gdur_vol_sal(:,1),gdur_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(gdur_vol_sal(:,1),gdur_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'gap dur');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,gdur_ent_sal(:,1),gdur_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(gdur_ent_sal(:,1),gdur_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'gap dur');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,gdur_pcv_sal(:,1),gdur_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(gdur_pcv_sal(:,1),gdur_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'gap dur');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');
