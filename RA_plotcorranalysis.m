
%params and input
load('gap_correlation_analysis1.mat');
activitythresh = 6;%zscore from shuffled
overlap = 0.02;%percent overlap threshold for single vs multi unit 

%indices for multi units with detected activity above activitythresh that have
%significant correlations
numcases = length(find(corrmat(:,4)>=activitythresh & corrmat(:,6) > overlap));
numsignificant = length(find(corrmat(:,4)>=activitythresh & corrmat(:,2)<=0.05 & corrmat(:,6) > overlap));
negcorr = find(corrmat(:,4)>=activitythresh & corrmat(:,6) > overlap & corrmat(:,2)<= 0.05 & corrmat(:,1)<0);
poscorr = find(corrmat(:,4)>=activitythresh & corrmat(:,6) > overlap & corrmat(:,2)<= 0.05 & corrmat(:,1)>0);
sigcorr = find(corrmat(:,4)>=activitythresh & corrmat(:,6) > overlap & corrmat(:,2)<= 0.05);
notsigcorr = find(corrmat(:,4)>=activitythresh & corrmat(:,6) > overlap & corrmat(:,2)> 0.05);
try
    durcorr_neg = length(find(corrmat(negcorr,9)<=0.05 | corrmat(negcorr,11)<=0.05));
    durcorr_pos = length(find(corrmat(poscorr,9)<=0.05 | corrmat(poscorr,11)<=0.05));   
end

%indices for single units based on pct_error<=overlap and above activitythresh that have significant
%correlations
numcases_su = length(find(corrmat(:,6)<=overlap & corrmat(:,4) >= activitythresh));
numsignificant_su = length(find(corrmat(:,6)<=overlap & corrmat(:,2)<=0.05 & corrmat(:,4) >= activitythresh));
negcorr_su = find(corrmat(:,6)<=overlap & corrmat(:,4) >= activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)<0);
poscorr_su = find(corrmat(:,6)<=overlap & corrmat(:,4) >= activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)>0);
sigcorr_su = find(corrmat(:,6)<=overlap & corrmat(:,4) >= activitythresh & corrmat(:,2)<= 0.05);
notsigcorr_su = find(corrmat(:,6)<=overlap & corrmat(:,4) >= activitythresh & corrmat(:,2)> 0.05);
try
    durcorr_neg_su = length(find(corrmat(negcorr_su,9)<=0.05 | corrmat(negcorr_su,11)<=0.05));
    durcorr_pos_su = length(find(corrmat(poscorr_su,9)<=0.05 | corrmat(poscorr_su,11)<=0.05));
end

%indices for multiunits above activity threshold
prevmultiind = find(prevactivity_corrmat(:,4)>=activitythresh & prevactivity_corrmat(:,6) > overlap);
nextmultiind = find(nextactivity_corrmat(:,4)>=activitythresh & nextactivity_corrmat(:,6) > overlap);
prevgapmultiind = find(prevcorrmat(:,4)>=activitythresh & prevcorrmat(:,6) > overlap);
nextgapmultiind = find(nextcorrmat(:,4)>=activitythresh & nextcorrmat(:,6) > overlap);
multiind = find(corrmat(:,4)>=activitythresh & corrmat(:,6) > overlap);

%indices for singleunits above activitythresh
prevsingleiind = find(prevactivity_corrmat(:,6)<=overlap & prevactivity_corrmat(:,4) >= activitythresh);
nextsingleiind = find(nextactivity_corrmat(:,6)<=overlap & nextactivity_corrmat(:,4) >= activitythresh);
prevgapsingleiind = find(prevcorrmat(:,6)<=overlap & prevcorrmat(:,4)>=activitythresh);
nextgapsingleiind = find(nextcorrmat(:,6)<=overlap & nextcorrmat(:,4)>=activitythresh);
singleiind = find(corrmat(:,6)<=overlap & corrmat(:,4) >= activitythresh);

%indices for significant multi units in correlation of bursts with other
%gaps in motif 
% sigcorr_all = find(corrmat_all(:,2)<=0.05);
% negcorr_all = find(corrmat_all(:,2)<=0.05 & corrmat_all(:,1)<0);
% poscorr_all = find(corrmat_all(:,2)<=0.05 & corrmat_all(:,1)>0);
% numcases_all = size(corrmat_all,1);
% 
% shuff_corr_all = corrmat_all_shuff(:,1:2:end);
% shuff_corrpval_all = corrmat_all_shuff(:,2:2:end);
% 
% shuff_propsigcorr_all = sum(shuff_corrpval_all<=0.05,2)./size(shuff_corrpval_all,2);
% shuff_propsigcorr_all = sort(shuff_propsigcorr_all);
% shuff_propsigcorr_all_hi = shuff_propsigcorr_all(ceil(0.975*length(shuff_propsigcorr_all)));
% shuff_propsigcorr_all_lo = shuff_propsigcorr_all(floor(0.025*length(shuff_propsigcorr_all)));
% shuff_propnegcorr_all = sum((shuff_corrpval_all<=0.05).*(shuff_corr_all<0),2)./size(shuff_corrpval_all,2);
% shuff_propnegcorr_all = sort(shuff_propnegcorr_all);
% shuff_propnegcorr_all_hi = shuff_propnegcorr_all(ceil(0.975*length(shuff_propnegcorr_all)));
% shuff_propnegcorr_all_lo = shuff_propnegcorr_all(floor(0.025*length(shuff_propnegcorr_all)));
% shuff_propposcorr_all = sum((shuff_corrpval_all<=0.05).*(shuff_corr_all>0),2)./size(shuff_corrpval_all,2);
% shuff_propposcorr_all = sort(shuff_propposcorr_all);
% shuff_propposcorr_all_hi = shuff_propposcorr_all(ceil(0.975*length(shuff_propposcorr_all)));
% shuff_propposcorr_all_lo = shuff_propposcorr_all(floor(0.025*length(shuff_propposcorr_all)));
% 
% mncorr_all = mean(abs(shuff_corr_all),1);
% mncorr_all = sort(mncorr_all);
% mncorr_all_hi = mncorr_all(ceil(0.975*length(mncorr_all)));
% mncorr_all_lo = mncorr_all(floor(0.025*length(mncorr_all)));

%indices for single units in correlation of bursts with other gaps in motif
% sigcorr_all_su = find(corrmat_all_su(:,2)<=0.05);
% negcorr_all_su = find(corrmat_all_su(:,2)<=0.05 & corrmat_all_su(:,1)<0);
% poscorr_all_su = find(corrmat_all_su(:,2)<=0.05 & corrmat_all_su(:,1)>0);
% numcases_all_su = size(corrmat_all_su,1);
% 
% shuff_corr_all_su = corrmat_all_shuff_su(:,1:2:end);
% shuff_corrpval_all_su = corrmat_all_shuff_su(:,2:2:end);
% 
% shuff_propsigcorr_all_su = sum(shuff_corrpval_all_su<=0.05,2)./size(shuff_corrpval_all_su,2);
% shuff_propsigcorr_all_su = sort(shuff_propsigcorr_all_su);
% shuff_propsigcorr_all_su_hi = shuff_propsigcorr_all_su(ceil(0.975*length(shuff_propsigcorr_all_su)));
% shuff_propsigcorr_all_su_lo = shuff_propsigcorr_all_su(floor(0.025*length(shuff_propsigcorr_all_su)));
% shuff_propnegcorr_all_su = sum((shuff_corrpval_all_su<=0.05).*(shuff_corr_all_su<0),2)./size(shuff_corrpval_all_su,2);
% shuff_propnegcorr_all_su = sort(shuff_propnegcorr_all_su);
% shuff_propnegcorr_all_su_hi = shuff_propnegcorr_all_su(ceil(0.975*length(shuff_propnegcorr_all_su)));
% shuff_propnegcorr_all_su_lo = shuff_propnegcorr_all_su(floor(0.025*length(shuff_propnegcorr_all_su)));
% shuff_propposcorr_all_su = sum((shuff_corrpval_all_su<=0.05).*(shuff_corr_all_su>0),2)./size(shuff_corrpval_all_su,2);
% shuff_propposcorr_all_su = sort(shuff_propposcorr_all_su);
% shuff_propposcorr_all_su_hi = shuff_propposcorr_all_su(ceil(0.975*length(shuff_propposcorr_all_su)));
% shuff_propposcorr_all_su_lo = shuff_propposcorr_all_su(floor(0.025*length(shuff_propposcorr_all_su)));
% 
% mncorr_all_su = mean(abs(shuff_corr_all_su),1);
% mncorr_all_su = sort(mncorr_all);
% mncorr_all_su_hi = mncorr_all(ceil(0.975*length(mncorr_all_su)));
% mncorr_all_su_lo = mncorr_all(floor(0.025*length(mncorr_all_su)));


