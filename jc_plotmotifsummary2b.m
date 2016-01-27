function jc_plotmotifsummary2b(motif_sal, motif_cond,marker,linecolor,excludewashin,sdurind,gdurind,syllables)
%regression
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);

if excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    tb_cond(ind) = [];
    motif_cond(ind) = [];
end

sdur1 = {};
for i = 1:length(sdurind)
    sdur1{i} = arrayfun(@(x) [x.syllpitch(i) x.durations(sdurind(i))],motif_sal,'unif',0);
    sdur1{i} = cell2mat(sdur1{i}(:));
end

gdur1 = {};
for i = 1:length(gdurind)
    gdur1{i} = arrayfun(@(x) [x.syllpitch(i) x.gaps(gdurind(i))],motif_sal,'unif',0);
    gdur1{i} = cell2mat(gdur1{i}(:));
end


sdur2 = {};
for i = 1:length(sdurind)
    sdur2{i} = arrayfun(@(x) [x.syllpitch(i) x.durations(sdurind(i))],motif_cond,'unif',0);
    sdur2{i} = cell2mat(sdur2{i}(:));
end

gdur2 = {};
for i = 1:length(gdurind)
    gdur2{i} = arrayfun(@(x) [x.syllpitch(i) x.gaps(gdurind(i))],motif_cond,'unif',0);
    gdur2{i} = cell2mat(gdur2{i}(:));
end

fignum = input('figure number for checking outliers:');
figure(fignum);hold on;
for i = 1:length(sdur1);
    removenan = find(isnan(sdur1{i}(:,2)));
    sdur1{i}(removenan,:) = [];
    h = plot(sdur1{i}(:,1),sdur1{i}(:,2),'k.');hold on;
    removeoutliers = input('remove outliers (pitch vs dur):','s');
    while removeoutliers == 'p' | removeoutliers == 'd'
        nstd = input('nstd:');
        delete(h);
        if removeoutliers == 'p'
            removeind = jc_findoutliers(sdur1{i}(:,1),nstd);
            sdur1{i}(removeind,:) = [];
        else
            removeind = jc_findoutliers(sdur1{i}(:,2),nstd);
            sdur1{i}(removeind,:) = [];
        end
        h = plot(sdur1{i}(:,1),sdur1{i}(:,2),'k.');hold on;
        removeoutliers = input('remove outliers (pitch vs dur):','s');
    end
    delete(h);
end

for i = 1:length(gdur1);
    removenan = find(isnan(gdur1{i}(:,2)));
    gdur1{i}(removenan,:) = [];
    h = plot(gdur1{i}(:,1),gdur1{i}(:,2),'k.');hold on;
    removeoutliers = input('remove outliers (pitch vs dur):','s');
    while removeoutliers == 'p' | removeoutliers == 'd'
        nstd = input('nstd:');
        delete(h);
        if removeoutliers == 'p'
            removeind = jc_findoutliers(gdur1{i}(:,1),nstd);
            gdur1{i}(removeind,:) = [];
        else
            removeind = jc_findoutliers(gdur1{i}(:,2),nstd);
            gdur1{i}(removeind,:) = [];
        end
        h = plot(gdur1{i}(:,1),gdur1{i}(:,2),'k.');hold on;
        removeoutliers = input('remove outliers (pitch vs dur):','s');
    end
    delete(h);
end        

for i = 1:length(sdur2);
    removenan = find(isnan(sdur2{i}(:,2)));
    sdur2{i}(removenan,:) = [];
    h = plot(sdur2{i}(:,1),sdur2{i}(:,2),'k.');hold on;
    removeoutliers = input('remove outliers (pitch vs dur):','s');
    while removeoutliers == 'p' | removeoutliers == 'd'
        nstd = input('nstd:');
        delete(h);
        if removeoutliers == 'p'
            removeind = jc_findoutliers(sdur2{i}(:,1),nstd);
            sdur2{i}(removeind,:) = [];
        else
            removeind = jc_findoutliers(sdur2{i}(:,2),nstd);
            sdur2{i}(removeind,:) = [];
        end
        h = plot(sdur2{i}(:,1),sdur2{i}(:,2),'k.');hold on;
        removeoutliers = input('remove outliers (pitch vs dur):','s');
    end
    delete(h);
end

for i = 1:length(gdur2);
    removenan = find(isnan(gdur2{i}(:,2)));
    gdur2{i}(removenan,:) = [];
    h = plot(gdur2{i}(:,1),gdur2{i}(:,2),'k.');hold on;
    removeoutliers = input('remove outliers (pitch vs dur):','s');
    while removeoutliers == 'p' | removeoutliers == 'd'
        nstd = input('nstd:');
        delete(h);
        if removeoutliers == 'p'
            removeind = jc_findoutliers(gdur2{i}(:,1),nstd);
            gdur2{i}(removeind,:) = [];
        else
            removeind = jc_findoutliers(gdur2{i}(:,2),nstd);
            gdur2{i}(removeind,:) = [];
        end
        h = plot(gdur2{i}(:,1),gdur2{i}(:,2),'k.');hold on;
        removeoutliers = input('remove outliers (pitch vs dur):','s');
    end
    delete(h);
end     

fignum = input('figure number for plotting regression values:');
figure(fignum);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
xtick = 0.5:length(sdur1);
jitter = (-1+2*rand)/10;
xticklabel = syllables;
for i = 1:length(sdur1)
    xpt = xtick(i)+jitter;
    [hi lo mn1] = jc_BootstrapCI_r(sdur1{i});
    plot(xpt,mn1,'k.',[xpt xpt],[hi lo],'k','markersize',15,'linewidth',1);
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
ylabel('regression coefficient');
xlabel('Syllable');
title('Correlation Coefficient for syllable pitch vs syllable duration');


subtightplot(2,1,1,0.07,0.08,0.15);hold on;
xtick = 0.5:length(sdur2);
xticklabel = syllables;
for i = 1:length(sdur2)
    xpt = xtick(i)+jitter;
    [hi lo mn1] = jc_BootstrapCI_r(sdur2{i});
    plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'markersize',15,'linewidth',1);
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
ylabel('regression coefficient');
xlabel('Syllable');
title('Correlation Coefficient for syllable pitch vs syllable duration');


subtightplot(2,1,2,0.07,0.08,0.15);hold on;
xtick = 0.5:length(gdur1);
xticklabel = syllables;
for i = 1:length(gdur1)
    xpt = xtick(i)+jitter;
    [hi lo mn1] = jc_BootstrapCI_r(gdur1{i});
    plot(xpt,mn1,'k.',[xpt xpt],[hi lo],'k','markersize',15,'linewidth',1);
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
ylabel('regression coefficient');
xlabel('Syllable');
title('Correlation Coefficient for syllable pitch vs gap duration');


subtightplot(2,1,2,0.07,0.08,0.15);hold on;
xtick = 0.5:length(gdur2);
xticklabel = syllables;
for i = 1:length(gdur2)
    xpt = xtick(i)+jitter;
    [hi lo mn1] = jc_BootstrapCI_r(gdur2{i});
    plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'markersize',15,'linewidth',1);
end
set(gca,'xtick',xtick,'xticklabel',xticklabel);
ylabel('regression coefficient');
xlabel('Syllable');
title('Correlation Coefficient for syllable pitch vs gap duration');


        