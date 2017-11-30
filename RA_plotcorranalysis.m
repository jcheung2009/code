
%params and input
load('gap_correlation_analysis.mat');
corrmat = spk_gapdur_corr;
nextcorrmat = spk_nextgapdur_corr;
prevcorrmat = spk_prevgapdur_corr;
nextactivity_corrmat = nextspk_gapdur_corr;
prevactivity_corrmat = prevspk_gapdur_corr;
corrmat_shuff = spk_gapdur_corr_shuff;
corrmat_shuffsu = spk_gapdur_corr_shuffsu;
activitythresh = 10;%zscore from shuffled

%indices for units with detected activity above activitythresh that have
%significant correlations
numcases = length(find(corrmat(:,4)>=activitythresh));
numsignificant = length(find(corrmat(:,4)>=activitythresh & corrmat(:,2)<=0.05));
negcorr = find(corrmat(:,4)>=activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)<0);
poscorr = find(corrmat(:,4)>=activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)>0);
sigcorr = find(corrmat(:,4)>=activitythresh & corrmat(:,2)<= 0.05);
notsigcorr = find(corrmat(:,4)>=activitythresh & corrmat(:,2)> 0.05);
try
    durcorr_neg = length(find(corrmat(negcorr,9)<=0.05 | corrmat(negcorr,11)<=0.05));
    durcorr_pos = length(find(corrmat(poscorr,9)<=0.05 | corrmat(poscorr,11)<=0.05));   
end

%indices for single units based on pct_error<=0.01 that have significant
%correlations
numcases_su = length(find(corrmat(:,6)<=0.01));
numsignificant_su = length(find(corrmat(:,6)<=0.01 & corrmat(:,2)<=0.05));
negcorr_su = find(corrmat(:,6)<=0.01 & corrmat(:,2)<= 0.05 & corrmat(:,1)<0);
poscorr_su = find(corrmat(:,6)<=0.01 & corrmat(:,2)<= 0.05 & corrmat(:,1)>0);
sigcorr_su = find(corrmat(:,6)<=0.01 & corrmat(:,2)<= 0.05);
notsigcorr_su = find(corrmat(:,6)<=0.01 & corrmat(:,2)> 0.05);
try
    durcorr_neg_su = length(find(corrmat(negcorr_su,9)<=0.05 | corrmat(negcorr_su,11)<=0.05));
    durcorr_pos_su = length(find(corrmat(poscorr_su,9)<=0.05 | corrmat(poscorr_su,11)<=0.05));
end

%indices for multiunits above activity threshold
prevmultiind = find(prevactivity_corrmat(:,4)>=activitythresh);
nextmultiind = find(nextactivity_corrmat(:,4)>=activitythresh);
multiind = find(corrmat(:,4)>=activitythresh);

%indices for singleunits 
prevsingleiind = find(prevactivity_corrmat(:,6)<=0.01);
nextsingleiind = find(nextactivity_corrmat(:,6)<=0.01);
singleiind = find(corrmat(:,6)<=0.01);

%% proportion of significant correlations in shuffled data (all units)
aph = 0.01;ntrials=1000;
shuffcorr = corrmat_shuff(:,1:2:end);
shuffpval = corrmat_shuff(:,2:2:end);
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

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