%% number of unique active units and birds that went into analysis
case_id = case_name(1:2:end);
case_singleunit_id = unique(case_id(singleiind));
ix = cellfun(@(x) regexp(x,'_'),case_singleunit_id,'un',0);
case_singleunit_birdid = unique(cellfun(@(x,y) x(1:y(1)-1),case_singleunit_id,ix,'un',0));
disp([num2str(length(case_singleunit_id)),' single units in ',...
    num2str(length(case_singleunit_birdid)),' birds'])
case_multiunit_id = unique(case_id(multiind));
ix = cellfun(@(x) regexp(x,'_'),case_multiunit_id,'un',0);
case_multiunit_birdid = unique(cellfun(@(x,y) x(1:y(1)-1),case_multiunit_id,ix,'un',0));
disp([num2str(length(case_multiunit_id)),' multi units in ',...
    num2str(length(case_multiunit_birdid)),' birds'])

%% proportion of significant correlations in shuffled data (multi units)
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

%% compare proportion of significant correlations (multi units)
figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(multiind,2)<=0.05);
plot(mn,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'color',[0.5 0.5 0.5],'linewidth',4)
title('shuffled vs empirical multi units');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(multiind,2)<=0.05 & corrmat(multiind,1)<0);
plot(mn,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical multi units');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.005:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(multiind,2)<=0.05 & corrmat(multiind,1)>0);
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical multi units');
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
[n b] = hist(randpropsignificant_su,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi_su,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo_su,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(singleiind,2)<=0.05);
plot(mn,y(1),'kd','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'k','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr_su,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi_su,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo_su,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(singleiind,2)<=0.05 & corrmat(singleiind,1)<0);
plot(mn,y(1),'bd','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr_su,[0:0.01:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo_su,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi_su,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(singleiind,2)<=0.05 & corrmat(singleiind,1)>0);
plot(mn,y(1),'rd','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4);
title('shuffled vs empirical single units');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');

%% distribution of correlation coefficients empirical vs shuffled data
figure;hold on;
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(multiind,1),[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(multiind,1)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
legend('shuffled','multi units');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(multiind,1),shuffcorr(:));
[h p2] = ttest2(corrmat(multiind,1),shuffcorr(:));
[h p3] = kstest2(corrmat(multiind,1),shuffcorr(:));
p4 = length(find(randdiffprop>=abs((length(negcorr)/numcases)-(length(poscorr)/numcases))))/ntrials;
p5 = length(find(randpropsignificant>=length(sigcorr)/numcases))/ntrials;
p6 = length(find(randpropsignificantposcorr>=length(poscorr)/numcases))/ntrials;
p7 = length(find(randpropsignificantnegcorr>=length(negcorr)/numcases))/ntrials;
text(0,1,{['total active cases:',num2str(numcases)];...
['proportion significant cases:',num2str(numsignificant/numcases)];...
['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
['proportion significantly positive:',num2str(length(poscorr)/numcases)];...
['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(ks)=',num2str(p3)];...
['p(sig)=',num2str(p5)];['p(neg)=',num2str(p7)];['p(pos)=',num2str(p6)];...
['p(neg-pos)=',num2str(p4)]},'units','normalized',...
'verticalalignment','top');

figure;hold on;
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
[h p3] = kstest2(corrmat(singleiind,1),shuffcorrsu(:));
p4 = length(find(randdiffprop_su>=abs((length(negcorr_su)/numcases_su)-(length(poscorr_su)/numcases_su))))/ntrials;
p5 = length(find(randpropsignificant_su>=length(sigcorr_su)/numcases_su))/ntrials;
p6 = length(find(randpropsignificantposcorr_su>=length(poscorr_su)/numcases_su))/ntrials;
p7 = length(find(randpropsignificantnegcorr_su>=length(negcorr_su)/numcases_su))/ntrials;
text(0,1,{['total active cases:',num2str(numcases_su)];...
['proportion significant cases:',num2str(numsignificant_su/numcases_su)];...
['proportion significantly negative:',num2str(length(negcorr_su)/numcases_su)];...
['proportion significantly positive:',num2str(length(poscorr_su)/numcases_su)];...
['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(ks)=',num2str(p3)];...
['p(sig)=',num2str(p5)];['p(neg)=',num2str(p7)];['p(pos)=',num2str(p6)];...
['p(neg-pos)=',num2str(p4)]},'units','normalized',...
'verticalalignment','top');

%% power analysis
sampsize = [25:5:500];
corrvals = regressionpower(0.05,0.2,sampsize);
figure;
plot(corrmat(sigcorr,7),abs(corrmat(sigcorr,1)),'ok');hold on;
plot(corrmat(sigcorr_su,7),abs(corrmat(sigcorr_su,1)),'or');hold on;
plot(sampsize,corrvals,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
xlabel('sample size');ylabel('correlation');
legend({'multi units','single units'});
set(gca,'fontweight','bold');

%% distribution of sample sizes (multi vs single unit)
minsampsize = min([corrmat(multiind,7);corrmat(singleiind,7)]);
maxsampsize = max([corrmat(multiind,7);corrmat(singleiind,7)]);
figure;hold on;
[n b] = hist(corrmat(multiind,7),[minsampsize:5:maxsampsize]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(singleiind,7),[minsampsize:5:maxsampsize]);
stairs(b,n/sum(n),'r','linewidth',2);
legend('multi unit','single unit');
[h p] = kstest2(corrmat(multiind,7),corrmat(singleiind,7));
text(0,1,{['p(ks)=',num2str(p)]},'units','normalized','verticalalignment','top');
xlabel('sample size');ylabel('probability');

%% burst alignment vs firing rate, burst width, correlation (multi units)
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
[h p] = ttest2(corrmat(negcorr(corrmat(negcorr,3)==1),1),corrmat(negcorr(corrmat(negcorr,3)==2),1));
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
[h p] = ttest2(corrmat(poscorr(corrmat(poscorr,3)==1),1),corrmat(poscorr(corrmat(poscorr,3)==2),1));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,4);hold on;
plot(corrmat(sigcorr,3),corrmat(sigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr(corrmat(sigcorr,3)==1),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(sigcorr(corrmat(sigcorr,3)==2),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('burst width (ms)');xlabel('burst alignment');
err1 = stderr(corrmat(sigcorr(corrmat(sigcorr,3)==1),5));
err2 = stderr(corrmat(sigcorr(corrmat(sigcorr,3)==2),5));
errorbar(1,mean(corrmat(sigcorr(corrmat(sigcorr,3)==1),5)),err1,'k','linewidth',2);sigcorr
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
[h p] = ttest2(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),4),corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),4));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,2);hold on;
plot(corrmat(negcorr_su,3),corrmat(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1));
err2 = stderr(corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1));
errorbar(1,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('correlation');xlabel('burst alignment');
[h p] = ttest2(corrmat(negcorr_su(corrmat(negcorr_su,3)==1),1),corrmat(negcorr_su(corrmat(negcorr_su,3)==2),1));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,3);hold on;
plot(corrmat(poscorr_su,3),corrmat(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
err1 = stderr(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1));
err2 = stderr(corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1));
errorbar(1,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1)),err2,'k','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('correlation');xlabel('burst alignment');
[h p] = ttest2(corrmat(poscorr_su(corrmat(poscorr_su,3)==1),1),corrmat(poscorr_su(corrmat(poscorr_su,3)==2),1));
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,4,4);hold on;
plot(corrmat(sigcorr_su,3),corrmat(sigcorr_su,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(2,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'onset','offset'});ylabel('burst width (ms)');xlabel('burst alignment');
err1 = stderr(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5));
err2 = stderr(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5));
errorbar(1,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5)),err1,'k','linewidth',2);
errorbar(2,mean(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5)),err2,'k','linewidth',2);
[h p] = ttest2(corrmat(sigcorr_su(corrmat(sigcorr_su,3)==1),5),corrmat(sigcorr_su(corrmat(sigcorr_su,3)==2),5));
text(0,1,['p=',num2str(p)],'units','normalized');

