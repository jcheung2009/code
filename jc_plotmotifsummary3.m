function [mdur sdur gdur mcv] = jc_plotmotifsummary3(motif_sal, motif_cond, marker, linecolor,xpt)
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
motifdur = [motif_sal(:).motifdur];
sylldur = mean([motif_sal(:).durations],1);
gapdur = mean([motif_sal(:).gaps],1);
if ~iscell(motif_sal) 
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
end
if ~iscell(motif_cond)
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
end

fignum = input('figure number for checking outliers:');
figure(fignum);cla
h = plot(tb_sal,motifdur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(motifdur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal(removeind) = [];
    h = plot(tb_sal,motifdur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

h = plot(tb_sal,sylldur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(sylldur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal(removeind) = [];
    h = plot(tb_sal,sylldur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

h = plot(tb_sal,gapdur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(gapdur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal(removeind) = [];
    h = plot(tb_sal,gapdur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

tb_salacorr = tb_sal;
h = plot(tb_salacorr,motifacorr,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(motifacorr',nstd);
    tb_salacorr(removeind) = [];
    h = plot(tb_salacorr,motifacorr,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

motifdur2 = [motif_cond(:).motifdur];
sylldur2 = mean([motif_cond(:).durations],1);
gapdur2 = mean([motif_cond(:).gaps],1);
motifacorr2 = [motif_cond(:).firstpeakdistance];

h = plot(tb_cond,motifdur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(motifdur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_cond(removeind) = [];
    h = plot(tb_cond,motifdur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

h = plot(tb_cond,sylldur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(sylldur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_cond(removeind) = [];
    h = plot(tb_cond,sylldur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

h = plot(tb_cond,gapdur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(gapdur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_cond(removeind) = [];
    h = plot(tb_cond,gapdur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

tb_condacorr = tb_cond;
h = plot(tb_condacorr,motifacorr2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    cla;
    removeind = jc_findoutliers(motifacorr2',nstd);
    tb_salacorr(removeind) = [];
    h = plot(tb_condacorr,motifacorr2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
clf;

%fit logistic
motifdur2n = (motifdur2-min(motifdur2))/(max(motifdur2)-min(motifdur2));
tb_condn = tb_cond - mean(tb_cond);
tb_condn = tb_condn/3600;
sigfunc = @(A,x)(A(4)+((A(1)-A(4))./(A(2)+exp(-A(3).*x))));
A0 = ones(4,1);
A_fit = nlinfit(tb_condn,motifdur2n',sigfunc,A0);
plot(tb_condn,motifdur2n,'k.');hold on;
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
% motifdurn = motifdur2(ind)./mean(motifdur(indsal));
% sylldurn = sylldur2(ind)./mean(sylldur(indsal));
% gapdurn = gapdur2(ind)./mean(gapdur(indsal));    

%z-score
motifdurn = (motifdur2(ind)-mean(motifdur(indsal)))./std(motifdur(indsal));
sylldurn = (sylldur2(ind)-mean(sylldur(indsal)))./std(sylldur(indsal));
gapdurn = (gapdur2(ind)-mean(gapdur(indsal)))./std(gapdur(indsal)); 



fignum = input('figure for all normalized data:');
figure(fignum);hold on;


subtightplot(4,1,1,0.07,0.07,0.1);hold on;
[hi lo mn1] = mBootstrapCI(motifdurn);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5,4.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Duration change');
title('Change in motif duration relative to saline');
mdur = mn1;

subtightplot(4,1,2,0.07,0.07,0.1);hold on;
[hi lo mn1] = mBootstrapCI(sylldurn);
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Duration change');
title('Change in syllable duration relative to saline');
sdur = mn1;


subtightplot(4,1,3,0.07,0.07,0.1);hold on;
[hi lo mn1] = mBootstrapCI(gapdurn);
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Duration change');
title('Change in gap duration relative to saline');
gdur = mn1;


subtightplot(4,1,4,0.07,0.07,0.1);hold on;
mn1 = mBootstrapCI_CV(motifdur(indsal));
[mn2 hi lo] = mBootstrapCI_CV(motifdur2(ind));
mn3 = mn2/mn1;
hi = mn3+((hi-mn2)/mn1);
lo = mn3-((mn2-lo)/mn1);
plot(xpt,mn3,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Duration CV change');
title('Change in motif duration CV relative to saline');
mcv = mn3;



