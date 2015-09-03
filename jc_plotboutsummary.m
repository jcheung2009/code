function jc_plotboutsummary(bout_sal, bout_cond, marker,linecolor,excludewashin)
%bout_sal from jc_findboutvals
%generate summary plots for changes in motif number and singing rate

if iscell(bout_sal)
    tb_sal=[];
    bout = [];
    for i = 1:length(bout_sal)
        tb_sal = [tb_sal; jc_tb([bout_sal{i}(:).datenm]',7,0)];
        bout = [bout bout_sal{i}];
    end
    bout_sal = bout;
end
if iscell(bout_cond)
    tb_cond=[];
    bout = [];
    for i = 1:length(bout_cond)
        tb_cond = [tb_cond; jc_tb([bout_cond{i}(:).datenm]',7,0)];
        bout =[bout bout_cond{i}];
    end
    bout_cond = bout;
end

if ~iscell(bout_sal) 
    tb_sal = jc_tb([bout_sal(:).datenm]',7,0);
end
if ~iscell(bout_cond)
    tb_cond = jc_tb([bout_cond(:).datenm]',7,0);
end
if excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    bout_cond(ind) = [];
    tb_cond(ind) = [];
end

nummotifs = [bout_sal(:).nummotifs]';
nummotifs2 = [bout_sal(:).nummotifs]';
nummotifs2 = nummotifs2/mean(nummotifs);
nummotifs = nummotifs/mean(nummotifs);

fignum = input('figure for plotting bout summary:');
figure(fignum);
subtightplot(1,2,1,0.07,0.05,0.08);hold on;
[hi lo mn1] = mBootstrapCI(nummotifs);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(nummotifs2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel('Change in number of motifs');
title('Normalized change in bout length');

subtightplot(1,2,2,0.07,0.05,0.08);hold on;
singingrate = length(tb_sal)/(tb_sal(end)-tb_sal(1));
singingrate2 = length(tb_cond)/(tb_cond(end)-tb_cond(1));
singingrate2 = singingrate2/singingrate;
singingrate = singingrate/singingrate;
plot(0.5,singingrate, marker, 1.5, singingrate2, marker,...
    [0.5 1.5],[singingrate singingrate2],linecolor,'linewidth',1,'markersize',12);hold on;
set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'saline','drug'});
ylabel('Change in singing rate');
title('Normalized change in singing rate');