%% compare proportion aligned to off1 for significant/not-sig, negative/positive for single+multi 
figure;subplot(1,2,1);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(sigcorr,3)==1);
bar(1,mn,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn,hi-mn,'b','linewidth',2);
[mn hi lo] = jc_BootstrapfreqCI(corrmat(notsigcorr,3)==1);
bar(2,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn,hi-mn,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(sigcorr,3)==1),sum(corrmat(notsigcorr,3)==1),length(sigcorr),length(notsigcorr));
text(0,1,['p=',num2str(p)],'units','normalized');
title('all units');

subplot(1,2,2);hold on;
[mn1 hi lo] = jc_BootstrapfreqCI(corrmat(negcorr,3)==1);
bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn1,hi-mn1,'b','linewidth',2);
[mn2 hi lo] = jc_BootstrapfreqCI(corrmat(poscorr,3)==1);
bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn2,hi-mn2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(negcorr,3)==1),sum(corrmat(poscorr,3)==1),length(negcorr),length(poscorr));
text(0,1,['p=',num2str(p)],'units','normalized');
title('all units');

figure;subplot(1,2,1);hold on;
[mn hi lo] = jc_BootstrapfreqCI(corrmat(sigcorr_su,3)==1);
bar(1,mn,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn,hi-mn,'b','linewidth',2);
[mn hi lo] = jc_BootstrapfreqCI(corrmat(notsigcorr_su,3)==1);
bar(2,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn,hi-mn,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(sigcorr_su,3)==1),sum(corrmat(notsigcorr_su,3)==1),length(sigcorr_su),length(notsigcorr_su));
text(0,1,['p=',num2str(p)],'units','normalized');
title('single units');