%% compare proportion of significant correlations (all units)
figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
plot(numsignificant/numcases,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
title('shuffled vs empirical all units');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
plot(length(negcorr)/numcases,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
title('shuffled vs empirical all units');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.005:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
plot(length(poscorr)/numcases,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
title('shuffled vs empirical all units');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');

%% proportion of significant correlations in shuffled data (single units)
aph = 0.01;ntrials=1000;
shuffcorrsu = corrmat_shuffsu(:,1:2:end);
shuffpvalsu = corrmat_shuffsu(:,2:2:end);
randnumsignificant_su = sum(shuffpvalsu<=0.05,2);    
randpropsignificant_su = randnumsignificant_su/size(shuffpvalsu,2);
randpropsignificant_sorted_su = sort(randpropsignificant_su);
randpropsignificant_lo_su = randpropsignificant_sorted_su(floor(aph*ntrials/2));
randpropsignificant_hi_su = randpropsignificant_sorted_su(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantnegcorr_su = sum((shuffpvalsu<=0.05).*(shuffcorrsu<0),2);
randpropsignificantnegcorr_su = randnumsignificantnegcorr_su./size(shuffpvalsu,2);
randpropsignificantnegcorr_sorted_su = sort(randpropsignificantnegcorr_su);
randpropsignificantnegcorr_lo_su = randpropsignificantnegcorr_sorted_su(floor(aph*ntrials/2));
randpropsignificantnegcorr_hi_su = randpropsignificantnegcorr_sorted_su(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantposcorr_su = sum((shuffpvalsu<=0.05).*(shuffcorrsu>0),2);
randpropsignificantposcorr_su = randnumsignificantposcorr_su./size(shuffpvalsu,2);
randpropsignificantposcorr_sorted_su = sort(randpropsignificantposcorr_su);
randpropsignificantposcorr_lo_su = randpropsignificantposcorr_sorted_su(floor(aph*ntrials/2));
randpropsignificantposcorr_hi_su = randpropsignificantposcorr_sorted_su(ceil(ntrials-(aph*ntrials/2)));

randdiffprop_su = abs(randpropsignificantnegcorr_su-randpropsignificantposcorr_su);
%% compare proportion of significant correlations (single units)
figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant_su,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi_su,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo_su,y(1),'k^','markersize',8);hold on;
plot(numsignificant_su/numcases_su,y(1),'kd','markersize',8,'markerfacecolor','k');hold on;
title('shuffled vs empirical single units');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr_su,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi_su,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo_su,y(1),'b^','markersize',8);hold on;
plot(length(negcorr_su)/numcases_su,y(1),'bd','markersize',8,'markerfacecolor','b');hold on;
title('shuffled vs empirical single units');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr_su,[0:0.005:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo_su,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi_su,y(1),'r^','markersize',8);hold on;
plot(length(poscorr_su)/numcases_su,y(1),'rd','markersize',8,'markerfacecolor','r');hold on;
title('shuffled vs empirical single units');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');

%% distribution of correlation coefficients empirical vs shuffled data
figure;subplot(1,2,1);hold on;
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(multiind,1),[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(multiind,1)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
legend('shuffled','all units');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(multiind,1),shuffcorr(:));
[h p2] = ttest2(corrmat(multiind,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((length(negcorr)/numcases)-(length(poscorr)/numcases))))/ntrials;
try
    text(0,1,{['total active units:',num2str(numcases)];...
        ['proportion of significant cases:',num2str(numsignificant/numcases)];...
        ['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
        ['proportion significantly positive:',num2str(length(poscorr)/numcases)];...
        ['proportion neg corrs also correlated with dur1 OR dur2:',num2str(durcorr_neg/length(negcorr))];...
        ['proportion pos corrs also correlated with dur1 OR dur2:',num2str(durcorr_pos/length(poscorr))];...
        ['p(F)=',num2str(p)];['p(t)=',num2str(p2)]},'units','normalized',...
        'verticalalignment','top');
catch
    text(0,1,{['total active units:',num2str(numcases)];...
        ['proportion of significant cases:',num2str(numsignificant/numcases)];...
        ['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
        ['proportion significantly positive:',num2str(length(poscorr)/numcases)];...
        ['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(neg-pos)=',num2str(p3)]},'units','normalized',...
        'verticalalignment','top');
end


subplot(1,2,2);hold on;
[n b] = hist(shuffcorrsu(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(singleiind,1),[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(singleiind,1)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorrsu(:)),y(1),'k^','markersize',8);hold on;
legend('shuffled','single units');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(singleiind,1),shuffcorrsu(:));
[h p2] = ttest2(corrmat(singleiind,1),shuffcorrsu(:));
p3 = length(find(randdiffprop_su>=abs((length(negcorr_su)/numcases_su)-(length(poscorr_su)/numcases_su))))/ntrials;
try
    text(0,1,{['total active units:',num2str(numcases_su)];...
        ['proportion of significant cases:',num2str(numsignificant_su/numcases_su)];...
        ['proportion significantly negative:',num2str(length(negcorr_su)/numcases_su)];...
        ['proportion significantly positive:',num2str(length(poscorr_su)/numcases_su)];...
        ['proportion neg corrs also correlated with dur1 OR dur2:',num2str(durcorr_neg_su/length(negcorr_su))];...
        ['proportion pos corrs also correlated with dur1 OR dur2:',num2str(durcorr_pos_su/length(poscorr_su))];...
        ['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(neg-pos)=',num2str(p3)]},'units','normalized',...
        'verticalalignment','top');
catch
    text(0,1,{['total active units:',num2str(numcases_su)];...
        ['proportion of significant cases:',num2str(numsignificant_su/numcases_su)];...
        ['proportion significantly negative:',num2str(length(negcorr_su)/numcases_su)];...
        ['proportion significantly positive:',num2str(length(poscorr_su)/numcases_su)];...
        ['p(F)=',num2str(p)];['p(t)=',num2str(p2)]},'units','normalized',...
        'verticalalignment','top');
end

%% power analysis
sampsize = [25:5:500];
corrvals = regressionpower(0.05,0.2,sampsize);
figure;
plot(corrmat(sigcorr,7),abs(corrmat(sigcorr,1)),'ok');hold on;
plot(corrmat(sigcorr_su,7),abs(corrmat(sigcorr_su,1)),'or');hold on;
plot(sampsize,corrvals,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
xlabel('sample size');ylabel('correlation');
legend({'all units','single units'});

%% burst alignment vs firing rate, burst width, correlation (all units)
figure;subplot(1,4,1);hold on;
plot(corrmat(sigcorr,3),corrmat(sigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr(corrmat(sigcorr,3)==1),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(sigcorr(corrmat(sigcorr,3)==2),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('activity (zsc)');xlabel('burst alignment');
err1 = stderr(corrmat(sigcorr(corrmat(sigcorr,3)==1),4));
err2 = stderr(corrmat(sigcorr(corrmat(sigcorr,3)==2),4));
errorbar(1,mean(corrmat(sigcorr(corrmat(sigcorr,3)==1),4)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(sigcorr(corrmat(sigcorr,3)==2),4)),err2,'k','linewidth',2);
[h p] = ttest2(corrmat(sigcorr(corrmat(sigcorr,3)==1),4),corrmat(sigcorr(corrmat(sigcorr,3)==2),4));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,2);hold on;
plot(corrmat(negcorr,3),corrmat(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr(corrmat(negcorr,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(negcorr(corrmat(negcorr,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr(corrmat(negcorr,3)==1),1));
err2 = stderr(corrmat(negcorr(corrmat(negcorr,3)==2),1));
errorbar(1,mean(corrmat(negcorr(corrmat(negcorr,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(negcorr(corrmat(negcorr,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('correlation');xlabel('burst alignment');
[h p] = ttest2(corrmat(sigcorr(corrmat(sigcorr,3)==1),1),corrmat(sigcorr(corrmat(sigcorr,3)==2),1));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,3);hold on;
plot(corrmat(poscorr,3),corrmat(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(poscorr(corrmat(poscorr,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr(corrmat(poscorr,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(corrmat(poscorr(corrmat(poscorr,3)==1),1));
err2 = stderr(corrmat(poscorr(corrmat(poscorr,3)==2),1));
errorbar(1,mean(corrmat(poscorr(corrmat(poscorr,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(poscorr(corrmat(poscorr,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('correlation');xlabel('burst alignment');
[h p] = ttest2(corrmat(sigcorr(corrmat(sigcorr,3)==1),1),corrmat(sigcorr(corrmat(sigcorr,3)==2),1));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,4);hold on;
plot(corrmat(sigcorr,3),corrmat(sigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr(corrmat(sigcorr,3)==1),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(sigcorr(corrmat(sigcorr,3)==2),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('burst width (ms)');xlabel('burst alignment');
err1 = stderr(corrmat(sigcorr(corrmat(sigcorr,3)==1),5));
err2 = stderr(corrmat(sigcorr(corrmat(sigcorr,3)==2),5));
errorbar(1,mean(corrmat(sigcorr(corrmat(sigcorr,3)==1),5)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(sigcorr(corrmat(sigcorr,3)==2),5)),err2,'k','linewidth',2);
[h p] = ttest2(corrmat(sigcorr(corrmat(sigcorr,3)==1),5),corrmat(sigcorr(corrmat(sigcorr,3)==2),5));
text(0,1,['p=',num2str(p)],'units','normalized');

%% burst alignment vs firing rate, burst width, correlation (single units)
figure;subplot(1,4,1);hold on;
plot(corrmat(sigcorr_su,3),corrmat(sigcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('activity (zsc');xlabel('burst alignment');
err1 = stderr(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),4));
err2 = stderr(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),4));
errorbar(1,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),4)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),4)),err2,'k','linewidth',2);

subplot(1,4,2);hold on;
plot(corrmat(negcorr_su,3),corrmat(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1));
err2 = stderr(corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1));
errorbar(1,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('correlation');xlabel('burst alignment');

subplot(1,4,3);hold on;
plot(corrmat(poscorr_su,3),corrmat(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1));
err2 = stderr(corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1));
errorbar(1,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('correlation');xlabel('burst alignment');

subplot(1,4,4);hold on;
plot(corrmat(sigcorr_su,3),corrmat(sigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('burst width (ms)');xlabel('burst alignment');
err1 = stderr(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5));
err2 = stderr(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5));
errorbar(1,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5)),err2,'k','linewidth',2);

%% compare proportion aligned to off1 for significant/not-sig, negative/positive, single/multi 
figure;subplot(1,3,1);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(sigcorr,3)==1);
bar(1,mn,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn,hi-mn,'b','linewidth',2);
[mn hi lo] = jc_BootstrapfreqCI(corrmat(notsigcorr,3)==1);
bar(2,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn,hi-mn,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(sigcorr,3)==1),sum(corrmat(notsigcorr,3)==1),length(sigcorr),length(notsigcorr));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,3,2);hold on;
[mn1 hi lo] = jc_BootstrapfreqCI(corrmat(negcorr,3)==1);
bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn1,hi-mn1,'b','linewidth',2);
[mn2 hi lo] = jc_BootstrapfreqCI(corrmat(poscorr,3)==1);
bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn2,hi-mn2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(negcorr,3)==1),sum(corrmat(poscorr,3)==1),length(negcorr),length(poscorr));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,3,3);hold on;
[mn1 hi lo] = jc_BootstrapfreqCI(corrmat(sigcorr,3)==1);
bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn1,hi-mn1,'b','linewidth',2);
[mn2 hi lo] = jc_BootstrapfreqCI(corrmat(sigcorr_su,3)==1);
bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn2,hi-mn2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'multi','single'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(sigcorr,3)==1),sum(corrmat(sigcorr_su,3)==1),length(sigcorr),length(sigcorr_su));
text(0,1,['p=',num2str(p)],'units','normalized');

%% firing rate vs negatively/positively, significantly/not sig correlated (all units)
figure;subplot(1,2,1);hold on;
plot(1,corrmat(sigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(notsigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(notsigcorr,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(sigcorr,4));
err2 = stderr(corrmat(notsigcorr,4));
errorbar(1,mean(corrmat(sigcorr,4)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(notsigcorr,4)),err2,'r','linewidth',2);
title('all units');
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(corrmat(sigcorr,4),corrmat(notsigcorr,4));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,corrmat(negcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(poscorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr,4));
err2 = stderr(corrmat(poscorr,4));
errorbar(1,mean(corrmat(negcorr,4)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(poscorr,4)),err2,'r','linewidth',2);
title('all units');
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(corrmat(negcorr,4),corrmat(poscorr,4));
text(0,1,['p=',num2str(p)],'units','normalized');

%% firing rate vs negatively/positively, significantly/not sig correlated (single units)
figure;subplot(1,2,1);hold on;
plot(1,corrmat(sigcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(notsigcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr_su,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(notsigcorr_su,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(sigcorr_su,4));
err2 = stderr(corrmat(notsigcorr_su,4));
errorbar(1,mean(corrmat(sigcorr_su,4)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(notsigcorr_su,4)),err2,'r','linewidth',2);
title('single units');
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(corrmat(sigcorr_su,4),corrmat(notsigcorr_su,4));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,corrmat(negcorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(poscorr_su,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr_su,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr_su,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr_su,4));
err2 = stderr(corrmat(poscorr_su,4));
errorbar(1,mean(corrmat(negcorr_su,4)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(poscorr_su,4)),err2,'r','linewidth',2);
title('single units');
title('single units');
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(corrmat(negcorr_su,4),corrmat(poscorr_su,4));
text(0,1,['p=',num2str(p)],'units','normalized');

%% firing rate distribution for all units vs single units with significant correlations
%all units = all that are significantly correlated
ind = find(corrmat(:,2)<=0.05);
figure;hold on;
minfr = floor(min(corrmat(sigcorr_su,4)));
maxfr = ceil(max(corrmat(sigcorr_su,4)));
[n b] = hist(corrmat(ind,4),[minfr:2:maxfr]);
stairs(b,n,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
[n b] = hist(corrmat(sigcorr_su,4),[minfr:2:maxfr]);
stairs(b,n,'k','linewidth',2);
xlabel('activity (zsc)');ylabel('counts');
legend('all units','single units');
%% distribution of burst width (all and single units)
minbw = floor(min(corrmat(multiind,5)));
maxbw = ceil(max(corrmat(multiind,5)));
figure;hold on;
[n b] = hist(corrmat(multiind,5),[minbw:2:maxbw]);
stairs(b,n/sum(n),'color',[0.5 0.5 0.5],'linewidth',2);hold on;
[n b] = hist(corrmat(singleiind,5),[minbw:2:maxbw]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
legend('multi units','single units');
xlabel('burst width (ms)');ylabel('probability');

%% burst width vs negatively/positively, significantly/not sig correlated (all units)
figure;subplot(1,2,1);hold on;
plot(1,corrmat(sigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(notsigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(notsigcorr,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(sigcorr,5));
err2 = stderr(corrmat(notsigcorr,5));
errorbar(1,mean(corrmat(sigcorr,5)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(notsigcorr,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('burst width (ms)');xlabel('correlation');
title('all units');
[h p] = ttest2(corrmat(sigcorr,5),corrmat(notsigcorr,5));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,corrmat(negcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(poscorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr,5));
err2 = stderr(corrmat(poscorr,5));
errorbar(1,mean(corrmat(negcorr,5)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(poscorr,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('burst width (ms)');xlabel('correlation');
title('all units');
[h p] = ttest2(corrmat(negcorr,5),corrmat(poscorr,5));
text(0,1,['p=',num2str(p)],'units','normalized');

%% burst width vs negatively/positively, significantly/not sig correlated (single units)
figure;subplot(1,2,1);hold on;
plot(1,corrmat(sigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(notsigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr_su,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(notsigcorr_su,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(sigcorr_su,5));
err2 = stderr(corrmat(notsigcorr_su,5));
errorbar(1,mean(corrmat(sigcorr_su,5)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(notsigcorr_su,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('burst width (ms)');xlabel('correlation');
title('single units');
[h p] = ttest2(corrmat(sigcorr_su,5),corrmat(notsigcorr_su,5));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,corrmat(negcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrmat(poscorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr_su,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr_su,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr_su,5));
err2 = stderr(corrmat(poscorr_su,5));
errorbar(1,mean(corrmat(negcorr_su,5)),err1,'b','linewidth',2);
errorbar(2,mean(corrmat(poscorr_su,5)),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('burst width (ms)');xlabel('correlation');
title('single units');
[h p] = ttest2(corrmat(negcorr_su,5),corrmat(poscorr_su,5));
text(0,1,['p=',num2str(p)],'units','normalized');

%% correlation vs firing rate and burst width for all units/single units
figure;subplot(2,2,1);hold on;
plot(corrmat(negcorr,4),corrmat(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr,4),corrmat(negcorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,2);hold on;
plot(corrmat(poscorr,4),corrmat(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr,4),corrmat(poscorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,3);hold on;
plot(corrmat(negcorr_su,4),corrmat(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr_su,4),corrmat(negcorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,4);hold on;
plot(corrmat(poscorr_su,4),corrmat(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr_su,4),corrmat(poscorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

figure;subplot(2,2,1);hold on;
plot(corrmat(negcorr,5),corrmat(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr,5),corrmat(negcorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,2);hold on;
plot(corrmat(poscorr,5),corrmat(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr,5),corrmat(poscorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,3);hold on;
plot(corrmat(negcorr_su,5),corrmat(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr_su,5),corrmat(negcorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,4);hold on;
plot(corrmat(poscorr_su,5),corrmat(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr_su,5),corrmat(poscorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

%% compare percentage of cases with significant correlations with target gap
%vs prev and next gap for neural activity at target gap
negcorr_prevgap = (prevcorrmat(prevmultiind,2)<= 0.05 & prevcorrmat(prevmultiind,1)<0);
poscorr_prevgap = (prevcorrmat(prevmultiind,2)<= 0.05 & prevcorrmat(prevmultiind,1)>0);
sigcorr_prevgap = (prevcorrmat(prevmultiind,2)<= 0.05);
notsigcorr_prevgap = (prevcorrmat(prevmultiind,2)> 0.05);

negcorr_nextgap = (nextcorrmat(nextmultiind,2)<= 0.05 & nextcorrmat(nextmultiind,1)<0);
poscorr_nextgap = (nextcorrmat(nextmultiind,2)<= 0.05 & nextcorrmat(nextmultiind,1)>0);
sigcorr_nextgap = (nextcorrmat(nextmultiind,2)<= 0.05);
notsigcorr_nextgap = (nextcorrmat(nextmultiind,2)> 0.05);

negcorr_targetgap = (corrmat(multiind,2)<= 0.05 & corrmat(multiind,1)<0);
poscorr_targetgap = (corrmat(multiind,2)<= 0.05 & corrmat(multiind,1)>0);
sigcorr_targetgap = (corrmat(multiind,2)<= 0.05);
notsigcorr_targetgap = (corrmat(multiind,2)> 0.05);

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
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'--','color',[0.5 0.5 0.5]);

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
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');
title('all units');

negcorr_prevgap = (prevcorrmat(prevsingleiind,2)<= 0.05 & prevcorrmat(prevsingleiind,1)<0);
poscorr_prevgap = (prevcorrmat(prevsingleiind,2)<= 0.05 & prevcorrmat(prevsingleiind,1)>0);
sigcorr_prevgap = (prevcorrmat(prevsingleiind,2)<= 0.05);
notsigcorr_prevgap = (prevcorrmat(prevsingleiind,2)> 0.05);

negcorr_nextgap = (nextcorrmat(nextsingleiind,2)<= 0.05 & nextcorrmat(nextsingleiind,1)<0);
poscorr_nextgap = (nextcorrmat(nextsingleiind,2)<= 0.05 & nextcorrmat(nextsingleiind,1)>0);
sigcorr_nextgap = (nextcorrmat(nextsingleiind,2)<= 0.05);
notsigcorr_nextgap = (nextcorrmat(nextsingleiind,2)> 0.05);

negcorr_targetgap = (corrmat(singleiind,2)<= 0.05 & corrmat(singleiind,1)<0);
poscorr_targetgap = (corrmat(singleiind,2)<= 0.05 & corrmat(singleiind,1)>0);
sigcorr_targetgap = (corrmat(singleiind,2)<= 0.05);
notsigcorr_targetgap = (corrmat(singleiind,2)> 0.05);

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
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi_su randpropsignificant_hi_su],'--','color',[0.5 0.5 0.5]);

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
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi_su randpropsignificantnegcorr_hi_su],'--','color',[0.5 0.5 0.5]);

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
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi_su randpropsignificantposcorr_hi_su],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');
title('single units');

%% compare percentage of cases with significant correlations with
%prev/current/next gap's activity with current gapdur
prevmultiind = find(prevactivity_corrmat(:,4)>=activitythresh);
negcorr_prevgap = (prevactivity_corrmat(prevmultiind,2)<= 0.05 & prevactivity_corrmat(prevmultiind,1)<0);
poscorr_prevgap = (prevactivity_corrmat(prevmultiind,2)<= 0.05 & prevactivity_corrmat(prevmultiind,1)>0);
sigcorr_prevgap = (prevactivity_corrmat(prevmultiind,2)<= 0.05);
notsigcorr_prevgap = (prevactivity_corrmat(prevmultiind,2)> 0.05);

nextmultiind = find(nextactivity_corrmat(:,4)>=activitythresh);
negcorr_nextgap = (nextactivity_corrmat(nextmultiind,2)<= 0.05 & nextactivity_corrmat(nextmultiind,1)<0);
poscorr_nextgap = (nextactivity_corrmat(nextmultiind,2)<= 0.05 & nextactivity_corrmat(nextmultiind,1)>0);
sigcorr_nextgap = (nextactivity_corrmat(nextmultiind,2)<= 0.05);
notsigcorr_nextgap = (nextactivity_corrmat(nextmultiind,2)> 0.05);

multiind = find(corrmat(:,4)>=activitythresh);
negcorr_targetgap = (corrmat(multiind,2)<= 0.05 & corrmat(multiind,1)<0);
poscorr_targetgap = (corrmat(multiind,2)<= 0.05 & corrmat(multiind,1)>0);
sigcorr_targetgap = (corrmat(multiind,2)<= 0.05);
notsigcorr_targetgap = (corrmat(multiind,2)> 0.05);

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
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'--','color',[0.5 0.5 0.5]);

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
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');
title('all units');

prevsingleiind = find(prevactivity_corrmat(:,6)<=0.01);
negcorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)<= 0.05 & prevactivity_corrmat(prevsingleiind,1)<0);
poscorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)<= 0.05 & prevactivity_corrmat(prevsingleiind,1)>0);
sigcorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)<= 0.05);
notsigcorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)> 0.05);

nextsingleiind = find(nextactivity_corrmat(:,6)<=0.01);
negcorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)<= 0.05 & nextactivity_corrmat(nextsingleiind,1)<0);
poscorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)<= 0.05 & nextactivity_corrmat(nextsingleiind,1)>0);
sigcorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)<= 0.05);
notsigcorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)> 0.05);

singleiind = find(corrmat(:,6)<=0.01);
negcorr_targetgap = (corrmat(singleiind,2)<= 0.05 & corrmat(singleiind,1)<0);
poscorr_targetgap = (corrmat(singleiind,2)<= 0.05 & corrmat(singleiind,1)>0);
sigcorr_targetgap = (corrmat(singleiind,2)<= 0.05);
notsigcorr_targetgap = (corrmat(singleiind,2)> 0.05);

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
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi_su randpropsignificant_hi_su],'--','color',[0.5 0.5 0.5]);

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
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi_su randpropsignificantnegcorr_hi_su],'--','color',[0.5 0.5 0.5]);

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
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi_su randpropsignificantposcorr_hi_su],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');
title('single units');

%% plot correlation at time lags relative to target gap (single units)

shuffcorr_lag = cellfun(@(x) x(:,1:2:end),crosscorr_shuff_su,'un',0);
shuffpval_lag = cellfun(@(x) x(:,2:2:end),crosscorr_shuff_su,'un',0);

ind1 = cellfun(@(x) x<0,shuffcorr_lag,'un',0);
ind2 = cellfun(@(x) x<=0.05,shuffpval_lag,'un',0);
propnegsigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
propnegsigshuff = cellfun(@(x) sum(x,2)/size(x,2),propnegsigshuff,'un',0);
propnegsigshuff = cellfun(@(x) sort(x),propnegsigshuff,'un',0);
propnegsigshuffhi = cellfun(@(x) x(ceil(0.95*length(x))),propnegsigshuff,'un',1);
propnegsigshufflo = cellfun(@(x) x(floor(0.05*length(x))),propnegsigshuff,'un',1);


ind1 = cellfun(@(x) x>0,shuffcorr_lag,'un',0);
proppossigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
proppossigshuff = cellfun(@(x) sum(x,2)/size(x,2),proppossigshuff,'un',0);
proppossigshuff = cellfun(@(x) sort(x),proppossigshuff,'un',0);
proppossigshuffhi = cellfun(@(x) x(ceil(0.95*length(x))),proppossigshuff,'un',1);
proppossigshufflo = cellfun(@(x) x(floor(0.05*length(x))),proppossigshuff,'un',1);

ind = find(cellfun(@(x) ~isempty(x),crosscorr_su));
[propnegsig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)<0),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),propnegsig,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),propnegsigshuffhi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),propnegsigshufflo,'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly negative cases');
title('single units');

[proppossig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)>0),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),proppossig,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),proppossigshuffhi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),proppossigshufflo,'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly positive cases');
title('single units');

mnnegcorrshuff = cellfun(@(x) x.*(x<0),shuffcorr_lag,'un',0);
[ii,~,v] = cellfun(@(x) find(x),mnnegcorrshuff,'un',0);
mnnegcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
mnnegcorrshuff = cellfun(@(x) sort(x),mnnegcorrshuff,'un',0);
mnnegcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnnegcorrshuff,'un',1);
mnnegcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnnegcorrshuff,'un',1);

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)<0),1)),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),mnnegcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),mnnegcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
title('single units');

mnposcorrshuff = cellfun(@(x) x.*(x>0),shuffcorr_lag,'un',0);
[ii,~,v] = cellfun(@(x) find(x),mnposcorrshuff,'un',0);
mnposcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
mnposcorrshuff = cellfun(@(x) sort(x),mnposcorrshuff,'un',0);
mnposcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnposcorrshuff,'un',1);
mnposcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnposcorrshuff,'un',1);
xlabel('time relative to target gap (ms)');ylabel('average correlation');

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)>0),1)),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),mnposcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),mnposcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target gap (ms)');ylabel('average correlation');
title('single units');

