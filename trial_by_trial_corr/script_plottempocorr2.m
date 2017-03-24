%pairwise motif tempo correlation, each point = bird 
%relates changes across drug epochs and changes across saline epochs 
%not trial-by-trial
ff = load_batchf('naspm_birds');

motif_syll = [];
motif_gap = [];
gap_syll = [];

motif_syll_sal = [];
motif_gap_sal = [];
gap_syll_sal = [];

for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
 
     if exist(['motifnaspm_',ff(i).name])
         x2 = eval(['motifnaspm_',ff(i).name]);
     elseif exist(['motifiem_',ff(i).name]) 
        x2 = eval(['motifiem_',ff(i).name]);
     end
     
     if exist(['motifsal_',ff(i).name])
         y2 = eval(['motifsal_',ff(i).name]);
     end
     
    
     motif_syll = [motif_syll; [nanmean(arrayfun(@(x) x.macorr.rel,x2)) nanmean(arrayfun(@(x) x.sdur.rel,x2))]];
     motif_gap = [motif_gap; [nanmean(arrayfun(@(x) x.macorr.rel,x2)) nanmean(arrayfun(@(x) x.gdur.rel,x2))]];
     gap_syll = [gap_syll; [nanmean(arrayfun(@(x) x.gdur.rel,x2)) nanmean(arrayfun(@(x) x.sdur.rel,x2))]];
     
     motif_syll_sal = [motif_syll_sal; [nanmean(arrayfun(@(x) x.macorr.rel,y2)) nanmean(arrayfun(@(x) x.sdur.rel,y2))]];
     motif_gap_sal = [motif_gap_sal; [nanmean(arrayfun(@(x) x.macorr.rel,y2)) nanmean(arrayfun(@(x) x.gdur.rel,y2))]];
     gap_syll_sal = [gap_syll_sal; [nanmean(arrayfun(@(x) x.gdur.rel,y2)) nanmean(arrayfun(@(x) x.sdur.rel,y2))]];
     
end

figure;hold on;
h1 = subtightplot(2,3,1,[0.1 0.05],0.08,0.08);
gscatter(motif_syll(:,1),motif_syll(:,2),{ff(:).name}','','o',8);
[r p] = corrcoef(motif_syll(:,1),motif_syll(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'motif acorr');
ylabel(h1,'syll dur');
set(h1,'fontweight','bold');

h2 = subtightplot(2,3,2,[0.1 0.05],0.08,0.08);
gscatter(motif_gap(:,1),motif_gap(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(motif_gap(:,1),motif_gap(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'motif acorr');
ylabel(h2,'gap dur');
set(h2,'fontweight','bold')

h3 = subtightplot(2,3,3,[0.15 0.05],0.08,0.08);
gscatter(gap_syll(:,1),gap_syll(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(gap_syll(:,1),gap_syll(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'gap dur');
ylabel(h3,'syll dur');
set(h3,'fontweight','bold');

h4 = subtightplot(2,3,4,[0.15 0.05],0.08,0.08);
gscatter(motif_syll_sal(:,1),motif_syll_sal(:,2),{ff(:).name}','','o',8);
[r p] = corrcoef(motif_syll_sal(:,1),motif_syll_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'motif acorr');
ylabel(h4,'syll dur');
set(h4,'fontweight','bold');

h5 = subtightplot(2,3,5,[0.15 0.05],0.08,0.08);
gscatter(motif_gap_sal(:,1),motif_gap_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(motif_gap_sal(:,1),motif_gap_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'motif acorr');
ylabel(h5,'gap dur');
set(h5,'fontweight','bold');

h6 = subtightplot(2,3,6,[0.15 0.05],0.08,0.08);
gscatter(gap_syll_sal(:,1),gap_syll_sal(:,2),{ff(:).name}','','o',8,'off');
[r p] = corrcoef(gap_syll_sal(:,1),gap_syll_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'gap dur');
ylabel(h6,'syll dur');
set(h6,'fontweight','bold');