subplot(1,2,2);hold on;
[mn1 hi lo] = jc_BootstrapfreqCI(corrmat(negcorr_su,3)==1);
bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
errorbar(1,mn1,hi-mn1,'b','linewidth',2);
[mn2 hi lo] = jc_BootstrapfreqCI(corrmat(poscorr_su,3)==1);
bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
errorbar(2,mn2,hi-mn2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('proportion aligned to onset');xlabel('correlation');
p = chisq_proptest(sum(corrmat(negcorr_su,3)==1),sum(corrmat(poscorr_su,3)==1),length(negcorr_su),length(poscorr_su));
text(0,1,['p=',num2str(p)],'units','normalized');
title('single units');
%% firing rate vs negatively/positively, significantly/not sig correlated (multi units)
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

%% firing rate distribution for multi units vs single units 
%multi units = all that have > 1% clustering error with no activity
%threshold filter
ind = find(corrmat(:,6)>0.01);
ind2 = find(corrmat(:,6)<=0.01);
figure;hold on;
minfr = floor(min(corrmat(ind2,4)));
maxfr = ceil(max(corrmat(ind2,4)));
[n b] = hist(corrmat(ind,4),[minfr:2:maxfr]);
stairs(b,n,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
[n b] = hist(corrmat(ind2,4),[minfr:2:maxfr]);
stairs(b,n,'k','linewidth',2);
xlabel('activity (zsc)');ylabel('counts');
legend('multi units','single units');
set(gca,'fontweight','bold');
%% burst width distribution for multi vs single units 
%multi units = all that have > 1% clustering error with no activity
%threshold filter
ind = find(corrmat(:,6)>0.01);
ind2 = find(corrmat(:,6)<=0.01);
minbw = floor(min(corrmat(ind,5)));
maxbw = ceil(max(corrmat(ind,5)));
figure;hold on;
[n b] = hist(corrmat(ind,5),[minbw:2:maxbw]);
stairs(b,n/sum(n),'color',[0.5 0.5 0.5],'linewidth',2);hold on;
[n b] = hist(corrmat(ind2,5),[minbw:2:maxbw]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
legend('multi units','single units');
xlabel('burst width (ms)');ylabel('probability');

%% burst width vs negatively/positively, significantly/not sig correlated (multi units)
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

%% correlation vs firing rate and burst width for multi units/single units
figure;subplot(2,2,1);hold on;
plot(corrmat(negcorr,4),corrmat(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr,4),corrmat(negcorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('multi units');

subplot(2,2,2);hold on;
plot(corrmat(poscorr,4),corrmat(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr,4),corrmat(poscorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('multi units');

subplot(2,2,3);hold on;
plot(corrmat(negcorr_su,4),corrmat(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr_su,4),corrmat(negcorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('single units');

subplot(2,2,4);hold on;
plot(corrmat(poscorr_su,4),corrmat(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('activity (zsc)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr_su,4),corrmat(poscorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('single units');

figure;subplot(2,2,1);hold on;
plot(corrmat(negcorr,5),corrmat(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr,5),corrmat(negcorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('all units');

subplot(2,2,2);hold on;
plot(corrmat(poscorr,5),corrmat(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr,5),corrmat(poscorr,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('all units');

subplot(2,2,3);hold on;
plot(corrmat(negcorr_su,5),corrmat(negcorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(negcorr_su,5),corrmat(negcorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('single units');

subplot(2,2,4);hold on;
plot(corrmat(poscorr_su,5),corrmat(poscorr_su,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrmat(poscorr_su,5),corrmat(poscorr_su,1));
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');
title('single units');
%% compare percentage of cases with significant correlations with target gap
%vs prev and next gap for neural activity at target gap
negcorr_prevgap = (prevcorrmat(prevgapmultiind,2)<= 0.05 & prevcorrmat(prevgapmultiind,1)<0);
poscorr_prevgap = (prevcorrmat(prevgapmultiind,2)<= 0.05 & prevcorrmat(prevgapmultiind,1)>0);
sigcorr_prevgap = (prevcorrmat(prevgapmultiind,2)<= 0.05);
notsigcorr_prevgap = (prevcorrmat(prevgapmultiind,2)> 0.05);

negcorr_nextgap = (nextcorrmat(nextgapmultiind,2)<= 0.05 & nextcorrmat(nextgapmultiind,1)<0);
poscorr_nextgap = (nextcorrmat(nextgapmultiind,2)<= 0.05 & nextcorrmat(nextgapmultiind,1)>0);
sigcorr_nextgap = (nextcorrmat(nextgapmultiind,2)<= 0.05);
notsigcorr_nextgap = (nextcorrmat(nextgapmultiind,2)> 0.05);

negcorr_targetgap = (corrmat(multiind,2)<= 0.05 & corrmat(multiind,1)<0);
poscorr_targetgap = (corrmat(multiind,2)<= 0.05 & corrmat(multiind,1)>0);
sigcorr_targetgap = (corrmat(multiind,2)<= 0.05);
notsigcorr_targetgap = (corrmat(multiind,2)> 0.05);

figure;ax = subplot(2,1,1);hold on;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(sigcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(sigcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(sigcorr_nextgap);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.7 0.7 0.7];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.7 0.7 0.7]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi randpropsignificant_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(negcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(negcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(negcorr_nextgap);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.7 0.7 0.7];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.7 0.7 0.7]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(poscorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(poscorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(poscorr_nextgap);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.7 0.7 0.7];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.7 0.7 0.7]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');
title('multi units');set(gca,'fontweight','bold');

negcorr_prevgap = (prevcorrmat(prevgapsingleiind,2)<= 0.05 & prevcorrmat(prevgapsingleiind,1)<0);
poscorr_prevgap = (prevcorrmat(prevgapsingleiind,2)<= 0.05 & prevcorrmat(prevgapsingleiind,1)>0);
sigcorr_prevgap = (prevcorrmat(prevgapsingleiind,2)<= 0.05);
notsigcorr_prevgap = (prevcorrmat(prevgapsingleiind,2)> 0.05);

negcorr_nextgap = (nextcorrmat(nextgapsingleiind,2)<= 0.05 & nextcorrmat(nextgapsingleiind,1)<0);
poscorr_nextgap = (nextcorrmat(nextgapsingleiind,2)<= 0.05 & nextcorrmat(nextgapsingleiind,1)>0);
sigcorr_nextgap = (nextcorrmat(nextgapsingleiind,2)<= 0.05);
notsigcorr_nextgap = (nextcorrmat(nextgapsingleiind,2)> 0.05);

negcorr_targetgap = (corrmat(singleiind,2)<= 0.05 & corrmat(singleiind,1)<0);
poscorr_targetgap = (corrmat(singleiind,2)<= 0.05 & corrmat(singleiind,1)>0);
sigcorr_targetgap = (corrmat(singleiind,2)<= 0.05);
notsigcorr_targetgap = (corrmat(singleiind,2)> 0.05);

ax = subplot(2,1,2);hold on;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(sigcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(sigcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(sigcorr_nextgap);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.7 0.7 0.7];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.7 0.7 0.7]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[randpropsignificant_hi_su randpropsignificant_hi_su],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(negcorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(negcorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(negcorr_nextgap);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.7 0.7 0.7];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.7 0.7 0.7]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi_su randpropsignificantnegcorr_hi_su],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(poscorr_prevgap);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(poscorr_targetgap);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(poscorr_nextgap);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.7 0.7 0.7];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.7 0.7 0.7]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi_su randpropsignificantposcorr_hi_su],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion significant correlations');
title('single units');set(gca,'fontweight','bold');

%% compare percentage of cases with significant correlations with
%prev/current/next gap's activity with current gapdur
negcorr_prevgap = (prevactivity_corrmat(prevmultiind,2)<= 0.05 & prevactivity_corrmat(prevmultiind,1)<0);
poscorr_prevgap = (prevactivity_corrmat(prevmultiind,2)<= 0.05 & prevactivity_corrmat(prevmultiind,1)>0);
sigcorr_prevgap = (prevactivity_corrmat(prevmultiind,2)<= 0.05);
notsigcorr_prevgap = (prevactivity_corrmat(prevmultiind,2)> 0.05);

negcorr_nextgap = (nextactivity_corrmat(nextmultiind,2)<= 0.05 & nextactivity_corrmat(nextmultiind,1)<0);
poscorr_nextgap = (nextactivity_corrmat(nextmultiind,2)<= 0.05 & nextactivity_corrmat(nextmultiind,1)>0);
sigcorr_nextgap = (nextactivity_corrmat(nextmultiind,2)<= 0.05);
notsigcorr_nextgap = (nextactivity_corrmat(nextmultiind,2)> 0.05);

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
title('multi units');set(gca,'fontweight','bold');

negcorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)<= 0.05 & prevactivity_corrmat(prevsingleiind,1)<0);
poscorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)<= 0.05 & prevactivity_corrmat(prevsingleiind,1)>0);
sigcorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)<= 0.05);
notsigcorr_prevgap = (prevactivity_corrmat(prevsingleiind,2)> 0.05);

negcorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)<= 0.05 & nextactivity_corrmat(nextsingleiind,1)<0);
poscorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)<= 0.05 & nextactivity_corrmat(nextsingleiind,1)>0);
sigcorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)<= 0.05);
notsigcorr_nextgap = (nextactivity_corrmat(nextsingleiind,2)> 0.05);

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
title('single units');set(gca,'fontweight','bold');

%% plot correlation at time lags relative to target gap (single units)

shuffcorr_lag = cellfun(@(x) x(:,1:2:end),crosscorr_shuff_su,'un',0);
shuffpval_lag = cellfun(@(x) x(:,2:2:end),crosscorr_shuff_su,'un',0);

ind1 = cellfun(@(x) x<0,shuffcorr_lag,'un',0);
ind2 = cellfun(@(x) x<=0.05,shuffpval_lag,'un',0);
propnegsigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
propnegsigshuff = cellfun(@(x) sum(x,2)/size(x,2),propnegsigshuff,'un',0);
propnegsigshuff = cellfun(@(x) sort(x),propnegsigshuff,'un',0);
propnegsigshuffhi = cellfun(@(x) x(ceil(0.975*length(x))),propnegsigshuff,'un',1);
propnegsigshufflo = cellfun(@(x) x(floor(0.025*length(x))),propnegsigshuff,'un',1);

ind1 = cellfun(@(x) x>0,shuffcorr_lag,'un',0);
proppossigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
proppossigshuff = cellfun(@(x) sum(x,2)/size(x,2),proppossigshuff,'un',0);
proppossigshuff = cellfun(@(x) sort(x),proppossigshuff,'un',0);
proppossigshuffhi = cellfun(@(x) x(ceil(0.975*length(x))),proppossigshuff,'un',1);
proppossigshufflo = cellfun(@(x) x(floor(0.025*length(x))),proppossigshuff,'un',1);

ind = find(cellfun(@(x) ~isempty(x),crosscorr_su));
[propnegsig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)<0),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),propnegsig,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[propnegsigshuffhi' fliplr(propnegsigshufflo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly negative cases');
title('single units');set(gca,'fontweight','bold');

[proppossig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)>0),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),proppossig,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[proppossigshuffhi' fliplr(proppossigshufflo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly positive cases');
title('single units');set(gca,'fontweight','bold');

