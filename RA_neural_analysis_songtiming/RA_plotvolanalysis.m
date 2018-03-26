%params and input
load('vol_correlation1.mat');
activitythresh = 6;%zscore from shuffled
overlap = 0.02; 

%indices for single units based on pct_error<=0.01 and above activitythresh that have significant
%correlations with vol1
numcases1 = length(find(corrmat(:,6) >= activitythresh));
numsignificant1 = length(find(corrmat(:,2)<=0.05 & corrmat(:,6) >= activitythresh));
negcorr1 = find(corrmat(:,6) >= activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)<0);
poscorr1 = find(corrmat(:,6) >= activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)>0);
sigcorr1 = find(corrmat(:,6) >= activitythresh & corrmat(:,2)<= 0.05);

%indices for single units based on pct_error<=0.01 and above activitythresh that have significant
%correlations with vol2
numcases2 = length(find(corrmat(:,6) >= activitythresh));
numsignificant2 = length(find(corrmat(:,4)<=0.05 & corrmat(:,6) >= activitythresh));
negcorr2 = find(corrmat(:,6) >= activitythresh & corrmat(:,4)<= 0.05 & corrmat(:,3)<0);
poscorr2 = find(corrmat(:,6) >= activitythresh & corrmat(:,4)<= 0.05 & corrmat(:,3)>0);
sigcorr2 = find(corrmat(:,6) >= activitythresh & corrmat(:,4)<= 0.05);


%% proportion of significant correlations in shuffled data for vol1
aph = 0.01;ntrials=1000;
shuffcorr = corrmat_shuff(:,1:4:end);
shuffpval = corrmat_shuff(:,2:4:end);
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

figure;hold on;
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(:,1),[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(:,1)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(:,1),shuffcorr(:));
[h p2] = ttest2(corrmat(:,1),shuffcorr(:));
[h p3] = kstest2(corrmat(:,1),shuffcorr(:));
p4 = length(find(randdiffprop>=abs((length(negcorr1)/numcases1)-(length(poscorr1)/numcases1))))/ntrials;
p5 = length(find(randpropsignificant>=length(sigcorr1)/numcases1))/ntrials;
p6 = length(find(randpropsignificantposcorr>=length(poscorr1)/numcases1))/ntrials;
p7 = length(find(randpropsignificantnegcorr>=length(negcorr1)/numcases1))/ntrials;
text(0,1,{['total active cases:',num2str(numcases1)];...
['proportion significant cases:',num2str(numsignificant1/numcases1)];...
['proportion significantly negative:',num2str(length(negcorr1)/numcases1)];...
['proportion significantly positive:',num2str(length(poscorr1)/numcases1)];...
['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(ks)=',num2str(p3)];...
['p(sig)=',num2str(p5)];['p(neg)=',num2str(p7)];['p(pos)=',num2str(p6)];...
['p(neg-pos)=',num2str(p4)]},'units','normalized',...
'verticalalignment','top');title('volume1');

%% proportion of significant correlations in shuffled data for vol2
aph = 0.01;ntrials=1000;
shuffcorr = corrmat_shuff(:,3:4:end);
shuffpval = corrmat_shuff(:,4:4:end);
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

figure;hold on;
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(:,3),[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(:,3)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(:,3),shuffcorr(:));
[h p2] = ttest2(corrmat(:,3),shuffcorr(:));
[h p3] = kstest2(corrmat(:,3),shuffcorr(:));
p4 = length(find(randdiffprop>=abs((length(negcorr2)/numcases2)-(length(poscorr2)/numcases2))))/ntrials;
p5 = length(find(randpropsignificant>=length(sigcorr2)/numcases2))/ntrials;
p6 = length(find(randpropsignificantposcorr>=length(poscorr2)/numcases2))/ntrials;
p7 = length(find(randpropsignificantnegcorr>=length(negcorr2)/numcases2))/ntrials;
text(0,1,{['total active cases:',num2str(numcases2)];...
['proportion significant cases:',num2str(numsignificant2/numcases2)];...
['proportion significantly negative:',num2str(length(negcorr2)/numcases2)];...
['proportion significantly positive:',num2str(length(poscorr2)/numcases2)];...
['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(ks)=',num2str(p3)];...
['p(sig)=',num2str(p5)];['p(neg)=',num2str(p7)];['p(pos)=',num2str(p6)];...
['p(neg-pos)=',num2str(p4)]},'units','normalized',...
'verticalalignment','top');title('volume2');