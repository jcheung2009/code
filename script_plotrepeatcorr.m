%pairwise correlation across birds, each point = repeat trial
%relates changes across drug epochs and changes across saline epochs 
%not trial-by-trial

ff = load_batchf('naspm_birds');

replen_acorr = [];
replen_syll = [];
replen_gap = [];
repacorr_syll = [];
repacorr_gap = [];
repsyll_gap = [];

replen_acorr_sal = [];
replen_syll_sal = [];
replen_gap_sal = [];
repacorr_syll_sal = [];
repacorr_gap_sal = [];
repsyll_gap_sal = [];
lname = {};
lname_sal = {};
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
        xdata = [x(:).([repeats{ii}])];
        ydata = [y(:).([repeats{ii}])];
        lname = [lname; repmat({ff(i).name},length(xdata),1)];
        lname_sal = [lname_sal; repmat({ff(i).name},length(ydata),1)];
        replen_acorr = [replen_acorr; 100*[arrayfun(@(x) x.rep.rel,xdata)'-1 arrayfun(@(x) x.acorr.rel,xdata)'-1]];
        replen_syll = [replen_syll; 100*[arrayfun(@(x) x.rep.rel,xdata)'-1 arrayfun(@(x) x.sdur.rel,xdata)'-1]];
        replen_gap = [replen_gap; 100*[arrayfun(@(x) x.rep.rel,xdata)'-1 arrayfun(@(x) x.gdur.rel,xdata)'-1]];
        repacorr_syll = [repacorr_syll; 100*[arrayfun(@(x) x.acorr.rel,xdata)'-1 arrayfun(@(x) x.sdur.rel,xdata)'-1]];
        repacorr_gap = [repacorr_gap; 100*[arrayfun(@(x) x.acorr.rel,xdata)'-1 arrayfun(@(x) x.gdur.rel,xdata)'-1]];
        repsyll_gap = [repsyll_gap; 100*[arrayfun(@(x) x.sdur.rel,xdata)'-1 arrayfun(@(x) x.gdur.rel,xdata)'-1]];
     
        replen_acorr_sal = [replen_acorr_sal; 100*[arrayfun(@(x) x.rep.rel,ydata)'-1 arrayfun(@(x) x.acorr.rel,ydata)'-1]];
        replen_syll_sal = [replen_syll_sal; 100*[arrayfun(@(x) x.rep.rel,ydata)'-1 arrayfun(@(x) x.sdur.rel,ydata)'-1]];
        replen_gap_sal = [replen_gap_sal; 100*[arrayfun(@(x) x.rep.rel,ydata)'-1 arrayfun(@(x) x.gdur.rel,ydata)'-1]];
        repacorr_syll_sal = [repacorr_syll_sal; 100*[arrayfun(@(x) x.acorr.rel,ydata)'-1 arrayfun(@(x) x.sdur.rel,ydata)'-1]];
        repacorr_gap_sal = [repacorr_gap_sal; 100*[arrayfun(@(x) x.acorr.rel,ydata)'-1 arrayfun(@(x) x.gdur.rel,ydata)'-1]];
        repsyll_gap_sal = [repsyll_gap_sal; 100*[arrayfun(@(x) x.sdur.rel,ydata)'-1 arrayfun(@(x) x.gdur.rel,ydata)'-1]];
    end
    
end

figure;hold on;
h1 = subtightplot(2,6,1,[0.2 0.05],0.08,0.08);
gscatter(replen_acorr(:,1),replen_acorr(:,2),lname,'','o',8);
[r p] = corrcoef(replen_acorr(:,1),replen_acorr(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'repeat length');
ylabel(h1,'acorr');
set(h1,'fontweight','bold');

h2 = subtightplot(2,6,2,[0.2 0.05],0.08,0.08);
gscatter(replen_syll(:,1),replen_syll(:,2),lname,'','o',8,'off');
[r p] = corrcoef(replen_syll(:,1),replen_syll(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'repeat length');
ylabel(h2,'syll dur');
set(h2,'fontweight','bold')

h3 = subtightplot(2,6,3,[0.2 0.05],0.08,0.08);
gscatter(replen_gap(:,1),replen_gap(:,2),lname,'','o',8,'off');
[r p] = corrcoef(replen_gap(:,1),replen_gap(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'repeat length');
ylabel(h3,'gap dur');
set(h3,'fontweight','bold');

h4 = subtightplot(2,6,4,[0.2 0.05],0.08,0.08);
gscatter(repacorr_syll(:,1),repacorr_syll(:,2),lname,'','o',8,'off');
[r p] = corrcoef(repacorr_syll(:,1),repacorr_syll(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'repeat acorr');
ylabel(h4,'syll dur');
set(h4,'fontweight','bold');

h5 = subtightplot(2,6,5,[0.2 0.05],0.08,0.08);
gscatter(repacorr_gap(:,1),repacorr_gap(:,2),lname,'','o',8,'off');
[r p] = corrcoef(repacorr_gap(:,1),repacorr_gap(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'repeat acorr');
ylabel(h5,'gap dur');
set(h5,'fontweight','bold');

h6 = subtightplot(2,6,6,[0.2 0.05],0.08,0.08);
gscatter(repsyll_gap(:,1),repsyll_gap(:,2),lname,'','o',8,'off');
[r p] = corrcoef(repsyll_gap(:,1),repsyll_gap(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'syll dur');
ylabel(h6,'gap dur');
set(h6,'fontweight','bold');

h7 = subtightplot(2,6,7,[0.2 0.05],0.08,0.08);
gscatter(replen_acorr_sal(:,1),replen_acorr_sal(:,2),lname_sal,'','o',8);
[r p] = corrcoef(replen_acorr_sal(:,1),replen_acorr_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'repeat length');
ylabel(h7,'acorr');
set(h7,'fontweight','bold');

h8 = subtightplot(2,6,8,[0.2 0.05],0.08,0.08);
gscatter(replen_syll_sal(:,1),replen_syll_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(replen_syll_sal(:,1),replen_syll_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'repeat length');
ylabel(h8,'syll dur');
set(h8,'fontweight','bold')

h9 = subtightplot(2,6,9,[0.2 0.05],0.08,0.08);
gscatter(replen_gap_sal(:,1),replen_gap_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(replen_gap_sal(:,1),replen_gap_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h9,str);
xlabel(h9,'repeat length');
ylabel(h9,'gap dur');
set(h9,'fontweight','bold');

h10 = subtightplot(2,6,10,[0.2 0.05],0.08,0.08);
gscatter(repacorr_syll_sal(:,1),repacorr_syll_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(repacorr_syll_sal(:,1),repacorr_syll_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h10,str);
xlabel(h10,'repeat acorr');
ylabel(h10,'syll dur');
set(h10,'fontweight','bold');

h11 = subtightplot(2,6,11,[0.2 0.05],0.08,0.08);
gscatter(repacorr_gap_sal(:,1),repacorr_gap_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(repacorr_gap_sal(:,1),repacorr_gap_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h11,str);
xlabel(h11,'repeat acorr');
ylabel(h11,'gap dur');
set(h11,'fontweight','bold');

h12 = subtightplot(2,6,12,[0.2 0.05],0.08,0.08);
gscatter(repsyll_gap_sal(:,1),repsyll_gap_sal(:,2),lname_sal,'','o',8,'off');
[r p] = corrcoef(repsyll_gap_sal(:,1),repsyll_gap_sal(:,2));
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h12,str);
xlabel(h12,'syll dur');
ylabel(h12,'gap dur');
set(h12,'fontweight','bold');

