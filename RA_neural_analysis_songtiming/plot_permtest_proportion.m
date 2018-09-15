function plot_permtest_proportion(corrtable,activitythresh,ntrials,aph);
%corrtable is from function RA_correlate_gapdur
%plot the distribution of proportion of significant cases for shuffled vs
%observed data

%indices for cases that are significantly negatively or positively
%correlated, and all cases that meet activity threshold
negcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'<0);
poscorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'>0);
sigcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05);
activecases = find(corrtable.pkFR>=activitythresh);

numcases = length(activecases); %total number of cases
numsignificant = length(find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05)); %total number of significant cases

%correlation vals and pvals for correlations for shuffled data (each case
%has ntrials number of shuffles) 
shuffcorr = [corrtable(activecases,:).shuffle{:,3}];
shuffpval = [corrtable(activecases,:).shuffle{:,4}];

%counting number of significant cases in shuffled data and determining
%cutoff at significance level
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

%counting the difference between the percentage of significant neg vs pos
%cases in shuffled data
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
randdiffprop_sorted = sort(randdiffprop);
randdiffprop_lo = randdiffprop_sorted(floor(aph*ntrials/2));
randdiffprop_hi = randdiffprop_sorted(ceil(ntrials-(aph*ntrials/2)));

figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI([corrtable(activecases,:).corrs{:,4}]'<=0.05);
plot(mn,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'color',[0.5 0.5 0.5],'linewidth',4)
title('shuffled vs empirical');
xlabel('proportion of significant correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI([corrtable(activecases,:).corrs{:,4}]'<=0.05 & ...
    [corrtable(activecases,:).corrs{:,3}]'<0);
plot(mn,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical');
xlabel('proportion of significantly negative correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.01:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI([corrtable(activecases,:).corrs{:,4}]'<=0.05 & ...
    [corrtable(activecases,:).corrs{:,3}]'>0);
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical');
xlabel('proportion of significantly positive correlations');ylabel('probability');
set(gca,'fontweight','bold');