medcorrshuff = cellfun(@(x) mean(abs(x),2),shuffcorr_lag,'un',0);
medcorrshuff = cellfun(@(x) sort(x),medcorrshuff,'un',0);
medcorrshuff_hi = cellfun(@(x) x(ceil(0.975*length(x))),medcorrshuff,'un',1);
medcorrshuff_lo = cellfun(@(x) x(floor(0.025*length(x))),medcorrshuff,'un',1);

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(abs(x(:,1))),crosscorr_su(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[medcorrshuff_hi' fliplr(medcorrshuff_lo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('average abs correlation');
title('single units');set(gca,'fontweight','bold');

% mnnegcorrshuff = cellfun(@(x) x.*(x<0),shuffcorr_lag,'un',0);
% [ii,~,v] = cellfun(@(x) find(x),mnnegcorrshuff,'un',0);
% mnnegcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
% mnnegcorrshuff = cellfun(@(x) sort(x),mnnegcorrshuff,'un',0);
% mnnegcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnnegcorrshuff,'un',1);
% mnnegcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnnegcorrshuff,'un',1);
% 
% [hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)<0),1)),crosscorr_su(ind),'un',1);
% figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
% patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
% plot(crosscorr_lags(ind),mnnegcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
% plot(crosscorr_lags(ind),mnnegcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
% title('single units');
% 
% mnposcorrshuff = cellfun(@(x) x.*(x>0),shuffcorr_lag,'un',0);
% [ii,~,v] = cellfun(@(x) find(x),mnposcorrshuff,'un',0);
% mnposcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
% mnposcorrshuff = cellfun(@(x) sort(x),mnposcorrshuff,'un',0);
% mnposcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnposcorrshuff,'un',1);
% mnposcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnposcorrshuff,'un',1);
% xlabel('time relative to target gap (ms)');ylabel('average correlation');
% 
% [hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)>0),1)),crosscorr_su(ind),'un',1);
% figure;hold on;plot(crosscorr_lags(ind),mncorr,'r','marker','o','linewidth',2);
% patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
% plot(crosscorr_lags(ind),mnposcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
% plot(crosscorr_lags(ind),mnposcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
% xlabel('time relative to target gap (ms)');ylabel('average correlation');
% title('single units');

%% plot correlation at time lags relative to target gap (multi units)

shuffcorr_lag = cellfun(@(x) x(:,1:2:end),crosscorr_shuff,'un',0);
shuffpval_lag = cellfun(@(x) x(:,2:2:end),crosscorr_shuff,'un',0);

ind1 = cellfun(@(x) x<0,shuffcorr_lag,'un',0);
ind2 = cellfun(@(x) x<=0.05,shuffpval_lag,'un',0);
propnegsigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
propnegsigshuff = cellfun(@(x) sum(x,2)/size(x,2),propnegsigshuff,'un',0);
propnegsigshuff = cellfun(@(x) sort(x),propnegsigshuff,'un',0);
propnegsigshuffhi = cellfun(@(x) x(ceil(0.975*length(x))),propnegsigshuff,'un',1);
propnegsigshufflo = cellfun(@(x) x(floor(0.025*length(x))),propnegsigshuff,'un',1);

ind1 = cellfun(@(x) x>0,shuffcorr_lag,'un',0);
proppossigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
proppossigshuff = cellfun(@(x) sum(x,2)/size(x,2),proppossigshuff,'un',0);
proppossigshuff = cellfun(@(x) sort(x),proppossigshuff,'un',0);
proppossigshuffhi = cellfun(@(x) x(ceil(0.975*length(x))),proppossigshuff,'un',1);
proppossigshufflo = cellfun(@(x) x(floor(0.025*length(x))),proppossigshuff,'un',1);

ind = find(cellfun(@(x) ~isempty(x),crosscorr));
[propnegsig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)<0),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),propnegsig,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[propnegsigshuffhi' fliplr(propnegsigshufflo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly negative cases');
title('multi units');

[proppossig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)>0),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),proppossig,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[proppossigshuffhi' fliplr(proppossigshufflo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly positive cases');
title('multi units');

