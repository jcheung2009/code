%% bk29bk8
load analysis/data_structures/motif_aabb_4_7_2014_sal.mat
load analysis/data_structures/motif_aabb_4_8_2014_naspm2.mat

gap_sal = arrayfun(@(x) x.gaps,motif_aabb_4_7_2014_sal,'un',0);
gap_sal = cell2mat(gap_sal);
gap_sal = gap_sal';

gap_naspm = arrayfun(@(x) x.gaps,motif_aabb_4_8_2014_naspm2,'un',0);
gap_naspm = cell2mat(gap_naspm);
gap_naspm = gap_naspm';

dur_sal = arrayfun(@(x) x.durations,motif_aabb_4_7_2014_sal,'un',0);
dur_sal = cell2mat(dur_sal);
dur_sal = dur_sal';

dur_naspm = arrayfun(@(x) x.durations,motif_aabb_4_8_2014_naspm2,'un',0);
dur_naspm = cell2mat(dur_naspm);
dur_naspm = dur_naspm';

mn = min([gap_sal;gap_naspm]);
mx = max([gap_sal;gap_naspm]);
figure;hold on;
for i = 1:3
    subplot(1,3,i);hold on;
    [n b] = hist(gap_sal(:,i),[mn(i):0.002:mx(i)]);stairs(b,n/sum(n),'k');hold on;
    [n b] = hist(gap_naspm(:,i),[mn(i):0.002:mx(i)]);stairs(b,n/sum(n),'r');hold on;
    plot(mean(gap_sal(:,i)),0,'k^');hold on;
    plot(mean(gap_naspm(:,i)),0,'r^');
    %[h p] = ttest2(gap_sal(:,i),gap_naspm(:,i));
    p = perm_diffmn(gap_sal(:,i),gap_naspm(:,i));
    text(0,1,{['p=',num2str(p)]},'units','normalized')
end

mn = min([dur_sal;dur_naspm]);
mx = max([dur_sal;dur_naspm]);
figure;hold on;
for i = 1:4
    subplot(1,4,i);hold on;
    [n b] = hist(dur_sal(:,i),[mn(i):0.002:mx(i)]);stairs(b,n/sum(n),'k');hold on;
    [n b] = hist(dur_naspm(:,i),[mn(i):0.002:mx(i)]);stairs(b,n/sum(n),'r');hold on;
    plot(mean(dur_sal(:,i)),0,'k^');hold on;
    plot(mean(dur_naspm(:,i)),0,'r^');
    %[h p] = ttest2(dur_sal(:,i),dur_naspm(:,i));
    p = perm_diffmn(dur_sal(:,i),dur_naspm(:,i));
    text(0,1,{['p=',num2str(p)]},'units','normalized')
end

%% pu26bk61
load analysis/data_structures/motif_bdtaa_10_5_2014_sal.mat
load analysis/data_structures/motif_bdtaa_10_8_2014_mid5.mat

tb_sal = jc_tb([motif_abccc_midazolam_2_12_2018(:).datenm]',7,0)./3600;
tb_mid = jc_tb([motif_bdtaa_10_8_2014_mid5(:).datenm]',7,0)./3600;
ind2 = find(tb_mid >= tb_mid(1)+1);
ind1 = find(tb_sal>=tb_mid(1)+1 & tb_sal<=tb_mid(end));


gap_sal = arrayfun(@(x) x.gaps,motif_bdtaa_10_5_2014_sal(ind1),'un',0);
gap_sal = cell2mat(gap_sal);
gap_sal = gap_sal';

gap_mid = arrayfun(@(x) x.gaps,motif_bdtaa_10_8_2014_mid5(ind2),'un',0);
gap_mid = cell2mat(gap_mid);
gap_mid = gap_mid';

dur_sal = arrayfun(@(x) x.durations,motif_bdtaa_10_5_2014_sal(ind1),'un',0);
dur_sal = cell2mat(dur_sal);
dur_sal = dur_sal';

dur_mid = arrayfun(@(x) x.durations,motif_bdtaa_10_8_2014_mid5(ind2),'un',0);
dur_mid = cell2mat(dur_mid);
dur_mid = dur_mid';

% gap_sal = jc_removeoutliers(gap_sal,3.5);
% gap_mid = jc_removeoutliers(gap_mid,3.5);
% dur_sal = jc_removeoutliers(dur_sal,3.5);
% dur_mid = jc_removeoutliers(dur_mid,3.5);

mn = min([gap_sal;gap_mid]);
mx = max([gap_sal;gap_mid]);
figure;hold on;
for i = 1:4
    subplot(1,4,i);hold on;
    [n b] = hist(gap_sal(:,i),[mn(i):0.004:mx(i)]);stairs(b,n/sum(n),'k');hold on;
    [n b] = hist(gap_mid(:,i),[mn(i):0.004:mx(i)]);stairs(b,n/sum(n),'b');hold on;
    plot(nanmean(gap_sal(:,i)),0,'k^');hold on;
    plot(nanmean(gap_mid(:,i)),0,'b^');
    %[h p] = ttest2(gap_sal(:,i),gap_naspm(:,i));
    p = perm_diffmn(gap_sal(:,i),gap_mid(:,i));
    text(0,1,{['p=',num2str(p)]},'units','normalized')
end

mn = min([dur_sal;dur_mid]);
mx = max([dur_sal;dur_mid]);
figure;hold on;
for i = 1:5
    subplot(1,5,i);hold on;
    [n b] = hist(dur_sal(:,i),[mn(i):0.004:mx(i)]);stairs(b,n/sum(n),'k');hold on;
    [n b] = hist(dur_mid(:,i),[mn(i):0.004:mx(i)]);stairs(b,n/sum(n),'b');hold on;
    plot(nanmean(dur_sal(:,i)),0,'k^');hold on;
    plot(nanmean(dur_mid(:,i)),0,'b^');
    %[h p] = ttest2(dur_sal(:,i),dur_naspm(:,i));
    p = perm_diffmn(dur_sal(:,i),dur_mid(:,i));
    text(0,1,{['p=',num2str(p)]},'units','normalized')
end