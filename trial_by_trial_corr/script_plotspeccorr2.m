%pairwise correlation across birds, each point = experiment 
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
     
     syllables = fieldnames(x);
     for ii = 1:length(syllables)
         xdata = [x(:).([syllables{ii}])];
         ydata = [y(:).([syllables{ii}])];
         
         fv_vol = [fv_vol; [[xdata(:).fv]' [xdata(:).vol]']];
         fv_vol_sal = [fv_vol_sal; [[ydata(:).fv]' [ydata(:).vol]']];
             
         fv_ent = [fv_ent; [[xdata(:).fv]' [xdata(:).ent]']];
         fv_ent_sal = [fv_ent_sal; [[ydata(:).fv]' [ydata(:).ent]']];
         
         fv_pcv = [fv_pcv; [[xdata(:).fv]' [xdata(:).pcv]'-1]];
         fv_pcv_sal = [fv_pcv_sal; [[ydata(:).fv]' [ydata(:).pcv]'-1]];
         
         vol_ent = [vol_ent; [[xdata(:).vol]' [xdata(:).ent]']];
         vol_ent_sal = [vol_ent_sal; [[ydata(:).vol]' [ydata(:).ent]']];
         
         vol_pcv = [vol_pcv; [[xdata(:).vol]' [xdata(:).pcv]'-1]];
         vol_pcv_sal = [vol_pcv_sal; [[ydata(:).vol]' [ydata(:).pcv]'-1]];
         
         ent_pcv = [ent_pcv; [[xdata(:).ent]' [xdata(:).pcv]'-1]];
         ent_pcv_sal = [ent_pcv_sal; [[ydata(:).ent]' [ydata(:).pcv]'-1]];
         
     end
end

figure;hold on;
h1 = subtightplot(3,2,1,0.08,0.08,0.1);
plot(h1,fv_vol(:,1),fv_vol(:,2),'or','markersize',8);
[r p] = corrcoef(fv_vol(:,1),fv_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'pitch');
ylabel(h1,'volume');
set(h1,'fontweight','bold');

h2 = subtightplot(3,2,2,0.08,0.08,0.1);
plot(h2,fv_ent(:,1),fv_ent(:,2),'or','markersize',8);
[r p] = corrcoef(fv_ent(:,1),fv_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'pitch');
ylabel(h2,'entropy');
set(h2,'fontweight','bold');

h3 = subtightplot(3,2,3,0.08,0.08,0.1);
plot(h3,fv_pcv(:,1),fv_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(fv_pcv(:,1),fv_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'pitch');
ylabel(h3,'pitch cv');
set(h3,'fontweight','bold');

h4 = subtightplot(3,2,4,0.08,0.08,0.1);
plot(h4,vol_ent(:,1),vol_ent(:,2),'or','markersize',8);
[r p] = corrcoef(vol_ent(:,1),vol_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'volume');
ylabel(h4,'entropy');
set(h4,'fontweight','bold');

h5 = subtightplot(3,2,5,0.08,0.08,0.1);
plot(h5,vol_pcv(:,1),vol_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(vol_pcv(:,1),vol_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'volume');
ylabel(h5,'pitch cv');
set(h5,'fontweight','bold');

h6 = subtightplot(3,2,6,0.08,0.08,0.1);
plot(h6,ent_pcv(:,1),ent_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(ent_pcv(:,1),ent_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'entropy');
ylabel(h6,'pitch cv');
set(h6,'fontweight','bold');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;hold on;
h1 = subtightplot(3,2,1,0.08,0.08,0.1);
plot(h1,fv_vol_sal(:,1),fv_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(fv_vol_sal(:,1),fv_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'pitch');
ylabel(h1,'volume');
set(h1,'fontweight','bold');

h2 = subtightplot(3,2,2,0.08,0.08,0.1);
plot(h2,fv_ent_sal(:,1),fv_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(fv_ent_sal(:,1),fv_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'pitch');
ylabel(h2,'entropy');
set(h2,'fontweight','bold');

h3 = subtightplot(3,2,3,0.08,0.08,0.1);
plot(h3,fv_pcv_sal(:,1),fv_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(fv_pcv_sal(:,1),fv_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'pitch');
ylabel(h3,'pitch cv');
set(h3,'fontweight','bold');

h4 = subtightplot(3,2,4,0.08,0.08,0.1);
plot(h4,vol_ent_sal(:,1),vol_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(vol_ent_sal(:,1),vol_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'volume');
ylabel(h4,'entropy');
set(h4,'fontweight','bold');

h5 = subtightplot(3,2,5,0.08,0.08,0.1);
plot(h5,vol_pcv_sal(:,1),vol_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(vol_pcv_sal(:,1),vol_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'volume');
ylabel(h5,'pitch cv');
set(h5,'fontweight','bold');

h6 = subtightplot(3,2,6,0.08,0.08,0.1);
plot(h6,ent_pcv_sal(:,1),ent_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(ent_pcv_sal(:,1),ent_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'entropy');
ylabel(h6,'pitch cv');
set(h6,'fontweight','bold');

