function [pitchdiff voldiff entdiff pcvdiff timebins] = jc_erroranalysis(fv_syll_sal1, fv_syll_sal2,marker,linecolor);
%measuring changes in spectral features post treatment vs pre treatment
%days

tb_sal1 = jc_tb([fv_syll_sal1(:).datenm]',7,0);
tb_sal2 = jc_tb([fv_syll_sal2(:).datenm]',7,0);

pitch = [fv_syll_sal1(:).mxvals];
vol = log([fv_syll_sal1(:).maxvol]);
ent = [fv_syll_sal1(:).spent];

pitch2 = [fv_syll_sal2(:).mxvals];
vol2 = log([fv_syll_sal2(:).maxvol]);
ent2 = [fv_syll_sal2(:).spent];


fignum = input('figure number for checking outliers:');
figure(fignum);
plot(tb_sal1,pitch,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(pitch',nstd);
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal1(removeind) = [];
    plot(tb_sal1,pitch,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_sal1,vol,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(vol',nstd);
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal1(removeind) = [];
    plot(tb_sal1,vol,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_sal1,ent,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(ent',nstd);
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal1(removeind) = [];
    plot(tb_sal1,ent,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla


plot(tb_sal2,pitch2,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(pitch2',nstd);
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_sal2(removeind) = [];
    plot(tb_sal2,pitch2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_sal2,vol2,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(vol2',nstd);
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_sal2(removeind) = [];
    plot(tb_sal2,vol2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_sal2,ent2,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(ent2',nstd);
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_sal2(removeind) = [];
    plot(tb_sal2,ent2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;


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
    pitchn = pitch2(ind2)./mean(pitch(ind1));
    voln = vol2(ind2)./mean(vol(ind1));
    entn = ent2(ind2)./mean(ent(ind1));
  
    [diffvec1(i,2) diffvec1(i,3) diffvec1(i,1)] = mBootstrapCI(pitchn);
    [diffvec2(i,2) diffvec2(i,3) diffvec2(i,1)] = mBootstrapCI(voln);
    [diffvec3(i,2) diffvec3(i,3) diffvec3(i,1)] = mBootstrapCI(entn);
    mn1 = mBootstrapCI_CV(pitch(ind1));
    [mn2 hi lo] = mBootstrapCI_CV(pitch2(ind2));
    mn3 = mn2/mn1;
    hi = mn3+((hi-mn2)/mn1);
    lo = mn3-((mn2-lo)/mn1);
    diffvec4(i,1) = mn3;
    diffvec4(i,2) = hi;
    diffvec4(i,3) = lo;
endfignum = input('figure number for plotting normalized data:');
figure(fignum);hold on;

subtightplot(4,1,1,0.07,0.07,0.1);hold on;
plot(timebins,diffvec1(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec1(:,2)'; diffvec1(:,3)'],linecolor);hold on;
plot(timebins,diffvec1(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Pitch change');
xlabel('Time (hours since 7 AM)');
title('Change in pitch post vs pre treatment');

subtightplot(4,1,2,0.07,0.07,0.1);hold on;
plot(timebins,diffvec2(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec2(:,2)'; diffvec2(:,3)'],linecolor);hold on;
plot(timebins,diffvec2(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Volume change');
xlabel('Time (hours since 7 AM)');
title('Change in volume post vs pre treatment');

subtightplot(4,1,3,0.07,0.07,0.1);hold on;
plot(timebins,diffvec3(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec3(:,2)'; diffvec3(:,3)'],linecolor);hold on;
plot(timebins,diffvec3(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Entropy change');
xlabel('Time (hours since 7 AM)');
title('Change in entropy post vs pre treatment');

subtightplot(4,1,4,0.07,0.07,0.1);hold on;
plot(timebins,diffvec4(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec4(:,2)'; diffvec4(:,3)'],linecolor);hold on;
plot(timebins,diffvec4(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Pitch CV change');
xlabel('Time (hours since 7 AM)');
title('Change in pitch post vs pre treatment');

pitchdiff = diffvec1;
voldiff = diffvec2;
entdiff = diffvec3;
pcvdiff = diffvec4;


fignum = input('figure number for plotting normalized data:');
figure(fignum);hold on;

subtightplot(4,1,1,0.07,0.07,0.1);hold on;
plot(timebins,diffvec1(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec1(:,2)'; diffvec1(:,3)'],linecolor);hold on;
plot(timebins,diffvec1(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Pitch change');
xlabel('Time (hours since 7 AM)');
title('Change in pitch post vs pre treatment');

subtightplot(4,1,2,0.07,0.07,0.1);hold on;
plot(timebins,diffvec2(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec2(:,2)'; diffvec2(:,3)'],linecolor);hold on;
plot(timebins,diffvec2(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Volume change');
xlabel('Time (hours since 7 AM)');
title('Change in volume post vs pre treatment');

subtightplot(4,1,3,0.07,0.07,0.1);hold on;
plot(timebins,diffvec3(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec3(:,2)'; diffvec3(:,3)'],linecolor);hold on;
plot(timebins,diffvec3(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Entropy change');
xlabel('Time (hours since 7 AM)');
title('Change in entropy post vs pre treatment');

subtightplot(4,1,4,0.07,0.07,0.1);hold on;
plot(timebins,diffvec4(:,1),marker,'markersize',12);hold on;
plot([timebins; timebins],[diffvec4(:,2)'; diffvec4(:,3)'],linecolor);hold on;
plot(timebins,diffvec4(:,1),linecolor);hold on;
xlim = get(gca,'xlim');
plot(xlim,[1 1],'m');hold on;
ylabel('Pitch CV change');
xlabel('Time (hours since 7 AM)');
title('Change in pitch post vs pre treatment');

pitchdiff = diffvec1;
voldiff = diffvec2;
entdiff = diffvec3;
pcvdiff = diffvec4;
