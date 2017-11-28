load('gap_correlation_analysis.mat');

%params
activitythresh = 10;%zscore from shuffled

%indices for units with detected activity above activitythresh
numcases = length(find(spk_gapdur_corr(:,4)>=activitythresh));
numsignificant = length(find(spk_gapdur_corr(:,4)>=activitythresh & spk_gapdur_corr(:,2)<=0.05));
negcorr = find(spk_gapdur_corr(:,4)>=activitythresh & spk_gapdur_corr(:,2)<= 0.05 & spk_gapdur_corr(:,1)<0);
poscorr = find(spk_gapdur_corr(:,4)>=activitythresh & spk_gapdur_corr(:,2)<= 0.05 & spk_gapdur_corr(:,1)>0);
sigcorr = find(spk_gapdur_corr(:,4)>=activitythresh & spk_gapdur_corr(:,2)<= 0.05);
notsigcorr = find(spk_gapdur_corr(:,4)>=activitythresh & spk_gapdur_corr(:,2)> 0.05);
durcorr_neg = length(find(spk_gapdur_corr(negcorr,9)<=0.05 | spk_gapdur_corr(negcorr,11)<=0.05));
durcorr_pos = length(find(spk_gapdur_corr(poscorr,9)<=0.05 | spk_gapdur_corr(poscorr,11)<=0.05));

%indices for single units based on pct_error<=0.01
numcases_su = length(find(spk_gapdur_corr(:,6)<=0.01));
numsignificant_su = length(find(spk_gapdur_corr(:,6)<=0.01 & spk_gapdur_corr(:,2)<=0.05));
negcorr_su = find(spk_gapdur_corr(:,6)<=0.01 & spk_gapdur_corr(:,2)<= 0.05 & spk_gapdur_corr(:,1)<0);
poscorr_su = find(spk_gapdur_corr(:,6)<=0.01 & spk_gapdur_corr(:,2)<= 0.05 & spk_gapdur_corr(:,1)>0);
sigcorr_su = find(spk_gapdur_corr(:,6)<=0.01 & spk_gapdur_corr(:,2)<= 0.05);
notsigcorr_su = find(spk_gapdur_corr(:,6)<=0.01 & spk_gapdur_corr(:,2)> 0.05);
durcorr_neg_su = length(find(spk_gapdur_corr(negcorr_su,9)<=0.05 | spk_gapdur_corr(negcorr_su,11)<=0.05));
durcorr_pos_su = length(find(spk_gapdur_corr(poscorr_su,9)<=0.05 | spk_gapdur_corr(poscorr_su,11)<=0.05));

