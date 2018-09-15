function [activecases,sigcorr,negcorr,poscorr] = plot_distr_corrs(corrtable,activitythresh,ntrials,aph);
%corrtable is from function RA_correlate_gapdur
%plot the correlation values for each regression between neural activity
%and behavior for every case
%also plots distr of correlation values from shuffled data


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

%distribution of correlations for observed vs shuffled data
figure;hold on;
subplot(1,3,1);
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist([corrtable(activecases,:).corrs{:,3}],[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');hold on;
plot(mean([corrtable(activecases,:).corrs{:,3}]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('partial correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([corrtable(activecases,:).corrs{:,3}],shuffcorr(:));
[h p2] = ttest2([corrtable(activecases,:).corrs{:,3}],shuffcorr(:));
[h p3] = kstest2([corrtable(activecases,:).corrs{:,3}],shuffcorr(:));
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

%cumulative distribution of correlations for observed vs shuffled data
subplot(1,3,2)
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
plot(b,cumsum(n/sum(n)),'k','linewidth',2);hold on;
[n b] = hist([corrtable(activecases,:).corrs{:,3}],[-1:0.05:1]);
plot(b,cumsum(n/sum(n)),'r','linewidth',2);hold on;
xlabel('correlation');ylabel('cumulative probability');
set(gca,'fontweight','bold');

%bar plots for % cases with neg vs pos corrs, and threshold for
%significance from permutation test
subplot(1,3,3)
bar(1,numsignificant/numcases,'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(3,length(negcorr)/numcases,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(5,length(poscorr)/numcases,'facecolor','none','edgecolor','b','linewidth',2);hold on;
plot([0 2],[randpropsignificant_hi randpropsignificant_hi],'k','linewidth',2);hold on;
plot([2 4],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'k','linewidth',2);hold on;
plot([4 6],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'k','linewidth',2);hold on;
set(gca,'XTick',[1,3,5],'XTickLabel',{'all','neg','pos'})
ylabel('proportion of cases with significant correlations')