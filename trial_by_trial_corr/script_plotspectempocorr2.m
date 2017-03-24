%pairwise correlation across birds, each point = motif/gdur/sdur and mean
%syllable change for that bird (by motif trial)

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
lname = {};
lname_sal = {};
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
     lname = [lname; repmat({ff(i).name},numtrials,1)];
     for ii = 1:numtrials
         xdata = x(ii);
         fv = [fv; 100*(nanmean(structfun(@(x) x.fv.rel, xdata)))];
         vol = [vol; 100*(nanmean(structfun(@(x) x.vol.rel,xdata)))];
         ent = [ent; 100*(nanmean(structfun(@(x) x.ent.rel,xdata)))];
         pcv = [pcv; 100*(nanmean(structfun(@(x) x.pcv,xdata))-1)]; 
     end
    
     numtrials = length(y);
     lname_sal = [lname_sal; repmat({ff(i).name},numtrials,1)];
     for ii = 1:numtrials
         ydata = y(ii);
         fv_sal = [fv_sal; 100*(nanmean(structfun(@(x) x.fv.rel, ydata)))];
         vol_sal = [vol_sal; 100*(nanmean(structfun(@(x) x.vol.rel,ydata)))];
         ent_sal = [ent_sal; 100*(nanmean(structfun(@(x) x.ent.rel,ydata)))];
         pcv_sal = [pcv_sal; 100*(nanmean(structfun(@(x) x.pcv,ydata))-1)];
     end
     
     x2data = 100*(arrayfun(@(x) x.macorr.rel,x2)'-1);
     y2data =100*(arrayfun(@(x) x.macorr.rel,y2)'-1);
     motif_fv = [motif_fv; [x2data fv]];
     motif_fv_sal = [motif_fv_sal; [y2data fv_sal]];
     motif_vol = [motif_vol; [x2data vol]];
     motif_vol_sal = [motif_vol_sal; [y2data vol_sal]];
     motif_ent = [motif_ent; [x2data ent]];
     motif_ent_sal = [motif_ent_sal; [y2data ent_sal]];
     motif_pcv = [motif_pcv; [x2data pcv]];
     motif_pcv_sal = [motif_pcv_sal; [y2data pcv_sal]];

     x2data = 100*(arrayfun(@(x) x.sdur.rel,x2)'-1);
     y2data =100*(arrayfun(@(x) x.sdur.rel,y2)'-1);
     sdur_fv = [sdur_fv; [x2data fv]];
     sdur_fv_sal = [sdur_fv_sal; [y2data fv_sal]];
     sdur_vol = [sdur_vol; [x2data vol]];
     sdur_vol_sal = [sdur_vol_sal; [y2data vol_sal]];
     sdur_ent = [sdur_ent; [x2data ent]];
     sdur_ent_sal = [sdur_ent_sal; [y2data ent_sal]];
     sdur_pcv = [sdur_pcv; [x2data pcv]];
     sdur_pcv_sal = [sdur_pcv_sal; [y2data pcv_sal]];

     x2data = 100*(arrayfun(@(x) x.gdur.rel,x2)'-1);
     y2data =100*(arrayfun(@(x) x.gdur.rel,y2)'-1);
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
h1 = subtightplot(2,4,1,[0.15 0.05],0.1,0.1);
gscatter(motif_fv(:,1),motif_fv(:,2),lname,'','o',8);
[r p] = corrcoef(motif_fv(:,1),motif_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'motif acorr');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.1,0.1);
gscatter(motif_vol(:,1),motif_vol(:,2),lname,'','o',8,'off');
[r p] = corrcoef(motif_vol(:,1),motif_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'motif acorr');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.1,0.1);
gscatter(motif_ent(:,1),motif_ent(:,2),lname,'','o',8,'off');
[r p] = corrcoef(motif_ent(:,1),motif_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'motif acorr');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.1,0.1);
gscatter(motif_pcv(:,1),motif_pcv(:,2),lname,'','o',8,'off');
[r p] = corrcoef(motif_pcv(:,1),motif_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'motif acorr');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.1,0.1);
gscatter(motif_fv_sal(:,1),motif_fv_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(motif_fv_sal(:,1),motif_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'motif acorr');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.1,0.1);
gscatter(motif_vol_sal(:,1),motif_vol_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(motif_vol_sal(:,1),motif_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'motif acorr');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.1,0.1);
gscatter(motif_ent_sal(:,1),motif_ent_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(motif_ent_sal(:,1),motif_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'motif acorr');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.1,0.1);
gscatter(motif_pcv_sal(:,1),motif_pcv_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(motif_pcv_sal(:,1),motif_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'motif acorr');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.1,0.1);
gscatter(sdur_fv(:,1),sdur_fv(:,2),lname,'','o',8);
[r p] = corrcoef(sdur_fv(:,1),sdur_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'syll dur');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.1,0.1);
gscatter(sdur_vol(:,1),sdur_vol(:,2),lname,'','o',8,'off');
[r p] = corrcoef(sdur_vol(:,1),sdur_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'syll dur');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.1,0.1);
gscatter(sdur_ent(:,1),sdur_ent(:,2),lname,'','o',8,'off');
[r p] = corrcoef(sdur_ent(:,1),sdur_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'syll dur');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.1,0.1);
gscatter(sdur_pcv(:,1),sdur_pcv(:,2),lname,'','o',8,'off');
[r p] = corrcoef(sdur_pcv(:,1),sdur_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'syll dur');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.1,0.1);
gscatter(sdur_fv_sal(:,1),sdur_fv_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(sdur_fv_sal(:,1),sdur_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'syll dur');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.1,0.1);
gscatter(sdur_vol_sal(:,1),sdur_vol_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(sdur_vol_sal(:,1),sdur_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'syll dur');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.1,0.1);
gscatter(sdur_ent_sal(:,1),sdur_ent_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(sdur_ent_sal(:,1),sdur_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'syll dur');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.1,0.1);
gscatter(sdur_pcv_sal(:,1),sdur_pcv_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(sdur_pcv_sal(:,1),sdur_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'syll dur');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.1,0.1);
gscatter(gdur_fv(:,1),gdur_fv(:,2),lname,'','o',8);
[r p] = corrcoef(gdur_fv(:,1),gdur_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'gap dur');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.1,0.1);
gscatter(gdur_vol(:,1),gdur_vol(:,2),lname,'','o',8,'off');
[r p] = corrcoef(gdur_vol(:,1),gdur_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'gap dur');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.1,0.1);
gscatter(gdur_ent(:,1),gdur_ent(:,2),lname,'','o',8,'off');
[r p] = corrcoef(gdur_ent(:,1),gdur_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'gap dur');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.1,0.1);
gscatter(gdur_pcv(:,1),gdur_pcv(:,2),lname,'','o',8,'off');
[r p] = corrcoef(gdur_pcv(:,1),gdur_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'gap dur');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.1,0.1);
gscatter(gdur_fv_sal(:,1),gdur_fv_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(gdur_fv_sal(:,1),gdur_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'gap dur');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.1,0.1);
gscatter(gdur_vol_sal(:,1),gdur_vol_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(gdur_vol_sal(:,1),gdur_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'gap dur');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.1,0.1);
gscatter(gdur_ent_sal(:,1),gdur_ent_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(gdur_ent_sal(:,1),gdur_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'gap dur');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.1,0.1);
gscatter(gdur_pcv_sal(:,1),gdur_pcv_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(gdur_pcv_sal(:,1),gdur_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'gap dur');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');
