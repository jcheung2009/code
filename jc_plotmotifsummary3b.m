function [macorr] = jc_plotmotifsummary3b(motif_sal, motif_cond, marker, linecolor,xpt)
%for blocked design to compare matched time
%fits logistic and takes last 20% assumign motif duration is a function
%that decreases
%if function doesn't fit, manually choose time window to compare in drug
%matched with time window in saline


if iscell(motif_sal)
     tb_sal=[];
    motif = [];
    for i = 1:length(motif_sal)
        tb_sal = [tb_sal; jc_tb([motif_sal{i}(:).datenm]',7,0)];
        motif = [motif motif_sal{i}];
    end
    motif_sal = motif;
end
if iscell(motif_cond)
    tb_cond=[];
    motif = [];
    for i = 1:length(motif_cond)
        tb_cond = [tb_cond; jc_tb([motif_cond{i}(:).datenm]',7,0)];
        motif =[motif motif_cond{i}];
    end
    motif_cond = motif;
end

motifacorr = [motif_sal(:).firstpeakdistance];
if ~iscell(motif_sal) 
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
end
if ~iscell(motif_cond)
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
end

fignum = input('figure number for checking outliers:');
figure(fignum);cla

h = plot(tb_sal,motifacorr,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(motifacorr',nstd);
    motifacorr(removeind) = [];
    tb_sal(removeind) = [];
    h = plot(tb_sal,motifacorr,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

motifacorr2 = [motif_cond(:).firstpeakdistance];
h = plot(tb_cond,motifacorr2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(motifacorr2',nstd);
    motifacorr2(removeind) = [];
    tb_cond(removeind) = [];
    h = plot(tb_cond,motifacorr2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
clf;

%fit logistic
motifacorr2n = (motifacorr2-min(motifacorr2))/(max(motifacorr2)-min(motifacorr2));
tb_condn = tb_cond - mean(tb_cond);
tb_condn = tb_condn/3600;
sigfunc = @(A,x)(A(4)+((A(1)-A(4))./(A(2)+exp(-A(3).*x))));
A0 = ones(4,1);
A_fit = nlinfit(tb_condn,motifacorr2n',sigfunc,A0);
plot(tb_condn,motifacorr2n,'k.');hold on;
plot(tb_condn,sigfunc(A_fit,tb_condn),'g');

goodfit = input('is the fit to pitch good?','s');
if goodfit == 'n'
    debug = input('dbug?:','s');
    if debug == 'y'
        error('bad fit, change sigfunc');
    else 
        timewindow = input('how many hours from the end:');
        ind = find(tb_cond >= tb_cond(end)-timewindow*3600 & tb_cond <= tb_cond(end));
        tb_cond_sub = tb_cond(ind);
        indsal = find(tb_sal >= tb_cond_sub(1) & tb_sal <= tb_cond_sub(end));
    end
else
    cla;
    predy = sigfunc(A_fit,tb_condn);
    predy = (predy-min(predy))/(max(predy)-min(predy)); 
    ind = find(predy <= 0.2);
    tb_cond_sub = tb_cond(ind);%subset of condition points that you will match time with saline
    indsal = find(tb_sal>=tb_cond_sub(1) & tb_sal <= tb_cond_sub(end));
end


if length(ind) < 20 | length(indsal) < 20
    return
end
%percent change
%motifacorrn = motifacorr2(ind)./mean(motifacorr(indsal));
 
%z-score
motifacorrn = (motifacorr2(ind)-nanmean(motifacorr(indsal)))./nanstd(motifacorr(indsal));



fignum = input('figure for all normalized data:');
figure(fignum);hold on;
[hi lo mn1] = mBootstrapCI(motifacorrn);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 1],'xtick',[0.5],'xticklabel',...
    {'control'},'fontweight','bold');
ylabel('Duration z-score change');
title('Change in tempo relative to saline');
macorr = mn1;



