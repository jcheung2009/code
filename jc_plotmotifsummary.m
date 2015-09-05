function jc_plotmotifsummary(motif_sal, motif_cond, marker, linecolor, excludewashin)

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

motifdur = [motif_sal(:).motifdur];
sylldur = mean([motif_sal(:).durations],1);
gapdur = mean([motif_sal(:).gaps],1);
if ~iscell(motif_sal) 
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
end
if ~iscell(motif_cond)
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
end
if excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    tb_cond(ind) = [];
end

fignum = input('figure number for checking outliers:');
figure(fignum);
h = plot(tb_sal,motifdur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(motifdur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal(removeind) = [];
    plot(tb_sal,motifdur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal,sylldur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(sylldur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal(removeind) = [];
    plot(tb_sal,sylldur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal,gapdur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(gapdur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal(removeind) = [];
    plot(tb_sal,gapdur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

motifdur2 = [motif_cond(:).motifdur];
sylldur2 = mean([motif_cond(:).durations],1);
gapdur2 = mean([motif_cond(:).gaps],1);
if excludewashin == 1
    motifdur2(ind) = [];
    sylldur2(ind) = [];
    gapdur2(ind) = [];
end

h = plot(tb_cond,motifdur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(motifdur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_cond(removeind) = [];
    plot(tb_cond,motifdur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_cond,sylldur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(sylldur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_cond(removeind) = [];
    plot(tb_cond,sylldur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_cond,gapdur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(gapdur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_cond(removeind) = [];
    plot(tb_cond,gapdur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);
clf;

rawplot = input('plot raw summary?:(y/n)','s');
if rawplot == 'y'
    fignum = input('figure number for motif summary:');
    figure(fignum);hold on;
    subtightplot(2,4,1,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(motifdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(motifdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Motif duration (s)');
    title('Raw motif duration changes');
    

    subtightplot(2,4,2,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(sylldur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(sylldur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Mean syllable duration (s)');
    title('Raw syllable duration changes');

    subtightplot(2,4,3,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(gapdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(gapdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Mean gap duration (s)');
    title('Raw gap duration changes');
    
    subtightplot(2,4,4,0.07,0.04,0.1);hold on;
    [mn1 hi lo] = mBootstrapCI_CV(motifdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [mn2 hi lo] = mBootstrapCI_CV(motifdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('CV');
    title('Raw motif duration CV changes');

    motifdur2 = motifdur2/mean(motifdur);
    motifdur = motifdur/mean(motifdur);
    sylldur2 = sylldur2/mean(sylldur);
    sylldur = sylldur/mean(sylldur);
    gapdur2 = gapdur2/mean(gapdur);
    gapdur = gapdur/mean(gapdur);

    subtightplot(2,4,5,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(motifdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(motifdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Change in motif duration relative to saline');
    title('Normalized motif duration changes');

    subtightplot(2,4,6,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(sylldur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(sylldur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in mean syllable duration', 'relative to saline'});
    title('Normalized syllable duration changes');

    subtightplot(2,4,7,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(gapdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(gapdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in mean gap duration', 'relative to saline'});
    title('Normalized gap duration changes');
    
    subtightplot(2,4,8,0.07,0.04,0.1);hold on;
    [mn1 hi lo] = mBootstrapCI_CV(motifdur);
    mn = mn1/mn1;
    hi = mn+((hi-mn1)/mn1);
    lo = mn-((mn1-lo)/mn1);
    plot(0.5,mn,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [mn2 hi lo] = mBootstrapCI_CV(motifdur2);
    mn3 = mn2/mn1;
    hi = mn3+((hi-mn2)/mn1);
    lo = mn3-((mn2-lo)/mn1);
    plot(1.5,mn3,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn mn3],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in motif duration CV', 'relative to saline'});
    title('Normalized motif duration CV changes');
    
else
    fignum = input('figure for all normalized data:');
    figure(fignum);hold on;
    
    motifdur2 = motifdur2/mean(motifdur);
    motifdur = motifdur/mean(motifdur);
    sylldur2 = sylldur2/mean(sylldur);
    sylldur = sylldur/mean(sylldur);
    gapdur2 = gapdur2/mean(gapdur);
    gapdur = gapdur/mean(gapdur);
    
    subtightplot(1,4,1,0.07,0.08,0.05);hold on;
    [hi lo mn1] = mBootstrapCI(motifdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(motifdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in motif duration', 'relative to saline'});
    title('Motif duration changes');
    
    subtightplot(1,4,2,0.07,0.08,0.05);hold on;
    [hi lo mn1] = mBootstrapCI(sylldur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(sylldur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in mean syllable duration','relative to saline'});
    title('Syllable duration changes');
    
    subtightplot(1,4,3,0.07,0.08,0.05);hold on;
    [hi lo mn1] = mBootstrapCI(gapdur);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(gapdur2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in mean gap duration', 'relative to saline'});
    title('Gap duration changes');
    
    subtightplot(1,4,4,0.07,0.08,0.05);hold on;
    [mn1 hi lo] = mBootstrapCI_CV(motifdur);
    mn = mn1/mn1;
    hi = mn+((hi-mn1)/mn1);
    lo = mn-((mn1-lo)/mn1);
    plot(0.5,mn,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [mn2 hi lo] = mBootstrapCI_CV(motifdur2);
    mn3 = mn2/mn1;
    hi = mn3+((hi-mn2)/mn1);
    lo = mn3-((mn2-lo)/mn1);
    plot(1.5,mn3,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn mn3],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel({'Change in motif duration CV', 'relative to saline'});
    title('Motif duration CV changes');
end