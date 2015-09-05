function jc_plotrepeatsummary(fv_rep_sal,fv_rep_cond,marker,linecolor,excludewashin)
%plots summary data for changes in repeat length, gap duration, and
%syllable duration for target repeat
%gap durations and syllable durations are matched by repeat position before
%normalizing 


if iscell(fv_rep_sal)
     tb_sal=[];
    fv_rep = [];
    for i = 1:length(fv_rep_sal)
        tb_sal = [tb_sal; jc_tb([fv_rep_sal{i}(:).datenm]',7,0)];
        fv_rep = [fv_rep fv_rep_sal{i}];
    end
    fv_rep_sal = fv_rep;
end
if iscell(fv_rep_cond)
    tb_cond=[];
    fv_rep = [];
    for i = 1:length(fv_rep_cond)
        tb_cond = [tb_cond; jc_tb([fv_rep_cond{i}(:).datenm]',7,0)];
        fv_rep =[fv_rep fv_rep_cond{i}];
    end
    fv_rep_cond = fv_rep;
end

if ~iscell(fv_rep_sal) 
    tb_sal = jc_tb([fv_rep_sal(:).datenm]',7,0);
end
if ~iscell(fv_rep_cond)
    tb_cond = jc_tb([fv_rep_cond(:).datenm]',7,0);
end
if excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    fv_rep_cond(ind) = [];
    tb_cond(ind) = [];
end

runlength = [fv_rep_sal(:).runlength];
runlength2 = [fv_rep_cond(:).runlength];
gapdur = [];
sylldur = [];
for i = 1:length(fv_rep_sal)
    gapdur = [gapdur; [1:length(fv_rep_sal(i).syllgaps)]' fv_rep_sal(i).syllgaps];%repeat position and duration of gap
    sylldur = [sylldur; [1:length(fv_rep_sal(i).sylldurations)]' fv_rep_sal(i).sylldurations];
end
gapdur2 = [];
sylldur2 = [];
for i = 1:length(fv_rep_cond)
    gapdur2 = [gapdur2; [1:length(fv_rep_cond(i).syllgaps)]' fv_rep_cond(i).syllgaps];
    sylldur2 = [sylldur2; [1:length(fv_rep_cond(i).sylldurations)]' fv_rep_cond(i).sylldurations];
end

fignum = input('figure number for checking outliers:');
figure(fignum);
h = plot(1,gapdur(:,2),'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(gapdur(:,2),nstd);
    gapdur(removeind,:) = [];
    plot(1,gapdur(:,2),'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(1,sylldur(:,2),'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(sylldur(:,2),nstd);
    sylldur(removeind,:) = [];
    plot(1,sylldur(:,2),'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(1,gapdur2(:,2),'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(gapdur2(:,2),nstd);
    gapdur2(removeind,:) = [];
    plot(1,gapdur2(:,2),'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(1,sylldur2(:,2),'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(sylldur2(:,2),nstd);
    sylldur2(removeind,:) = [];
    plot(1,sylldur2(:,2),'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

%normalize gap and syllable durations by repeat position 
maxlength = max([runlength';runlength2']);
for i = 1:maxlength
    ind = find(gapdur(:,1)==i);
    ind2 = find(gapdur2(:,1)==i);
%     if length(ind) < 20 | length(ind2) < 20
%          gapdur(ind,:) = [];
%          gapdur2(ind2,:) = [];
%          continue
%     end
    if ~isempty(ind)
        salmn = mean(gapdur(ind,2));
        gapdur(ind,2) = gapdur(ind,2)/salmn;
        gapdur2(ind2,2) = gapdur2(ind2,2)/salmn;
    else
        gapdur(ind,:) = [];
        gapdur2(ind2,:) = [];
    end
end
for i = 1:maxlength
    ind = find(sylldur(:,1)==i);
    ind2 = find(sylldur2(:,1)==i);
%     if length(ind) < 20 | length(ind2) < 20
%         sylldur(ind,:) = [];
%         sylldur2(ind2,:) = [];
%         continue
%     end
    if ~isempty(ind)
        salmn = mean(sylldur(ind,2));
        sylldur(ind,2) = sylldur(ind,2)/salmn;
        sylldur2(ind2,2) = sylldur2(ind2,2)/salmn;
    else
        sylldur(ind,:) = [];
        sylldur2(ind2,:) = [];
    end
end

fignum = input('figure number for plotting repeat summary:');
figure(fignum);
subtightplot(1,3,1,0.07,0.08,0.1);hold on;
[hi lo mn1] = mBootstrapCI(runlength);
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(runlength2);
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel('Number of syllables in repeat');
title('Change in repeat length');

subtightplot(1,3,2,0.07,0.08,0.1);hold on;
[hi lo mn1] = mBootstrapCI(gapdur(:,2));
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(gapdur2(:,2));
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel({'Gap duration','(normalized)'});
title('Change in gap duration');

subtightplot(1,3,3,0.07,0.08,0.1);hold on;
[hi lo mn1] = mBootstrapCI(sylldur(:,2));
plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
[hi lo mn2] = mBootstrapCI(sylldur2(:,2));
plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
ylabel({'Syllable duration','(normalized)'});
title('Change in syllable duration');

