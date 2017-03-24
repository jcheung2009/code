%correlating spectral changes of individual syllable cases with
%corresponding syllable duration/gap. each point = syllable-trial

ff = load_batchf('naspm_birds');

fv_syll = [];
fv_gap1 = [];
fv_gap0 = [];

vol_syll = [];
vol_gap1 = [];
vol_gap0 = [];

fv_syll_sal = [];
fv_gap1_sal = [];
fv_gap0_sal = [];

vol_syll_sal = [];
vol_gap1_sal = [];
vol_gap0_sal = [];

for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['fvmotifnaspm_',ff(i).name])
         x = eval(['fvmotifnaspm_',ff(i).name]);
     elseif exist(['fvmotifiem_',ff(i).name]) 
        x = eval(['fvmotifiem_',ff(i).name]);
     end
     
     if exist(['fvmotifsal_',ff(i).name])
         y = eval(['fvmotifsal_',ff(i).name]);
     end
     
     for ii = 1:length(x)
         xdata = cell2mat(struct2cell(x(ii).fv_syll));
         fv_syll = [fv_syll; xdata];
         
         xdata = cell2mat(struct2cell(x(ii).fv_gap1));
         fv_gap1 = [fv_gap1; xdata];
         
         xdata = cell2mat(struct2cell(x(ii).fv_gap0));
         fv_gap0 = [fv_gap0; xdata];
         
         xdata = cell2mat(struct2cell(x(ii).vol_syll));
         vol_syll = [vol_syll; xdata];
         
         xdata = cell2mat(struct2cell(x(ii).vol_gap0));
         vol_gap0 = [vol_gap0; xdata];
         
         xdata = cell2mat(struct2cell(x(ii).vol_gap1));
         vol_gap1 = [vol_gap1; xdata];
         
     end
     
     for ii = 1:length(y)
         ydata = cell2mat(struct2cell(y(ii).fv_syll));
         fv_syll_sal = [fv_syll_sal; ydata];
         
         ydata = cell2mat(struct2cell(y(ii).fv_gap1));
         fv_gap1_sal = [fv_gap1_sal; ydata];
         
         ydata = cell2mat(struct2cell(y(ii).fv_gap0));
         fv_gap0_sal = [fv_gap0_sal; ydata];
         
         ydata = cell2mat(struct2cell(y(ii).vol_syll));
         vol_syll_sal = [vol_syll_sal; ydata];
         
         ydata = cell2mat(struct2cell(y(ii).vol_gap0));
         vol_gap0_sal = [vol_gap0_sal; ydata];
         
         ydata = cell2mat(struct2cell(y(ii).vol_gap1));
         vol_gap1_sal = [vol_gap1_sal; ydata];
         
     end
end

figure;hold on;
h1 = subtightplot(2,6,1,[0.15 0.05],0.08,0.08);
plot(h1,fv_syll(:,1),fv_syll(:,2),'or','markersize',8);
[r p] = corrcoef(fv_syll(:,1),fv_syll(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'pitch');
ylabel(h1,'syllable duration');
set(h1,'fontweight','bold');

h2 = subtightplot(2,6,2,[0.15 0.05],0.08,0.08);
plot(h2,fv_gap0(:,1),fv_gap0(:,2),'or','markersize',8);
[r p] = corrcoef(fv_gap0(:,1),fv_gap0(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'pitch');
ylabel(h2,'pre gap');
set(h2,'fontweight','bold')

h3 = subtightplot(2,6,3,[0.15 0.05],0.08,0.08);
plot(h3,fv_gap1(:,1),fv_gap1(:,2),'or','markersize',8);
[r p] = corrcoef(fv_gap1(:,1),fv_gap1(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'pitch');
ylabel(h3,'gap');
set(h3,'fontweight','bold');

h4 = subtightplot(2,6,4,[0.15 0.05],0.08,0.08);
plot(h4,vol_syll(:,1),vol_syll(:,2),'or','markersize',8);
[r p] = corrcoef(vol_syll(:,1),vol_syll(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'volume');
ylabel(h4,'syllable duration');
set(h4,'fontweight','bold');

h5 = subtightplot(2,6,5,[0.15 0.05],0.08,0.08);
plot(h5,vol_gap0(:,1),vol_gap0(:,2),'or','markersize',8);
[r p] = corrcoef(vol_gap0(:,1),vol_gap0(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'volume');
ylabel(h5,'pre gap');
set(h5,'fontweight','bold');

h6 = subtightplot(2,6,6,[0.15 0.05],0.08,0.08);
plot(h6,vol_gap1(:,1),vol_gap1(:,2),'or','markersize',8);
[r p] = corrcoef(vol_gap1(:,1),vol_gap1(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'volume');
ylabel(h6,'gap');
set(h6,'fontweight','bold');

h7 = subtightplot(2,6,7,[0.15 0.05],0.08,0.08);
plot(h7,fv_syll_sal(:,1),fv_syll_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(fv_syll_sal(:,1),fv_syll_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'pitch');
ylabel(h7,'syllable duration');
set(h7,'fontweight','bold');

h8 = subtightplot(2,6,8,[0.15 0.05],0.08,0.08);
plot(h8,fv_gap0_sal(:,1),fv_gap0_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(fv_gap0_sal(:,1),fv_gap0_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'pitch');
ylabel(h8,'pre gap');
set(h8,'fontweight','bold');
         
h9 = subtightplot(2,6,9,[0.15 0.05],0.08,0.08);
plot(h9,fv_gap1_sal(:,1),fv_gap1_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(fv_gap1_sal(:,1),fv_gap1_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h9,str);
xlabel(h9,'pitch');
ylabel(h9,'gap');
set(h9,'fontweight','bold');

h10 = subtightplot(2,6,10,[0.15 0.05],0.08,0.08);
plot(h10,vol_syll_sal(:,1),vol_syll_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(vol_syll_sal(:,1),vol_syll_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h10,str);
xlabel(h10,'volume');
ylabel(h10,'syllable duration');
set(h10,'fontweight','bold');

h11 = subtightplot(2,6,11,[0.15 0.05],0.08,0.08);
plot(h11,vol_gap0_sal(:,1),vol_gap0_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(vol_gap0_sal(:,1),vol_gap0_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h11,str);
xlabel(h11,'volume');
ylabel(h11,'pre gap');
set(h11,'fontweight','bold');

h12 = subtightplot(2,6,12,[0.15 0.05],0.08,0.08);
plot(h12,vol_gap1_sal(:,1),vol_gap1_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(vol_gap1_sal(:,1),vol_gap1_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h12,str);
xlabel(h12,'volulme');
ylabel(h12,'gap');
set(h12,'fontweight','bold');
         
     
    