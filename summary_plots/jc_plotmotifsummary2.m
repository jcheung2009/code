function jc_plotmotifsummary2(motif_sal, motif_cond,marker,linecolor,excludewashin)
%plots graph of regression values between motif duration and
%pitch/entropy/volume, includes 95% confidence interval 

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

if ~iscell(motif_sal) 
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
end
if ~iscell(motif_cond)
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
end
if excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    tb_cond(ind) = [];
    motif_cond(ind) = [];
end

motifdur_and_pitch = arrayfun(@(x) [x.motifdur x.syllpitch],motif_sal,'UniformOutput',false);
motifdur_and_volume = arrayfun(@(x) [x.motifdur log(x.syllvol)],motif_sal,'UniformOutput',false);
motifdur_and_entropy = arrayfun(@(x) [x.motifdur x.syllent],motif_sal,'UniformOutput',false);
motifdur_and_volume = cell2mat(motifdur_and_volume');
motifdur_and_pitch = cell2mat(motifdur_and_pitch');
motifdur_and_entropy = cell2mat(motifdur_and_entropy');
nsyllables = size(motifdur_and_pitch,2)-1;

motifdur_and_pitch2 = arrayfun(@(x) [x.motifdur x.syllpitch],motif_cond,'UniformOutput',false);
motifdur_and_volume2 = arrayfun(@(x) [x.motifdur log(x.syllvol)],motif_cond,'UniformOutput',false);
motifdur_and_entropy2 = arrayfun(@(x) [x.motifdur x.syllent],motif_cond,'UniformOutput',false);
motifdur_and_volume2 = cell2mat(motifdur_and_volume2');
motifdur_and_pitch2 = cell2mat(motifdur_and_pitch2');
motifdur_and_entropy2 = cell2mat(motifdur_and_entropy2');

%zcore the values
motifdur_and_pitch(:,1) = (motifdur_and_pitch(:,1)-mean(motifdur_and_pitch(:,1)))/std(motifdur_and_pitch(:,1));
motifdur_and_volume(:,1) = (motifdur_and_volume(:,1)-mean(motifdur_and_volume(:,1)))/std(motifdur_and_volume(:,1));
motifdur_and_entropy(:,1) = (motifdur_and_entropy(:,1)-mean(motifdur_and_entropy(:,1)))/std(motifdur_and_entropy(:,1));
motifdur_and_pitch2(:,1) = (motifdur_and_pitch2(:,1)-mean(motifdur_and_pitch2(:,1)))/std(motifdur_and_pitch2(:,1));
motifdur_and_volume2(:,1) = (motifdur_and_volume2(:,1)-mean(motifdur_and_volume2(:,1)))/std(motifdur_and_volume2(:,1));
motifdur_and_entropy2(:,1) = (motifdur_and_entropy2(:,1)-mean(motifdur_and_entropy2(:,1)))/std(motifdur_and_entropy2(:,1));

for i = 1:nsyllables
    motifdur_and_pitch(:,i+1) = (motifdur_and_pitch(:,i+1)-nanmean(motifdur_and_pitch(:,i+1)))/nanstd(motifdur_and_pitch(:,i+1));
    motifdur_and_volume(:,i+1) = (motifdur_and_volume(:,i+1)-nanmean(motifdur_and_volume(:,i+1)))/nanstd(motifdur_and_volume(:,i+1));
    motifdur_and_entropy(:,i+1) = (motifdur_and_entropy(:,i+1)-nanmean(motifdur_and_entropy(:,i+1)))/nanstd(motifdur_and_entropy(:,i+1));
    motifdur_and_pitch2(:,i+1) = (motifdur_and_pitch2(:,i+1)-nanmean(motifdur_and_pitch2(:,i+1)))/nanstd(motifdur_and_pitch2(:,i+1));
    motifdur_and_volume2(:,i+1) = (motifdur_and_volume2(:,i+1)-nanmean(motifdur_and_volume2(:,i+1)))/nanstd(motifdur_and_volume2(:,i+1));
    motifdur_and_entropy2(:,i+1) = (motifdur_and_entropy2(:,i+1)-nanmean(motifdur_and_entropy2(:,i+1)))/nanstd(motifdur_and_entropy2(:,i+1));
end

motifdur_and_pitch = [repmat(motifdur_and_pitch(:,1),nsyllables,1) reshape(motifdur_and_pitch(:,2:end),[],1)];
motifdur_and_volume = [repmat(motifdur_and_volume(:,1),nsyllables,1) reshape(motifdur_and_volume(:,2:end),[],1)];
motifdur_and_entropy = [repmat(motifdur_and_entropy(:,1),nsyllables,1) reshape(motifdur_and_entropy(:,2:end),[],1)];
motifdur_and_pitch2 = [repmat(motifdur_and_pitch2(:,1),nsyllables,1) reshape(motifdur_and_pitch2(:,2:end),[],1)];
motifdur_and_volume2 = [repmat(motifdur_and_volume2(:,1),nsyllables,1) reshape(motifdur_and_volume2(:,2:end),[],1)];
motifdur_and_entropy2 = [repmat(motifdur_and_entropy2(:,1),nsyllables,1) reshape(motifdur_and_entropy2(:,2:end),[],1)];

removenan = find(isnan(motifdur_and_pitch(:,2)));
motifdur_and_pitch(removenan,:) = [];
removenan = find(isnan(motifdur_and_volume(:,2)));
motifdur_and_volume(removenan,:) = [];
removenan = find(isnan(motifdur_and_entropy(:,2)));
motifdur_and_entropy(removenan,:) = [];
removenan = find(isnan(motifdur_and_pitch2(:,2)));
motifdur_and_pitch2(removenan,:) = [];
removenan = find(isnan(motifdur_and_volume2(:,2)));
motifdur_and_volume2(removenan,:) = [];
removenan = find(isnan(motifdur_and_entropy2(:,2)));
motifdur_and_entropy2(removenan,:) = [];

%check for outliers
fignum = input('figure number for checking outliers:');
figure(fignum);

h = plot(motifdur_and_pitch(:,1),motifdur_and_pitch(:,2),'k.');
removeoutliers = input('remove outliers (motifdur/pitch or n):','s');
while removeoutliers == 'm' | removeoutliers == 'p'
    nstd = input('nstd:');
    delete(h);
    if removeoutliers == 'm'
        removeind = jc_findoutliers(motifdur_and_pitch(:,1),nstd);
        motifdur_and_pitch(removeind,:) = [];
    else
        removeind = jc_findoutliers(motifdur_and_pitch(:,2),nstd);
        motifdur_and_pitch(removeind,:) = [];
    end
    plot(motifdur_and_pitch(:,1),motifdur_and_pitch(:,2),'k.');
    removeoutliers = input('remove outliers (motifdur/pitch or n):','s');
end
delete(h);
    
h = plot(motifdur_and_volume(:,1),motifdur_and_volume(:,2),'k.');
removeoutliers = input('remove outliers (motifdur/volume or n):','s');
while removeoutliers == 'm' | removeoutliers == 'v'
    nstd = input('nstd:');
    delete(h);
    if removeoutliers == 'm'
        removeind = jc_findoutliers(motifdur_and_volume(:,1),nstd);
        motifdur_and_volume(removeind,:) = [];
    else
        removeind = jc_findoutliers(motifdur_and_volume(:,2),nstd);
        motifdur_and_volume(removeind,:) = [];
    end
    plot(motifdur_and_volume(:,1),motifdur_and_volume(:,2),'k.');
    removeoutliers = input('remove outliers (motifdur/volume or n):','s');
end
delete(h);
    
h = plot(motifdur_and_entropy(:,1),motifdur_and_entropy(:,2),'k.');
removeoutliers = input('remove outliers (motifdur/entropy or n):','s');
while removeoutliers == 'm' | removeoutliers == 'e'
    nstd = input('nstd:');
    delete(h);
    if removeoutliers == 'm'
        removeind = jc_findoutliers(motifdur_and_entropy(:,1),nstd);
        motifdur_and_entropy(removeind,:) = [];
    else
        removeind = jc_findoutliers(motifdur_and_entropy(:,2),nstd);
        motifdur_and_entropy(removeind,:) = [];
    end
    plot(motifdur_and_entropy(:,1),motifdur_and_entropy(:,2),'k.');
    removeoutliers = input('remove outliers (motifdur/entropy or n):','s');
end
delete(h);
    
h = plot(motifdur_and_pitch2(:,1),motifdur_and_pitch2(:,2),'k.');
removeoutliers = input('remove outliers (motifdur/pitch or n):','s');
while removeoutliers == 'm' | removeoutliers == 'p'
    nstd = input('nstd:');
    delete(h);
    if removeoutliers == 'm'
        removeind = jc_findoutliers(motifdur_and_pitch2(:,1),nstd);
        motifdur_and_pitch2(removeind,:) = [];
    else
        removeind = jc_findoutliers(motifdur_and_pitch2(:,2),nstd);
        motifdur_and_pitch2(removeind,:) = [];
    end
    plot(motifdur_and_pitch2(:,1),motifdur_and_pitch2(:,2),'k.');
    removeoutliers = input('remove outliers (motifdur/pitch or n):','s');
end
delete(h);

h = plot(motifdur_and_volume2(:,1),motifdur_and_volume2(:,2),'k.');
removeoutliers = input('remove outliers (motifdur/volume or n):','s');
while removeoutliers == 'm' | removeoutliers == 'v'
    nstd = input('nstd:');
    delete(h);
    if removeoutliers == 'm'
        removeind = jc_findoutliers(motifdur_and_volume2(:,1),nstd);
        motifdur_and_volume2(removeind,:) = [];
    else
        removeind = jc_findoutliers(motifdur_and_volume2(:,2),nstd);
        motifdur_and_volume2(removeind,:) = [];
    end
    plot(motifdur_and_volume2(:,1),motifdur_and_volume2(:,2),'k.');
    removeoutliers = input('remove outliers (motifdur/volume or n):','s');
end
delete(h);

h = plot(motifdur_and_entropy2(:,1),motifdur_and_entropy2(:,2),'k.');
removeoutliers = input('remove outliers (motifdur/entropy or n):','s');
while removeoutliers == 'm' | removeoutliers == 'e'
    nstd = input('nstd:');
    delete(h);
    if removeoutliers == 'm'
        removeind = jc_findoutliers(motifdur_and_entropy2(:,1),nstd);
        motifdur_and_entropy2(removeind,:) = [];
    else
        removeind = jc_findoutliers(motifdur_and_entropy2(:,2),nstd);
        motifdur_and_entropy2(removeind,:) = [];
    end
    plot(motifdur_and_entropy2(:,1),motifdur_and_entropy2(:,2),'k.');
    removeoutliers = input('remove outliers (motifdur/entropy or n):','s');
end
delete(h);


fignum = input('figure number for plotting bar plot for regression values');
figure(fignum);

    subtightplot(1,3,1,0.07,0.07,0.08);hold on;
    [hi lo mn1] = jc_BootstrapCI_r(motifdur_and_pitch);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
%     createPatches(xlocs(1),mn1,0.5,'k',0.5);
%     plot([xlocs(1) xlocs(1)],[hi lo],'k','linewidth',1);
    [hi lo mn2] = jc_BootstrapCI_r(motifdur_and_pitch2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
%     createPatches(xlocs(2),mn2,0.5,linecolor,0.5);
%     plot([xlocs(2) xlocs(2)],[hi lo],'k','linewidth',1);
%     h = findobj(gca,'Type','patch');set(h,'edgecolor','none');
    ylabel('Correlation Coefficient');
    title('Motif duration vs pitch correlation');
    set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'saline','drug'});

    subtightplot(1,3,2,0.07,0.07,0.08);hold on;
    [hi lo mn1] = jc_BootstrapCI_r(motifdur_and_volume);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = jc_BootstrapCI_r(motifdur_and_volume2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    title('Motif duration vs volume correlation');
    set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'saline','drug'});
    
    subtightplot(1,3,3,0.07,0.07,0.08);hold on;
    [hi lo mn1] = jc_BootstrapCI_r(motifdur_and_entropy);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = jc_BootstrapCI_r(motifdur_and_entropy2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    title('Motif duration vs entropy correlation');
    set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'saline','drug'});