%% plot distribution of significant correlation coefficients (units above activitythresh)
figure;hold on;[n b] = hist(spk_gapdur_corr(sigcorr,1),[-1:0.1:1]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(mean(spk_gapdur_corr(negcorr,1)),y(1),'b^','markersize',8);hold on;
plot(mean(spk_gapdur_corr(poscorr,1)),y(1),'r^','markersize',8);hold on;
title('r values for significant RA activity vs gap duration correlations');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
text(0,1,{['total active units:',num2str(numcases)];...
    ['proportion of significant cases:',num2str(numsignificant/numcases)];...
    ['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
    ['proportion significantly positive:',num2str(length(poscorr)/numcases)];...
    ['proportion neg corrs also correlated with dur1 OR dur2:',num2str(durcorr_neg/length(negcorr))];...
    ['proportion pos corrs also correlated with dur1 OR dur2:',num2str(durcorr_pos/length(poscorr))]},'units','normalized',...
    'verticalalignment','top');

%% plot distribution of significant correlation coefficients (single units)
figure;hold on;[n b] = hist(spk_gapdur_corr(sigcorr_su,1),[-1:0.1:1]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(mean(spk_gapdur_corr(negcorr_su,1)),y(1),'b^','markersize',8);hold on;
plot(mean(spk_gapdur_corr(poscorr_su,1)),y(1),'r^','markersize',8);hold on;
title('r values for significant RA activity vs gap duration correlations (single units)');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
text(0,1,{['total active units:',num2str(numcases_su)];...
    ['proportion of significant cases:',num2str(numsignificant_su/numcases_su)];...
    ['proportion significantly negative:',num2str(length(negcorr_su)/numcases_su)];...
    ['proportion significantly positive:',num2str(length(poscorr_su)/numcases_su)];...
    ['proportion neg corrs also correlated with dur1 OR dur2:',num2str(durcorr_neg_su/length(negcorr_su))];...
    ['proportion pos corrs also correlated with dur1 OR dur2:',num2str(durcorr_pos_su/length(poscorr_su))]},'units','normalized',...
    'verticalalignment','top');

%% proportion of significant correlations in shuffled data
aph = 0.01;ntrials=1000;
shuffcorr = spk_gapdur_corr_shuff(:,1:2:end);
shuffpval = spk_gapdur_corr_shuff(:,2:2:end);
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randpropsignificant_lo = randpropsignificant_sorted(floor(aph*ntrials/2));
randpropsignificant_hi = randpropsignificant_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_lo = randpropsignificantnegcorr_sorted(floor(aph*ntrials/2));
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_lo = randpropsignificantposcorr_sorted(floor(aph*ntrials/2));
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

%% compare proportion of significant correlations 
figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
plot(numsignificant/numcases,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
plot(numsignificant_su/numcases_su,y(1),'kd','markersize',8,'markerfacecolor','k');hold on;
title('shuffled RA activity vs gap duration correlations');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
plot(length(negcorr)/numcases,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
plot(length(negcorr_su)/numcases_su,y(1),'bd','markersize',8,'markerfacecolor','b');hold on;
title('shuffled RA activity vs gap duration correlations');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.005:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
plot(length(poscorr)/numcases,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
plot(length(poscorr_su)/numcases_su,y(1),'rd','markersize',8,'markerfacecolor','r');hold on;
title('shuffled RA activity vs gap duration correlations');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');

%% power analysis
sampsize = [25:5:500];
corrvals = regressionpower(0.05,0.2,sampsize);
figure;
plot(spk_gapdur_corr(sigcorr,7),spk_gapdur_corr(sigcorr,1),'ok');hold on;
plot(spk_gapdur_corr(sigcorr_su,7),spk_gapdur_corr(sigcorr_su,1),'or');hold on;
plot(sampsize,corrvals,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
xlabel('sample size');ylabel('correlation');
legend({'units above pkactivity','single units'});

%% burst alignment vs firing rate, burst width, correlation (all units)
figure;subplot(1,4,1);hold on;
plot(spk_gapdur_corr(sigcorr,3),spk_gapdur_corr(sigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==1),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==2),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('activity (zsc)');xlabel('burst alignment');
err1 = stderr(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==1),4));
err2 = stderr(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==2),4));
errorbar(1,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==1),4)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==2),4)),err2,'k','linewidth',2);

subplot(1,4,2);hold on;
plot(spk_gapdur_corr(negcorr,3),spk_gapdur_corr(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==1),1));
err2 = stderr(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==2),1));
errorbar(1,mean(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('correlation');xlabel('burst alignment');

subplot(1,4,3);hold on;
plot(spk_gapdur_corr(poscorr,3),spk_gapdur_corr(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==1),1));
err2 = stderr(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==2),1));
errorbar(1,mean(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('correlation');xlabel('burst alignment');

subplot(1,4,4);hold on;
plot(spk_gapdur_corr(sigcorr,3),spk_gapdur_corr(sigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==1),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==2),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('burst width (ms)');xlabel('burst alignment');
err1 = stderr(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==1),5));
err2 = stderr(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==2),5));
errorbar(1,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==1),5)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(sigcorr(spk_gapdur_corr(sigcorr,3)==2),5)),err2,'k','linewidth',2);

%% burst alignment vs firing rate, burst width, correlation (single units)
figure;subplot(1,4,1);hold on;
plot(spk_gapdur_corr(sigcorr_su,3),spk_gapdur_corr(sigcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==1),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==2),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('activity (zsc');xlabel('burst alignment');
err1 = stderr(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==1),4));
err2 = stderr(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==2),4));
errorbar(1,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==1),4)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==2),4)),err2,'k','linewidth',2);

