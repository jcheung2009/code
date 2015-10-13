function [rep sdur gdur] = jc_plotrepeatsummary(fv_rep_sal,fv_rep_cond,marker,linecolor)
%plots summary data for changes in repeat length, gap duration, and
%syllable duration for target repeat
%gap durations and syllable durations are matched by repeat position before
%normalizing 
%for blocked design

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

runlength = [fv_rep_sal(:).runlength];
runlength2 = [fv_rep_cond(:).runlength];
fignum = input('figure number for checking time course:');
figure(fignum);hold on;
plot(tb_cond/3600,runlength2,'k.');hold on;
timewindow = input('how many hours from the end:');
cla;
ind = find(tb_cond >= tb_cond(end)-timewindow*3600 & tb_cond <= tb_cond(end));
tb_cond = tb_cond(ind);
indsal = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
tb_sal = tb_sal(indsal);
runlength = runlength(indsal);
runlength2 = runlength2(ind);

fv_rep_sal = fv_rep_sal(indsal);
fv_rep_cond = fv_rep_cond(ind);
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

figure(fignum);hold on
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
figure(fignum);hold on;
runlength2 = runlength2/mean(runlength);
%subtightplot(3,1,1,0.07,0.08,0.15);hold on;
[hi lo mn2] = mBootstrapCI(runlength2);
jitter = (-1+2*rand)/20;
xpt = 0.5+jitter;
plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0.4 .85],'xtick',[0.5,0.75],'xticklabel',{'saline','NASPM'});
ylabel('Repeat length relative to saline');
title('Change in repeat length');
rep = mn2;

% subtightplot(3,1,2,0.07,0.08,0.15);hold on;
 [hi lo mn2] = mBootstrapCI(gapdur2(:,2));
% plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
% set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'NASPM','saline'});
% ylabel('Gap duration relative to saline');
% title('Change in gap duration');
 gdur = mn2;
% 
% subtightplot(3,1,3,0.07,0.08,0.15);hold on;
 [hi lo mn2] = mBootstrapCI(sylldur2(:,2));
% plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
% set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'NASPM','saline'});
% ylabel('Syllable duration relative to saline');
% title('Change in syllable duration');
 sdur = mn2;