%% plot correlation at time lags relative to target gap (all units)

shuffcorr_lag = cellfun(@(x) x(:,1:2:end),crosscorr_shuff,'un',0);
shuffpval_lag = cellfun(@(x) x(:,2:2:end),crosscorr_shuff,'un',0);

ind1 = cellfun(@(x) x<0,shuffcorr_lag,'un',0);
ind2 = cellfun(@(x) x<=0.05,shuffpval_lag,'un',0);
propnegsigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
propnegsigshuff = cellfun(@(x) sum(x,2)/size(x,2),propnegsigshuff,'un',0);
propnegsigshuff = cellfun(@(x) sort(x),propnegsigshuff,'un',0);
propnegsigshuffhi = cellfun(@(x) x(ceil(0.95*length(x))),propnegsigshuff,'un',1);
propnegsigshufflo = cellfun(@(x) x(floor(0.05*length(x))),propnegsigshuff,'un',1);


ind1 = cellfun(@(x) x>0,shuffcorr_lag,'un',0);
proppossigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
proppossigshuff = cellfun(@(x) sum(x,2)/size(x,2),proppossigshuff,'un',0);
proppossigshuff = cellfun(@(x) sort(x),proppossigshuff,'un',0);
proppossigshuffhi = cellfun(@(x) x(ceil(0.95*length(x))),proppossigshuff,'un',1);
proppossigshufflo = cellfun(@(x) x(floor(0.05*length(x))),proppossigshuff,'un',1);