medcorrshuff = cellfun(@(x) mean(abs(x),2),shuffcorr_lag,'un',0);
medcorrshuff = cellfun(@(x) sort(x),medcorrshuff,'un',0);
medcorrshuff_hi = cellfun(@(x) x(ceil(0.975*length(x))),medcorrshuff,'un',1);
medcorrshuff_lo = cellfun(@(x) x(floor(0.025*length(x))),medcorrshuff,'un',1);

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(abs(x(:,1))),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[medcorrshuff_hi' fliplr(medcorrshuff_lo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('average abs correlation');
title('multi units');

% mnnegcorrshuff = cellfun(@(x) x.*(x<0),shuffcorr_lag,'un',0);
% [ii,~,v] = cellfun(@(x) find(x),mnnegcorrshuff,'un',0);
% mnnegcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
% mnnegcorrshuff = cellfun(@(x) sort(x),mnnegcorrshuff,'un',0);
% mnnegcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnnegcorrshuff,'un',1);
% mnnegcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnnegcorrshuff,'un',1);
% 
% [hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)<0),1)),crosscorr(ind),'un',1);
% figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
% patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
% plot(crosscorr_lags(ind),mnnegcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
% plot(crosscorr_lags(ind),mnnegcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
% title('all units');
% 
% mnposcorrshuff = cellfun(@(x) x.*(x>0),shuffcorr_lag,'un',0);
% [ii,~,v] = cellfun(@(x) find(x),mnposcorrshuff,'un',0);
% mnposcorrshuff = cellfun(@(x,y) accumarray(x,y,[],@mean),ii,v,'un',0);
% mnposcorrshuff = cellfun(@(x) sort(x),mnposcorrshuff,'un',0);
% mnposcorrshuff_hi = cellfun(@(x) x(ceil(0.95*length(x))),mnposcorrshuff,'un',1);
% mnposcorrshuff_lo = cellfun(@(x) x(floor(0.05*length(x))),mnposcorrshuff,'un',1);
% 
% [hi lo mncorr] = cellfun(@(x) mBootstrapCI(x(find(x(:,1)>0),1)),crosscorr(ind),'un',1);
% figure;hold on;plot(crosscorr_lags(ind),mncorr,'r','marker','o','linewidth',2);
% patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
% plot(crosscorr_lags(ind),mnposcorrshuff_hi,'color',[0.5 0.5 0.5],'linewidth',2);
% plot(crosscorr_lags(ind),mnposcorrshuff_lo,'color',[0.5 0.5 0.5],'linewidth',2);
% xlabel('time relative to target gap (ms)');ylabel('average correlation');
% title('all units');

%% compare correlations for bursts at other gaps in motif when unit has significant
%correlation at target gap 

figure;subplot(2,1,1);hold on;ax=gca;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(corrmat_all(:,2)<=0.05);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(corrmat_all_su(:,2)<=0.05);
b=bar(ax,[1 2],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
legend('multi units','single units');
offset = 0.1429;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1+offset,mn2,hi2-mn2,'r');
plot(ax,[1-2*offset 1],[shuff_propsigcorr_all_hi shuff_propsigcorr_all_hi],'--','color',[0.5 0.5 0.5]);
plot(ax,[1 1+2*offset],[shuff_propsigcorr_all_su_hi shuff_propsigcorr_all_su_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(corrmat_all(:,2)<=0.05 & corrmat_all(:,1)<0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(corrmat_all_su(:,2)<=0.05 & corrmat_all_su(:,1)<0);
b=bar(ax,[2 3],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2+offset,mn2,hi2-mn2,'r');
plot(ax,[2-2*offset 2],[shuff_propnegcorr_all_hi shuff_propnegcorr_all_hi],'--','color',[0.5 0.5 0.5]);
plot(ax,[2 2+2*offset],[shuff_propnegcorr_all_su_hi shuff_propnegcorr_all_su_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(corrmat_all(:,2)<=0.05 & corrmat_all(:,1)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(corrmat_all_su(:,2)<=0.05 & corrmat_all_su(:,1)>0);
b=bar(ax,[3 4],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3+offset,mn2,hi2-mn2,'r');
plot(ax,[3-3*offset 3],[shuff_propposcorr_all_hi shuff_propposcorr_all_hi],'--','color',[0.5 0.5 0.5]);
plot(ax,[3 3+3*offset],[shuff_propposcorr_all_su_hi shuff_propposcorr_all_su_hi],'--','color',[0.5 0.5 0.5]);

xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion of significant correlations');

subplot(2,1,2);hold on;ax=gca;
[mn1 hi1 lo1] = mBootstrapCI(abs(corrmat_all(:,1)));
[mn2 hi2 lo2] = mBootstrapCI(abs(corrmat_all_su(:,1)));
b=bar(ax,[1 2],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1+offset,mn2,hi2-mn2,'r');
plot(ax,[1-2*offset 1],[mncorr_all_hi mncorr_all_hi],'--','color',[0.5 0.5 0.5]);
plot(ax,[1 1+2*offset],[mncorr_all_su_hi mncorr_all_su_hi],'--','color',[0.5 0.5 0.5]);
legend('multi units','single units');
xticks(ax,[1,2]);xticklabels({'',''});xlim([0.5 1.5])
ylabel('average abs correlations');
%% compare distribution of correlation values for syllable vs gap (single units)
load('gap_correlation_analysis1.mat');
corrmat_gap = corrmat;
gapshuff = corrmat_shuffsu;
clearvars -except corrmat_gap gapshuff
load('dur_correlation_analysis1.mat');
corrmat_dur = corrmat;
durshuff = corrmat_shuffsu;
clearvars -except corrmat_gap corrmat_dur gapshuff durshuff
activitythresh = 6;
singleunitid_gap = find(corrmat_gap(:,6)<=0.01 & corrmat_gap(:,4)>=activitythresh);
singleunitid_dur = find(corrmat_dur(:,6)<=0.01 & corrmat_dur(:,4)>=activitythresh);
figure;hold on;
[n b] = hist(corrmat_gap(singleunitid_gap,1),[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);
[n b] = hist(corrmat_dur(singleunitid_dur,1),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
legend('gaps','syllables');
xlabel('correlation coefficient');ylabel('probability');
set(gca,'fontweight','bold');

numcases_gap = length(singleunitid_gap);
sigcorr_gap = length(find(corrmat_gap(singleunitid_gap,2)<=0.05));
negcorr_gap = length(find(corrmat_gap(singleunitid_gap,2)<=0.05 & corrmat_gap(singleunitid_gap,1)<0));
poscorr_gap = length(find(corrmat_gap(singleunitid_gap,2)<=0.05 & corrmat_gap(singleunitid_gap,1)>0));

numcases_dur = length(singleunitid_dur);
sigcorr_dur = length(find(corrmat_dur(singleunitid_dur,2)<=0.05));
negcorr_dur = length(find(corrmat_dur(singleunitid_dur,2)<=0.05 & corrmat_dur(singleunitid_dur,1)<0));
poscorr_dur = length(find(corrmat_dur(singleunitid_dur,2)<=0.05 & corrmat_dur(singleunitid_dur,1)>0));

pooledsamp = [corrmat_gap(singleunitid_gap,1:2);corrmat_dur(singleunitid_dur,1:2)];
ntrials = 1000;
diffsig = [];diffneg = [];diffpos=[];mndiff = [];
for i = 1:ntrials
    randpool = pooledsamp(randperm(length(pooledsamp),length(pooledsamp)),:);
    gapsamp = randpool(1:numcases_gap,:);
    dursamp = randpool(numcases_gap+1:end,:);
    sigcorr_gapsamp = length(find(gapsamp(:,2)<=0.05));
    negcorr_gapsamp = length(find(gapsamp(:,2)<=0.05 & gapsamp(:,1)<0));
    poscorr_gapsamp = length(find(gapsamp(:,2)<=0.05 & gapsamp(:,1)>0));
    sigcorr_dursamp = length(find(dursamp(:,2)<=0.05));
    negcorr_dursamp = length(find(dursamp(:,2)<=0.05 & dursamp(:,1)<0));
    poscorr_dursamp = length(find(dursamp(:,2)<=0.05 & dursamp(:,1)>0));
    diffsig = [diffsig; ((sigcorr_gapsamp/length(gapsamp))-(sigcorr_dursamp/length(dursamp)))];
    diffneg = [diffneg; ((negcorr_gapsamp/length(gapsamp))-(negcorr_dursamp/length(dursamp)))];
    diffpos = [diffpos; ((poscorr_gapsamp/length(gapsamp))-(poscorr_dursamp/length(dursamp)))];
    mndiff = [mndiff; mean(gapsamp(:,1))-mean(dursamp(:,1))];
end
p_diffsig = length(find(abs(diffsig)>=abs((sigcorr_gap/numcases_gap)-(sigcorr_dur/numcases_dur))))/ntrials
p_diffneg = length(find(abs(diffneg)>=abs((negcorr_gap/numcases_gap)-(negcorr_dur/numcases_dur))))/ntrials
p_diffpos = length(find(abs(diffpos)>=abs((poscorr_gap/numcases_gap)-(poscorr_dur/numcases_dur))))/ntrials
p_mndiff = length(find(abs(mndiff)>=abs(mean(corrmat_gap(singleunitid_gap,1))-mean(corrmat_dur(singleunitid_dur,1)))))/ntrials;
text(0,1,{['p(abs(siggap-sigdur))=',num2str(p_diffsig)];...
    ['p(abs(neggap-negdur))=',num2str(p_diffneg)];...
    ['p(abs(posgap-posdur))=',num2str(p_diffpos)]},'units','normalized','verticalalignment','top');

%% compare sample sizes for syllable vs gap data sets (single units)
load('gap_correlation_analysis1.mat');
corrmat_gap = corrmat;
clearvars -except corrmat_gap 
load('dur_correlation_analysis1.mat');
corrmat_dur = corrmat;
clearvars -except corrmat_gap corrmat_dur  
activitythresh = 6;
idgap = find(corrmat_gap(:,6)<=0.01 & corrmat_gap(:,4)>=activitythresh & corrmat_gap(:,2)<=0.05);
iddur = find(corrmat_dur(:,6)<=0.01 & corrmat_dur(:,4)>=activitythresh & corrmat_dur(:,2)<=0.05);
sampsize = [25:5:500];
corrvals = regressionpower(0.05,0.2,sampsize);
figure;
plot(corrmat_gap(idgap,7),abs(corrmat_gap(idgap,1)),'ok');hold on;
plot(corrmat_dur(iddur,7),abs(corrmat_dur(iddur,1)),'or');hold on;
plot(sampsize,corrvals,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
xlabel('sample size');ylabel('correlation');
legend({'gaps','syllables'});
set(gca,'fontweight','bold');

%% mixed linear model (single units)
load('gap_correlation_analysis1.mat');
data_singleunit_gap = data(data.unittype<=0.01 & data.activity>=6 & data.corrpval<=0.05,:);
data_singleunit_gap.gap_or_dur = repmat(1,size(data_singleunit_gap,1),1);
formula = 'dur ~ spikes + (spikes-1|unitid:seqid)';
mdl_data_singleunit_gap = fitlme(data_singleunit_gap,formula)

load('dur_correlation_analysis1.mat');
data_singleunit_dur = data(data.unittype<=0.01 & data.activity>=6 & data.corrpval<=0.05,:);
data_singleunit_dur.gap_or_dur = repmat(-1,size(data_singleunit_dur,1),1);
formula = 'dur ~ spikes + (spikes-1|unitid:seqid)';
mdl_data_singleunit_dur = fitlme(data_singleunit_dur,formula)

data_singleunit = [data_singleunit_gap; data_singleunit_dur];
formula = 'dur ~ spikes:gap_or_dur + spikes +(spikes:gap_or_dur-1|unitid) + (spikes-1|unitid:seqid)'
mdl_data_singleunit = fitlme(data_singleunit,formula)


%% distribution of sample sizes (gaps vs syllables)
load('gap_correlation_analysis1a.mat');
corrmat_gap = corrmat;
clearvars -except corrmat_gap 
load('dur_correlation_analysis1a.mat');
corrmat_dur = corrmat;
clearvars -except corrmat_gap corrmat_dur  
activitythresh = 6;
idgap = find(corrmat_gap(:,6)<=0.01 & corrmat_gap(:,4)>=activitythresh);
iddur = find(corrmat_dur(:,6)<=0.01 & corrmat_dur(:,4)>=activitythresh);
gapsampsize = corrmat_gap(idgap,7);
syllsampsize = corrmat_dur(iddur,7);
maxsampsize = max([gapsampsize;syllsampsize]);
figure;hold on;
[n b] = hist(gapsampsize,[25:10:maxsampsize+5]);
stairs(b,n/sum(n),'b','linewidth',2);hold on;
[n b] = hist(syllsampsize,[25:10:maxsampsize+5]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
xlabel('sample size');ylabel('counts');
legend({'gaps','sylls'});
y = get(gca,'ylim');
plot(median(gapsampsize),y(1),'b^');hold on;
plot(median(syllsampsize),y(1),'r^');hold on;
p = ranksum(gapsampsize,syllsampsize);
text(0,1,{['p=',num2str(p)]},'units','normalized');
set(gca,'fontweight','bold');title('single units');

idgap = find(corrmat_gap(:,6)>0.01 & corrmat_gap(:,4)>=activitythresh);
iddur = find(corrmat_dur(:,6)>0.01 & corrmat_dur(:,4)>=activitythresh);
gapsampsize = corrmat_gap(idgap,7);
syllsampsize = corrmat_dur(iddur,7);
maxsampsize = max([gapsampsize;syllsampsize]);
figure;hold on;
[n b] = hist(gapsampsize,[25:10:maxsampsize+5]);
stairs(b,n/sum(n),'b','linewidth',2);hold on;
[n b] = hist(syllsampsize,[25:10:maxsampsize+5]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
xlabel('sample size');ylabel('counts');
legend({'gaps','sylls'});
y = get(gca,'ylim');
plot(median(gapsampsize),y(1),'b^');hold on;
plot(median(syllsampsize),y(1),'r^');hold on;
p = ranksum(gapsampsize,syllsampsize);
text(0,1,{['p=',num2str(p)]},'units','normalized');
set(gca,'fontweight','bold');title('multi units');

%% for cases in which burst happens for gap as well as for syllable premotor win
%not enough samples
bothind = find(corrmat(singleiind,12)>=-40);
corrmat_both = corrmat(singleiind(bothind),:);
sigcorr_gap1 = find(corrmat_both(:,2)<=0.05);
sigcorr_dur2 = find(corrmat_both(:,11)<=0.05);
negcorr_gap1 = find(corrmat_both(:,2)<=0.05 & corrmat_both(:,1)<0);
negcorr_dur2 = find(corrmat_both(:,11)<=0.05 & corrmat_both(:,10)<0);
poscorr_gap1 = find(corrmat_both(:,2)<=0.05 & corrmat_both(:,1)>0);
poscorr_dur2 = find(corrmat_both(:,11)<=0.05 & corrmat_both(:,10)>0);
numcases_both = length(corrmat_both);

%compare distribution of corrs for gap and syll
[n b] = hist(corrmat_both(:,1),[-1:0.1:1]);
figure;hold on;
stairs(b,n/sum(n),'k','linewidth',2);hold on
[n b] = hist(corrmat_both(:,10),[-1:0.1:1]);
stairs(b,n/sum(n),'r','linewidth',2);
legend('gap','next syllable');
xlabel('correlation');ylabel('probability');
[h p] = kstest2(corrmat_both(:,1),corrmat_both(:,10))

%perm test 
pooledsamp = [corrmat_both(:,1:2);corrmat_both(:,10:11)];
ntrials = 1000;
diffsig = [];diffneg = [];diffpos=[];mndiff = [];
for i = 1:ntrials
    randpool = pooledsamp(randperm(length(pooledsamp),length(pooledsamp)),:);
    gapsamp = randpool(1:length(randpool)/2,:);
    dursamp = randpool(length(randpool)/2+1:end,:);
    sigcorr_gapsamp = length(find(gapsamp(:,2)<=0.05));
    negcorr_gapsamp = length(find(gapsamp(:,2)<=0.05 & gapsamp(:,1)<0));
    poscorr_gapsamp = length(find(gapsamp(:,2)<=0.05 & gapsamp(:,1)>0));
    sigcorr_dursamp = length(find(dursamp(:,2)<=0.05));
    negcorr_dursamp = length(find(dursamp(:,2)<=0.05 & dursamp(:,1)<0));
    poscorr_dursamp = length(find(dursamp(:,2)<=0.05 & dursamp(:,1)>0));
    diffsig = [diffsig; ((sigcorr_gapsamp/length(gapsamp))-(sigcorr_dursamp/length(dursamp)))];
    diffneg = [diffneg; ((negcorr_gapsamp/length(gapsamp))-(negcorr_dursamp/length(dursamp)))];
    diffpos = [diffpos; ((poscorr_gapsamp/length(gapsamp))-(poscorr_dursamp/length(dursamp)))];
    mndiff = [mndiff; mean(gapsamp(:,1))-mean(dursamp(:,1))];
end
p_diffsig = length(find(abs(diffsig)>=abs((length(sigcorr_gap1)/numcases_both)-(length(sigcorr_dur2)/numcases_both))))/ntrials;
p_diffneg = length(find(abs(diffneg)>=abs((length(negcorr_gap1)/numcases_both)-(length(negcorr_dur2)/numcases_both))))/ntrials;
p_diffpos = length(find(abs(diffpos)>=abs((length(poscorr_gap1)/numcases_both)-(length(poscorr_dur2)/numcases_both))))/ntrials;
text(0,1,{['p(abs(siggap-sigdur))=',num2str(p_diffsig)];...
    ['p(abs(neggap-negdur))=',num2str(p_diffneg)];...
    ['p(abs(posgap-posdur))=',num2str(p_diffpos)];...
    ['p(ks)=',num2str(p)]},'units','normalized','verticalalignment','top');

%% for cases in which burst happens for syll as well as for gap premotor win
%not enough samples
bothind = find(corrmat(singleiind,10)>=-40);
corrmat_both = corrmat(singleiind(bothind),:);
sigcorr_dur1 = find(corrmat_both(:,2)<=0.05);
sigcorr_gap2 = find(corrmat_both(:,9)<=0.05);
negcorr_dur1 = find(corrmat_both(:,2)<=0.05 & corrmat_both(:,1)<0);
negcorr_gap2 = find(corrmat_both(:,9)<=0.05 & corrmat_both(:,8)<0);
poscorr_dur1 = find(corrmat_both(:,2)<=0.05 & corrmat_both(:,1)>0);
poscorr_gap2 = find(corrmat_both(:,9)<=0.05 & corrmat_both(:,8)>0);
numcases_both = length(corrmat_both);

%% for each unit, look at paired correlations to syllables vs gaps at different song positions
load('gap_correlation_analysis1.mat');
activitythresh = 6;
singleiind = find(corrmat(:,6)<=0.01 & corrmat(:,4) >= activitythresh);
unitid = case_name(1:2:end);unitid=unitid(singleiind);
seqid = case_name(2:2:end);seqid = seqid(singleiind);
[ic,~,ia] = unique(unitid);
gaps = cell(length(ic),1);
for i = 1:length(ic)
    gaps{i} = corrmat(singleiind(ia==i),1:2);
end
load('dur_correlation_analysis1.mat');
activitythresh = 6;
singleiind = find(corrmat(:,6)<=0.01 & corrmat(:,4) >= activitythresh);
unitid = case_name(1:2:end);unitid=unitid(singleiind);
seqid = case_name(2:2:end);seqid = seqid(singleiind);
durs = {};
for i = 1:length(ic)
    ind = find(cellfun(@(x) strcmp(x,ic{i}),unitid));
    durs = [durs; corrmat(singleiind(ind),1:2)];
end
gap_pooled = cell2mat(gaps);
durs_pooled = cell2mat(durs);
figure;hold on;
[n b] = hist(gap_pooled(:,1),[-1:0.1:1]);
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(durs_pooled(:,1),[-1:0.1:1]);
stairs(b,n/sum(n),'r');
[h p] = kstest2(gap_pooled(:,1),durs_pooled(:,1));

sigcorr_gap = length(find(gap_pooled(:,2)<=0.05))/size(gap_pooled,1);
negcorr_gap = length(find(gap_pooled(:,2)<=0.05 & gap_pooled(:,1)<0))/size(gap_pooled,1);
poscorr_gap = length(find(gap_pooled(:,2)<=0.05 & gap_pooled(:,1)>0))/size(gap_pooled,1);
sigcorr_dur = length(find(durs_pooled(:,2)<=0.05))/size(durs_pooled,1);
negcorr_dur = length(find(durs_pooled(:,2)<=0.05 & durs_pooled(:,1)<0))/size(durs_pooled,1);
poscorr_dur = length(find(durs_pooled(:,2)<=0.05 & durs_pooled(:,1)>0))/size(durs_pooled,1);

mndiff = [];sig=[];neg=[];pos=[];
for n = 1:1000
    permgap = [];permdur = [];
    for i = 1:length(gaps)
        gapsamp = size(gaps{i},1);
        dursamp = size(durs{i},1);
        pooled = [gaps{i};durs{i}];
        randpool = pooled(randperm(gapsamp+dursamp,gapsamp+dursamp),:);
        randgapsamp = randpool(1:gapsamp,:);
        randdursamp = randpool(gapsamp+1:end,:);
        permgap = [permgap;randgapsamp];
        permdur = [permdur;randdursamp];
    end
    mndiff = [mndiff; median(permgap)-median(permdur)];
    sig = [sig; sum(permgap(:,2)<=0.05)/size(permgap,1)-sum(permdur(:,2)<=0.05)/size(permdur,1)];
    neg = [neg; sum(permgap(:,2)<=0.05 & permgap(:,1)<0)/size(permgap,1)-sum(permdur(:,2)<=0.05 & permdur(:,1)<0)/size(permdur,1)];
    pos = [pos; sum(permgap(:,2)<=0.05 & permgap(:,1)>0)/size(permgap,1)-sum(permdur(:,2)<=0.05 & permdur(:,1)>0)/size(permdur,1)];
end
p_sigdiff = length(find(abs(sig)>=abs(sigcorr_gap-sigcorr_dur)))/1000
p_negdiff = length(find(abs(neg)>=abs(negcorr_gap-negcorr_dur)))/1000
p_posdiff = length(find(abs(pos)>=abs(poscorr_gap-poscorr_dur)))/1000

%% comparing sample sizes for single units that are negative vs positively correlated
negsampsize = corrmat(singleiind(corrmat(singleiind,1)<0),7);
possampsize = corrmat(singleiind(corrmat(singleiind,1)>0),7);
maxsize = max([negsampsize;possampsize]);
figure;hold on;
[n b] = hist(negsampsize,[25:10:maxsize+5]);
stairs(b,n/sum(n),'b','linewidth',2);hold on;
[n b] = hist(possampsize,[25:10:maxsize+5]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
xlabel('sample size');ylabel('counts');
legend({'negative','positive'});
y = get(gca,'ylim');
plot(median(negsampsize),y(1),'b^');hold on;
plot(median(possampsize),y(1),'r^');hold on;
p = ranksum(negsampsize,possampsize);
text(0,1,{['p=',num2str(p)]},'units','normalized');
set(gca,'fontweight','bold');title('single units');

negsampsize = corrmat(multiind(corrmat(multiind,1)<0),7);
possampsize = corrmat(multiind(corrmat(multiind,1)>0),7);
maxsize = max([negsampsize;possampsize]);
figure;hold on;
[n b] = hist(negsampsize,[25:10:maxsize+5]);
stairs(b,n/sum(n),'b','linewidth',2);hold on;
[n b] = hist(possampsize,[25:10:maxsize+5]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
xlabel('sample size');ylabel('counts');
legend({'negative','positive'});
y = get(gca,'ylim');
plot(median(negsampsize),y(1),'b^');hold on;
plot(median(possampsize),y(1),'r^');hold on;
p = ranksum(negsampsize,possampsize);
text(0,1,{['p=',num2str(p)]},'units','normalized');
set(gca,'fontweight','bold');title('multi units');

%% %% power analysis for negative vs positively correlated single units
sampsize = [25:5:500];
corrvals = regressionpower(0.05,0.2,sampsize);
figure;
plot(corrmat(singleiind(corrmat(singleiind,1)<0),7),...
    abs(corrmat(singleiind(corrmat(singleiind,1)<0),1)),'ob');hold on;
plot(corrmat(singleiind(corrmat(singleiind,1)>0),7),...
    abs(corrmat(singleiind(corrmat(singleiind,1)>0),1)),'or');hold on;
plot(corrmat(negcorr_su,7),abs(corrmat(negcorr_su,1)),'b.','markersize',10);hold on;
plot(corrmat(poscorr_su,7),abs(corrmat(poscorr_su,1)),'r.','markersize',10);hold on;
plot(sampsize,corrvals,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
xlabel('sample size');ylabel('correlation');
legend({'negative','positive'});
set(gca,'fontweight','bold');

%% distribution of burst windows relative to target onset
burstwidth = corrmat(singleiind,5);
latency = corrmat(singleiind,13);
windows_st = floor(latency - burstwidth/2);
windows_ed = ceil(latency + burstwidth/2);
mintm = min(windows_st);
maxtm = max(windows_ed);
windows = cell2mat(arrayfun(@(x,y) [x:y]',windows_st,windows_ed,'un',0));
figure;
[n b] = hist(windows,[mintm:1:maxtm]);stairs(b,n/sum(n),'k');hold on;
xlabel('ms');ylabel('probability');
set(gca,'fontweight','bold');

burstwidth = corrmat(multiind,5);
latency = corrmat(multiind,13);
windows_st = floor(latency - burstwidth/2);
windows_ed = ceil(latency + burstwidth/2);
mintm = min(windows_st);
maxtm = max(windows_ed);
windows = cell2mat(arrayfun(@(x,y) [x:y]',windows_st,windows_ed,'un',0));
[n b] = hist(windows,[mintm:1:maxtm]);stairs(b,n/sum(n),'r');hold on;
xlabel('ms');ylabel('probability');title('burst windows');
legend({'single units','multi units'});
set(gca,'fontweight','bold');
    
%% lagged trial correlation
singletrialcorr = trialcorr;
[maxlen id] = max(cellfun(@(x) size(x,1),singletrialcorr));
lag = singletrialcorr{id}(:,2);
singletrialcorr = cellfun(@(x) [NaN(x(1,2)-lag(1),size(x,2));x;NaN(lag(end)-x(end,2),size(x,2))],...
    singletrialcorr,'un',0);

figure;hold on;
for i = 1:length(singletrialcorr)
   plot(singletrialcorr{i}(:,2),abs(singletrialcorr{i}(:,1)),'color',[1 0.8 0.8]);hold on;
   %  plot(singletrialcorr{i}(:,2),abs(singletrialcorr{i}(:,3:end)),'b');hold on;
end

singletrialcorr_sum = cell2mat(cellfun(@(x) abs(x(:,1)'),singletrialcorr,'un',0));
patch([lag' fliplr(lag')],[nanmean(singletrialcorr_sum)+nanstderr(singletrialcorr_sum) ...
    fliplr(nanmean(singletrialcorr_sum)-nanstderr(singletrialcorr_sum))],'r',...
    'edgecolor','none','facealpha',0.7);hold on;

singletrialcorrshuff = cell2mat(cellfun(@(x) abs(x(:,3:end)'),singletrialcorr,'un',0));
hi = NaN(1,length(lag));lo = NaN(1,length(lag));
for i = 1:size(singletrialcorrshuff,2)
    id = find(~isnan(singletrialcorrshuff(:,i)));
    x = sort(singletrialcorrshuff(id,i));
    hi(i) = x(fix(length(x)*0.95));
    lo(i) = x(fix(length(x)*0.05));
end
patch([lag' fliplr(lag')],[lo fliplr(hi)],[0.2 0.2 0.2],...
    'edgecolor','none','facealpha',0.7);hold on;
xlabel('trial lag');
ylabel('abs correlation');
title('single units')
set(gca,'fontweight','bold');xlim([-100 100]);


