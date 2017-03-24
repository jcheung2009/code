%pairwise correlation across birds, each point = motif/gdur/sdur and
%syllable pairing (by syllable trial) 

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
     
     
     syllables = fieldnames(x);
     for ii = 1:length(syllables)
         xdata = [x(:).([syllables{ii}])];
         ydata = [y(:).([syllables{ii}])];
         x2data = [x2(:).macorr]';
         y2data =[y2(:).macorr]';
         
         motif_fv = [motif_fv; [x2data [xdata(:).fv]']];
         motif_fv_sal = [motif_fv_sal; [y2data [ydata(:).fv]']];
         motif_vol = [motif_vol; [x2data [xdata(:).vol]']];
         motif_vol_sal = [motif_vol_sal; [y2data [ydata(:).vol]']];
         motif_ent = [motif_ent; [x2data [xdata(:).ent]']];
         motif_ent_sal = [motif_ent_sal; [y2data [ydata(:).ent]']];
         motif_pcv = [motif_pcv; [x2data [xdata(:).pcv]'-1]];
         motif_pcv_sal = [motif_pcv_sal; [y2data [ydata(:).pcv]'-1]];
         
         x2data = [x2(:).sdur]';
         y2data =[y2(:).sdur]';
         sdur_fv = [sdur_fv; [x2data [xdata(:).fv]']];
         sdur_fv_sal = [sdur_fv_sal; [y2data [ydata(:).fv]']];
         sdur_vol = [sdur_vol; [x2data [xdata(:).vol]']];
         sdur_vol_sal = [sdur_vol_sal; [y2data [ydata(:).vol]']];
         sdur_ent = [sdur_ent; [x2data [xdata(:).ent]']];
         sdur_ent_sal = [sdur_ent_sal; [y2data [ydata(:).ent]']];
         sdur_pcv = [sdur_pcv; [x2data [xdata(:).pcv]'-1]];
         sdur_pcv_sal = [sdur_pcv_sal; [y2data [ydata(:).pcv]'-1]];
         
         x2data = [x2(:).gdur]';
         y2data =[y2(:).gdur]';
         gdur_fv = [gdur_fv; [x2data [xdata(:).fv]']];
         gdur_fv_sal = [gdur_fv_sal; [y2data [ydata(:).fv]']];
         gdur_vol = [gdur_vol; [x2data [xdata(:).vol]']];
         gdur_vol_sal = [gdur_vol_sal; [y2data [ydata(:).vol]']];
         gdur_ent = [gdur_ent; [x2data [xdata(:).ent]']];
         gdur_ent_sal = [gdur_ent_sal; [y2data [ydata(:).ent]']];
         gdur_pcv = [gdur_pcv; [x2data [xdata(:).pcv]'-1]];
         gdur_pcv_sal = [gdur_pcv_sal; [y2data [ydata(:).pcv]'-1]]; 
     end
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


