function [motifdurdiff sylldurdiff gapdurdiff mcvdiff timebins] = jc_erroranalysis2(motif_sal1, motif_sal2,marker,linecolor)
%measuring change sin tempo post treatment vs pre treatment

tb_sal1 = jc_tb([motif_sal1(:).datenm]',7,0);
tb_sal2 = jc_tb([motif_sal2(:).datenm]',7,0);

motifdur = [motif_sal1(:).motifdur];
sylldur = mean([motif_sal1(:).durations],1);
gapdur = mean([motif_sal1(:).gaps],1);
motifdur2 = [motif_sal2(:).motifdur];
sylldur2 = mean([motif_sal2(:).durations],1);
gapdur2 = mean([motif_sal2(:).gaps],1);

fignum = input('figure number for checking outliers:');
figure(fignum);
h = plot(tb_sal1,motifdur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(motifdur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal1(removeind) = [];
    h = plot(tb_sal1,motifdur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal1,sylldur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(sylldur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal1(removeind) = [];
    h = plot(tb_sal1,sylldur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal1,gapdur,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(gapdur',nstd);
    motifdur(removeind) = [];
    sylldur(removeind) = [];
    gapdur(removeind) = [];
    tb_sal1(removeind) = [];
    h = plot(tb_sal1,gapdur,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal2,motifdur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(motifdur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_sal2(removeind) = [];
    h = plot(tb_sal2,motifdur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal2,sylldur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(sylldur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_sal2(removeind) = [];
    h = plot(tb_sal2,sylldur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

h = plot(tb_sal2,gapdur2,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    nstd = input('nstd:');
    delete(h);
    removeind = jc_findoutliers(gapdur2',nstd);
    motifdur2(removeind) = [];
    sylldur2(removeind) = [];
    gapdur2(removeind) = [];
    tb_sal2(removeind) = [];
    h = plot(tb_sal2,gapdur2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
delete(h);

halfwinsize = 0.5;%1 hour windows moved by half hour
jogsize = 0.5;
timebins = halfwinsize:jogsize:14-halfwinsize;
diffvec1 = NaN(length(timebins),3);
diffvec2 = NaN(length(timebins),3);
diffvec3 = NaN(length(timebins),3);
diffvec4 = NaN(length(timebins),3);

for i = 1:length(timebins)
    ind1 = find(tb_sal1/3600 >= (timebins(i)-halfwinsize) & tb_sal1/3600 < (timebins(i)+halfwinsize));
    ind2 = find(tb_sal2/3600 >= (timebins(i)-halfwinsize) & tb_sal2/3600 < (timebins(i)+halfwinsize));
    if length(ind1) < 20 | length(ind2) < 20
        continue
    end
    motifdurn = motifdur2(ind2)./mean(motifdur(ind1));
    sylldurn = sylldur2(ind2)./mean(sylldur(ind1));
    gapdurn = gapdur2(ind2)./mean(gapdur(ind1));
  
    [diffvec1(i,2) diffvec1(i,3) diffvec1(i,1)] = mBootstrapCI(motifdurn);
    [diffvec2(i,2) diffvec2(i,3) diffvec2(i,1)] = mBootstrapCI(sylldurn);
    [diffvec3(i,2) diffvec3(i,3) diffvec3(i,1)] = mBootstrapCI(gapdurn);
    mn1 = mBootstrapCI_CV(motifdur(ind1));
    [mn2 hi lo] = mBootstrapCI_CV(motifdur2(ind2));
    mn3 = mn2/mn1;
    hi = mn3+((hi-mn2)/mn1);
    lo = mn3-((mn2-lo)/mn1);
    diffvec4(i,1) = mn3;
    diffvec4(i,2) = hi;
    diffvec4(i,3) = lo;
end
fignum = input('figure number for plotting normalized data:');
figure(fignum);hold on;

subtightplot(4,1,1,0.07,0.07,0.1);hold on;
plot(timebins,diffvec1(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec1(:,2)'; diffvec1(:,3)'],linecolor);hold on;
plot(timebins,diffvec1(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Duration change');
xlabel('Time (hours since 7 AM)');
title('Change in motif duration post vs pre treatment');

subtightplot(4,1,2,0.07,0.07,0.1);hold on;
plot(timebins,diffvec2(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec2(:,2)'; diffvec2(:,3)'],linecolor);hold on;
plot(timebins,diffvec2(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Duration change');
xlabel('Time (hours since 7 AM)');
title('Change in syllable duration post vs pre treatment');

subtightplot(4,1,3,0.07,0.07,0.1);hold on;
plot(timebins,diffvec3(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec3(:,2)'; diffvec3(:,3)'],linecolor);hold on;
plot(timebins,diffvec3(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Duration change');
xlabel('Time (hours since 7 AM)');
title('Change in gap duration post vs pre treatment');

subtightplot(4,1,4,0.07,0.07,0.1);hold on;
plot(timebins,diffvec4(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec4(:,2)'; diffvec4(:,3)'],linecolor);hold on;
plot(timebins,diffvec4(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Duration CV change');
xlabel('Time (hours since 7 AM)');
title('Change in motif duration CV post vs pre treatment');

motifdurdiff = diffvec1;
sylldurdiff = diffvec2;
gapdurdiff = diffvec3;
mcvdiff = diffvec4;




