%spec pairwise correlation across birds, each point = bird 
%relates changes across drug epochs and changes across saline epochs 
%not trial-by-trial

ff = load_batchf('naspm_birds');

fv_vol = [];
fv_ent = [];
fv_pcv = [];
vol_ent = [];
vol_pcv = [];
ent_pcv = [];

fv_vol_sal = [];
fv_ent_sal = [];
fv_pcv_sal = [];
vol_ent_sal = [];
vol_pcv_sal = [];
ent_pcv_sal = [];

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
     
     numtrials = length(x);
     fv = [];fv_sal = [];
     vol = [];vol_sal = [];
     ent = [];ent_sal = [];
     pcv = [];pcv_sal = [];
     for ii = 1:numtrials
         xdata = x(ii);
         fv = [fv; nanmean(structfun(@(x) x.fv.rel, xdata))];
         vol = [vol; nanmean(structfun(@(x) x.vol.rel,xdata))];
         ent = [ent; nanmean(structfun(@(x) x.ent.rel,xdata))];
         pcv = [pcv; nanmean(structfun(@(x) x.pcv,xdata))-1]; 
     end
     
     numtrials = length(y);
     for ii = 1:numtrials
         ydata = y(ii);
         fv_sal = [fv_sal; nanmean(structfun(@(x) x.fv.rel, ydata))];
         vol_sal = [vol_sal; nanmean(structfun(@(x) x.vol.rel,ydata))];
         ent_sal = [ent_sal; nanmean(structfun(@(x) x.ent.rel,ydata))];
         pcv_sal = [pcv_sal; nanmean(structfun(@(x) x.pcv,ydata))-1];
     end
     
     fv_vol = [fv_vol; 100*[nanmean(fv) nanmean(vol)]];
     fv_ent = [fv_ent; 100*[nanmean(fv) nanmean(ent)]];
     fv_pcv = [fv_pcv; 100*[nanmean(fv) nanmean(pcv)]];
     vol_ent = [vol_ent; 100*[nanmean(vol) nanmean(ent)]];
     vol_pcv = [vol_pcv; 100*[nanmean(vol) nanmean(pcv)]];
     ent_pcv = [ent_pcv; 100*[nanmean(ent) nanmean(pcv)]];
     
     fv_vol_sal = [fv_vol_sal; 100*[nanmean(fv_sal) nanmean(vol_sal)]];
     fv_ent_sal = [fv_ent_sal; 100*[nanmean(fv_sal) nanmean(ent_sal)]];
     fv_pcv_sal = [fv_pcv_sal; 100*[nanmean(fv_sal) nanmean(pcv_sal)]];
     vol_ent_sal = [vol_ent_sal; 100*[nanmean(vol_sal) nanmean(ent_sal)]];
     vol_pcv_sal = [vol_pcv_sal; 100*[nanmean(vol_sal) nanmean(pcv_sal)]];
     ent_pcv_sal = [ent_pcv_sal; 100*[nanmean(ent_sal) nanmean(pcv_sal)]];   
end

figure;hold on;
h1 = subtightplot(3,2,1,[0.1 0.1],0.08, 0.15);
gscatter(fv_vol(:,1),fv_vol(:,2),{ff(:).name}','','o',8);
[r p] = corrcoef(fv_vol(:,1),fv_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h1,str,'Color',c);
xlabel(h1,'pitch');
ylabel(h1,'volume');
set(h1,'fontweight','bold');

h2 = subtightplot(3,2,2,[0.1 0.1],0.08, 0.15);
gscatter(fv_ent(:,1),fv_ent(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(fv_ent(:,1),fv_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h2,str,'Color',c);
xlabel(h2,'pitch');
ylabel(h2,'entropy');
set(h2,'fontweight','bold')

h3 = subtightplot(3,2,3,[0.1 0.1],0.08, 0.15);
gscatter(fv_pcv(:,1),fv_pcv(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(fv_pcv(:,1),fv_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h3,str,'Color',c);
xlabel(h3,'pitch');
ylabel(h3,'pitch cv');
set(h3,'fontweight','bold');

h4 = subtightplot(3,2,4,[0.1 0.1],0.08, 0.15);
gscatter(vol_ent(:,1),vol_ent(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(vol_ent(:,1),vol_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h4,str,'Color',c);
xlabel(h4,'volume');
ylabel(h4,'entropy');
set(h4,'fontweight','bold');

h5 = subtightplot(3,2,5,[0.1 0.1],0.08, 0.15);
gscatter(vol_pcv(:,1),vol_pcv(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(vol_pcv(:,1),vol_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h5,str,'Color',c);
xlabel(h5,'volume');
ylabel(h5,'pitch cv');
set(h5,'fontweight','bold');

h6 = subtightplot(3,2,6,[0.1 0.1],0.08, 0.15);
gscatter(ent_pcv(:,1),ent_pcv(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(ent_pcv(:,1),ent_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h6,str,'Color',c);
xlabel(h6,'entropy');
ylabel(h6,'pitch cv');
set(h6,'fontweight','bold');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(3,2,1,[0.1 0.1],0.08, 0.15);
gscatter(fv_vol_sal(:,1),fv_vol_sal(:,2),{ff(:).name}','','o',8);
[r p] = corrcoef(fv_vol_sal(:,1),fv_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h1,str,'Color',c);
xlabel(h1,'pitch');
ylabel(h1,'volume');
set(h1,'fontweight','bold');

h2 = subtightplot(3,2,2,[0.1 0.1],0.08, 0.15);
gscatter(fv_ent_sal(:,1),fv_ent_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(fv_ent_sal(:,1),fv_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h2,str,'Color',c);
xlabel(h2,'pitch');
ylabel(h2,'entropy');
set(h2,'fontweight','bold');

h3 = subtightplot(3,2,3,[0.1 0.1],0.08, 0.15);
gscatter(fv_pcv_sal(:,1),fv_pcv_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(fv_pcv_sal(:,1),fv_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h3,str,'Color',c);
xlabel(h3,'pitch');
ylabel(h3,'pitch cv');
set(h3,'fontweight','bold');

h4 = subtightplot(3,2,4,[0.1 0.1],0.08, 0.15);
gscatter(vol_ent_sal(:,1),vol_ent_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(vol_ent_sal(:,1),vol_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h4,str,'Color',c);
xlabel(h4,'volume');
ylabel(h4,'entropy');
set(h4,'fontweight','bold');

h5 = subtightplot(3,2,5,[0.1 0.1],0.08, 0.15);
gscatter(vol_pcv_sal(:,1),vol_pcv_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(vol_pcv_sal(:,1),vol_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h5,str,'Color',c);
xlabel(h5,'volume');
ylabel(h5,'pitch cv');
set(h5,'fontweight','bold');

h6 = subtightplot(3,2,6,[0.1 0.1],0.08, 0.15);
gscatter(ent_pcv_sal(:,1),ent_pcv_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(ent_pcv_sal(:,1),ent_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
if p(2) <= 0.05
    c = 'r';
else
    c = 'k';
end
title(h6,str,'Color',c);
xlabel(h6,'entropy');
ylabel(h6,'pitch cv');
set(h6,'fontweight','bold');