ind = find(cellfun(@(x) ~isempty(x),crosscorr));
[propnegsig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)<0),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),propnegsig,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),propnegsigshuffhi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),propnegsigshufflo,'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly negative cases');
title('all units');

[proppossig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)>0),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),proppossig,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),proppossigshuffhi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),proppossigshufflo,'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly positive cases');
title('all units');

mnnegcorrshuff = cellfun(@(x) x.*(x<0),shuffcorr_lag,'un',0);
[ii,~,v] = cellfun(@(x) find(x),mnnegcorrshuff,'un',0);
mnnegcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
mnnegcorrshuff = cellfun(@(x) sort(x),mnnegcorrshuff,'un',0);
mnnegcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnnegcorrshuff,'un',1);
mnnegcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnnegcorrshuff,'un',1);

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)<0),1)),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),mnnegcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),mnnegcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
title('all units');

mnposcorrshuff = cellfun(@(x) x.*(x>0),shuffcorr_lag,'un',0);
[ii,~,v] = cellfun(@(x) find(x),mnposcorrshuff,'un',0);
mnposcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
mnposcorrshuff = cellfun(@(x) sort(x),mnposcorrshuff,'un',0);
mnposcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnposcorrshuff,'un',1);
mnposcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnposcorrshuff,'un',1);
xlabel('time relative to target gap (ms)');ylabel('average correlation');

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)>0),1)),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
plot(crosscorr_lags(ind),mnposcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
plot(crosscorr_lags(ind),mnposcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target gap (ms)');ylabel('average correlation');
title('all units');