subplot(1,4,2);hold on;
plot(spk_gapdur_corr(negcorr_su,3),spk_gapdur_corr(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(negcorr_su(spk_gapdur_corr(negcorr_su,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(negcorr_su(spk_gapdur_corr(negcorr_su,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(negcorr_su(spk_gapdur_corr(negcorr_su,3)==1),1));
err2 = stderr(spk_gapdur_corr(negcorr_su(spk_gapdur_corr(negcorr_su,3)==2),1));
errorbar(1,mean(spk_gapdur_corr(negcorr_su(spk_gapdur_corr(negcorr_su,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(negcorr_su(spk_gapdur_corr(negcorr_su,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('correlation');xlabel('burst alignment');

subplot(1,4,3);hold on;
plot(spk_gapdur_corr(poscorr_su,3),spk_gapdur_corr(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(poscorr_su(spk_gapdur_corr(poscorr_su,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(poscorr_su(spk_gapdur_corr(poscorr_su,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(poscorr_su(spk_gapdur_corr(poscorr_su,3)==1),1));
err2 = stderr(spk_gapdur_corr(poscorr_su(spk_gapdur_corr(poscorr_su,3)==2),1));
errorbar(1,mean(spk_gapdur_corr(poscorr_su(spk_gapdur_corr(poscorr_su,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(poscorr_su(spk_gapdur_corr(poscorr_su,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('correlation');xlabel('burst alignment');

subplot(1,4,4);hold on;
plot(spk_gapdur_corr(sigcorr_su,3),spk_gapdur_corr(sigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==1),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==2),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('burst width (ms)');xlabel('burst alignment');
err1 = stderr(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==1),5));
err2 = stderr(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==2),5));
errorbar(1,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==1),5)),err1,'k','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(sigcorr_su(spk_gapdur_corr(sigcorr_su,3)==2),5)),err2,'k','linewidth',2);

%% compare proportion aligned to off1 for significant/not-sig, negative/positive, single/multi 
figure;subplot(1,3,1);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(sigcorr,3)==1);
bar(1,mn,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn,hi-mn,'b','linewidth',2);
[mn hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(notsigcorr,3)==1);
bar(2,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn,hi-mn,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('proportion aligned to off1');xlabel('correlation');
p = chisq_proptest(sum(spk_gapdur_corr(sigcorr,3)==1),sum(spk_gapdur_corr(notsigcorr,3)==1),length(sigcorr),length(notsigcorr));

subplot(1,3,2);hold on;
[mn1 hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(negcorr,3)==1);
bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn1,hi-mn1,'b','linewidth',2);
[mn2 hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(poscorr,3)==1);
bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn2,hi-mn2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('proportion aligned to off1');xlabel('correlation');
p = chisq_proptest(sum(spk_gapdur_corr(negcorr,3)==1),sum(spk_gapdur_corr(poscorr,3)==1),length(negcorr),length(poscorr));

subplot(1,3,3);hold on;
[mn1 hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(sigcorr,3)==1);
bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn1,hi-mn1,'b','linewidth',2);
[mn2 hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(sigcorr_su,3)==1);
bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn2,hi-mn2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'multi','single'});ylabel('proportion aligned to off1');xlabel('correlation');
p = chisq_proptest(sum(spk_gapdur_corr(sigcorr,3)==1),sum(spk_gapdur_corr(sigcorr_su,3)==1),length(negcorr),length(poscorr));

%% firing rate vs negatively/positively, significantly/not sig correlated (all units)
figure;subplot(1,2,1);hold on;
plot(1,spk_gapdur_corr(sigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(notsigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(notsigcorr,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(sigcorr,4));
err2 = stderr(spk_gapdur_corr(notsigcorr,4));
errorbar(1,mean(spk_gapdur_corr(sigcorr,4)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(notsigcorr,4)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(spk_gapdur_corr(sigcorr,4),spk_gapdur_corr(notsigcorr,4));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,spk_gapdur_corr(negcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(poscorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(negcorr,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(poscorr,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(negcorr,4));
err2 = stderr(spk_gapdur_corr(poscorr,4));
errorbar(1,mean(spk_gapdur_corr(negcorr,4)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(poscorr,4)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('activity (zsc)');xlabel('correlation');

%% firing rate vs negatively/positively, significantly/not sig correlated (single units)
figure;subplot(1,2,1);hold on;
plot(1,spk_gapdur_corr(sigcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(notsigcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr_su,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(notsigcorr_su,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(sigcorr_su,4));
err2 = stderr(spk_gapdur_corr(notsigcorr_su,4));
errorbar(1,mean(spk_gapdur_corr(sigcorr_su,4)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(notsigcorr_su,4)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(spk_gapdur_corr(sigcorr_su,4),spk_gapdur_corr(notsigcorr_su,4));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,spk_gapdur_corr(negcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(poscorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(negcorr_su,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(poscorr_su,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(negcorr_su,4));
err2 = stderr(spk_gapdur_corr(poscorr_su,4));
errorbar(1,mean(spk_gapdur_corr(negcorr_su,4)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(poscorr_su,4)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('activity (zsc)');xlabel('correlation');

%% burst width vs negatively/positively, significantly/not sig correlated (all units)
figure;subplot(1,2,1);hold on;
plot(1,spk_gapdur_corr(sigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(notsigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(notsigcorr,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(sigcorr,5));
err2 = stderr(spk_gapdur_corr(notsigcorr,5));
errorbar(1,mean(spk_gapdur_corr(sigcorr,5)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(notsigcorr,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('burst width (ms)');xlabel('correlation');
[h p] = ttest2(spk_gapdur_corr(sigcorr,5),spk_gapdur_corr(notsigcorr,5));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,spk_gapdur_corr(negcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(poscorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(negcorr,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(poscorr,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(negcorr,5));
err2 = stderr(spk_gapdur_corr(poscorr,5));
errorbar(1,mean(spk_gapdur_corr(negcorr,5)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(poscorr,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('burst width (ms)');xlabel('correlation');

%% burst width vs negatively/positively, significantly/not sig correlated (single units)
figure;subplot(1,2,1);hold on;
plot(1,spk_gapdur_corr(sigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(notsigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(sigcorr_su,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(notsigcorr_su,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(sigcorr_su,5));
err2 = stderr(spk_gapdur_corr(notsigcorr_su,5));
errorbar(1,mean(spk_gapdur_corr(sigcorr_su,5)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(notsigcorr_su,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('burst width (ms)');xlabel('correlation');
[h p] = ttest2(spk_gapdur_corr(sigcorr_su,5),spk_gapdur_corr(notsigcorr_su,5));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,spk_gapdur_corr(negcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,spk_gapdur_corr(poscorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(spk_gapdur_corr(negcorr_su,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(spk_gapdur_corr(poscorr_su,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(spk_gapdur_corr(negcorr_su,5));
err2 = stderr(spk_gapdur_corr(poscorr_su,5));
errorbar(1,mean(spk_gapdur_corr(negcorr_su,5)),err1,'b','linewidth',2);
errorbar(2,mean(spk_gapdur_corr(poscorr_su,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('burst width (ms)');xlabel('correlation');

%% correlation vs firing rate and burst width for all units/single units
figure;subplot(2,2,1);hold on;
plot(spk_gapdur_corr(negcorr,4),spk_gapdur_corr(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(negcorr,4),spk_gapdur_corr(negcorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,2);hold on;
plot(spk_gapdur_corr(poscorr,4),spk_gapdur_corr(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(poscorr,4),spk_gapdur_corr(poscorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,3);hold on;
plot(spk_gapdur_corr(negcorr_su,4),spk_gapdur_corr(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(negcorr_su,4),spk_gapdur_corr(negcorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,4);hold on;
plot(spk_gapdur_corr(poscorr_su,4),spk_gapdur_corr(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(poscorr_su,4),spk_gapdur_corr(poscorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

figure;subplot(2,2,1);hold on;
plot(spk_gapdur_corr(negcorr,5),spk_gapdur_corr(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(negcorr,5),spk_gapdur_corr(negcorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,2);hold on;
plot(spk_gapdur_corr(poscorr,5),spk_gapdur_corr(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(poscorr,5),spk_gapdur_corr(poscorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,3);hold on;
plot(spk_gapdur_corr(negcorr_su,5),spk_gapdur_corr(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(negcorr_su,5),spk_gapdur_corr(negcorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,4);hold on;
plot(spk_gapdur_corr(poscorr_su,5),spk_gapdur_corr(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(spk_gapdur_corr(poscorr_su,5),spk_gapdur_corr(poscorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

%% compare percentage of cases with significant correlations with target gap
%vs prev and next gap for neural activity at target gap
prevmultiind = find(spk_prevgapdur_corr(:,4)>=activitythresh);
negcorr_prevgap = (spk_prevgapdur_corr(prevmultiind,2)<= 0.05 & spk_prevgapdur_corr(prevmultiind,1)<0);
poscorr_prevgap = (spk_prevgapdur_corr(prevmultiind,2)<= 0.05 & spk_prevgapdur_corr(prevmultiind,1)>0);
sigcorr_prevgap = (spk_prevgapdur_corr(prevmultiind,2)<= 0.05);
notsigcorr_prevgap = (spk_prevgapdur_corr(prevmultiind,2)> 0.05);

nextmultiind = find(spk_nextgapdur_corr(:,4)>=activitythresh);
negcorr_nextgap = (spk_nextgapdur_corr(nextmultiind,2)<= 0.05 & spk_nextgapdur_corr(nextmultiind,1)<0);
poscorr_nextgap = (spk_nextgapdur_corr(nextmultiind,2)<= 0.05 & spk_nextgapdur_corr(nextmultiind,1)>0);
sigcorr_nextgap = (spk_nextgapdur_corr(nextmultiind,2)<= 0.05);
notsigcorr_nextgap = (spk_nextgapdur_corr(nextmultiind,2)> 0.05);

multiind = find(spk_gapdur_corr(:,4)>=activitythresh);
negcorr_targetgap = (spk_gapdur_corr(multiind,2)<= 0.05 & spk_gapdur_corr(multiind,1)<0);
poscorr_targetgap = (spk_gapdur_corr(multiind,2)<= 0.05 & spk_gapdur_corr(multiind,1)>0);
sigcorr_targetgap = (spk_gapdur_corr(multiind,2)<= 0.05);
notsigcorr_targetgap = (spk_gapdur_corr(multiind,2)> 0.05);

figure;ax = subplot(2,1,1);hold on;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(sigcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(sigcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(sigcorr_nextgap);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi randpropsignificant_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(negcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(negcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(negcorr_nextgap);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(poscorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(poscorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(poscorr_nextgap);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');

prevsingleiind = find(spk_prevgapdur_corr(:,6)<=0.01);
negcorr_prevgap = (spk_prevgapdur_corr(prevsingleiind,2)<= 0.05 & spk_prevgapdur_corr(prevsingleiind,1)<0);
poscorr_prevgap = (spk_prevgapdur_corr(prevsingleiind,2)<= 0.05 & spk_prevgapdur_corr(prevsingleiind,1)>0);
sigcorr_prevgap = (spk_prevgapdur_corr(prevsingleiind,2)<= 0.05);
notsigcorr_prevgap = (spk_prevgapdur_corr(prevsingleiind,2)> 0.05);

nextsingleiind = find(spk_nextgapdur_corr(:,6)<=0.01);
negcorr_nextgap = (spk_nextgapdur_corr(nextsingleiind,2)<= 0.05 & spk_nextgapdur_corr(nextsingleiind,1)<0);
poscorr_nextgap = (spk_nextgapdur_corr(nextsingleiind,2)<= 0.05 & spk_nextgapdur_corr(nextsingleiind,1)>0);
sigcorr_nextgap = (spk_nextgapdur_corr(nextsingleiind,2)<= 0.05);
notsigcorr_nextgap = (spk_nextgapdur_corr(nextsingleiind,2)> 0.05);

singleiind = find(spk_gapdur_corr(:,6)<=0.01);
negcorr_targetgap = (spk_gapdur_corr(singleiind,2)<= 0.05 & spk_gapdur_corr(singleiind,1)<0);
poscorr_targetgap = (spk_gapdur_corr(singleiind,2)<= 0.05 & spk_gapdur_corr(singleiind,1)>0);
sigcorr_targetgap = (spk_gapdur_corr(singleiind,2)<= 0.05);
notsigcorr_targetgap = (spk_gapdur_corr(singleiind,2)> 0.05);

ax = subplot(2,1,2);hold on;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(sigcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(sigcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(sigcorr_nextgap);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi randpropsignificant_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(negcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(negcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(negcorr_nextgap);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(poscorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(poscorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(poscorr_nextgap);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');

%% compare percentage of cases with significant correlations with
%prev/current/next gap's activity with current gapdur
prevmultiind = find(prevspk_gapdur_corr(:,4)>=activitythresh);
negcorr_prevgap = (prevspk_gapdur_corr(prevmultiind,2)<= 0.05 & prevspk_gapdur_corr(prevmultiind,1)<0);
poscorr_prevgap = (prevspk_gapdur_corr(prevmultiind,2)<= 0.05 & prevspk_gapdur_corr(prevmultiind,1)>0);
sigcorr_prevgap = (prevspk_gapdur_corr(prevmultiind,2)<= 0.05);
notsigcorr_prevgap = (prevspk_gapdur_corr(prevmultiind,2)> 0.05);

nextmultiind = find(nextspk_gapdur_corr(:,4)>=activitythresh);
negcorr_nextgap = (nextspk_gapdur_corr(nextmultiind,2)<= 0.05 & nextspk_gapdur_corr(nextmultiind,1)<0);
poscorr_nextgap = (nextspk_gapdur_corr(nextmultiind,2)<= 0.05 & nextspk_gapdur_corr(nextmultiind,1)>0);
sigcorr_nextgap = (nextspk_gapdur_corr(nextmultiind,2)<= 0.05);
notsigcorr_nextgap = (nextspk_gapdur_corr(nextmultiind,2)> 0.05);

multiind = find(spk_gapdur_corr(:,4)>=activitythresh);
negcorr_targetgap = (spk_gapdur_corr(multiind,2)<= 0.05 & spk_gapdur_corr(multiind,1)<0);
poscorr_targetgap = (spk_gapdur_corr(multiind,2)<= 0.05 & spk_gapdur_corr(multiind,1)>0);
sigcorr_targetgap = (spk_gapdur_corr(multiind,2)<= 0.05);
notsigcorr_targetgap = (spk_gapdur_corr(multiind,2)> 0.05);

figure;ax = subplot(2,1,1);hold on;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(sigcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(sigcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(sigcorr_nextgap);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi randpropsignificant_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(negcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(negcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(negcorr_nextgap);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(poscorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(poscorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(poscorr_nextgap);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');

prevsingleiind = find(prevspk_gapdur_corr(:,6)<=0.01);
negcorr_prevgap = (prevspk_gapdur_corr(prevsingleiind,2)<= 0.05 & prevspk_gapdur_corr(prevsingleiind,1)<0);
poscorr_prevgap = (prevspk_gapdur_corr(prevsingleiind,2)<= 0.05 & prevspk_gapdur_corr(prevsingleiind,1)>0);
sigcorr_prevgap = (prevspk_gapdur_corr(prevsingleiind,2)<= 0.05);
notsigcorr_prevgap = (prevspk_gapdur_corr(prevsingleiind,2)> 0.05);

nextsingleiind = find(nextspk_gapdur_corr(:,6)<=0.01);
negcorr_nextgap = (nextspk_gapdur_corr(nextsingleiind,2)<= 0.05 & nextspk_gapdur_corr(nextsingleiind,1)<0);
poscorr_nextgap = (nextspk_gapdur_corr(nextsingleiind,2)<= 0.05 & nextspk_gapdur_corr(nextsingleiind,1)>0);
sigcorr_nextgap = (nextspk_gapdur_corr(nextsingleiind,2)<= 0.05);
notsigcorr_nextgap = (nextspk_gapdur_corr(nextsingleiind,2)> 0.05);

singleiind = find(spk_gapdur_corr(:,6)<=0.01);
negcorr_targetgap = (spk_gapdur_corr(singleiind,2)<= 0.05 & spk_gapdur_corr(singleiind,1)<0);
poscorr_targetgap = (spk_gapdur_corr(singleiind,2)<= 0.05 & spk_gapdur_corr(singleiind,1)>0);
sigcorr_targetgap = (spk_gapdur_corr(singleiind,2)<= 0.05);
notsigcorr_targetgap = (spk_gapdur_corr(singleiind,2)> 0.05);

ax = subplot(2,1,2);hold on;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(sigcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(sigcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(sigcorr_nextgap);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi randpropsignificant_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(negcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(negcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(negcorr_nextgap);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(poscorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(poscorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(poscorr_nextgap);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');