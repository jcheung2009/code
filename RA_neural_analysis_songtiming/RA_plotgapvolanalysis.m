%params and input
load('gapvolmultipleregression.mat');
activitythresh = 6;%zscore from shuffled
overlap = 0.02; 

active = find(corrmat(:,8)>=activitythresh);

%indices for single units based on pct_error<=0.01 and above activitythresh that have significant
%correlations with vol1
numcases1 = length(find(corrmat(:,8) >= activitythresh));
numsignificant1 = length(find(corrmat(:,8) >= activitythresh & corrmat(:,2)<=0.05));
negcorr1 = find(corrmat(:,8) >= activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)<0);
poscorr1 = find(corrmat(:,8) >= activitythresh & corrmat(:,2)<= 0.05 & corrmat(:,1)>0);
sigcorr1 = find(corrmat(:,8) >= activitythresh & corrmat(:,2)<= 0.05);

%indices for single units based on pct_error<=0.01 and above activitythresh that have significant
%correlations with vol2
numcases2 = length(find(corrmat(:,8) >= activitythresh));
numsignificant2 = length(find(corrmat(:,8) >= activitythresh & corrmat(:,4)<=0.05));
negcorr2 = find(corrmat(:,8) >= activitythresh & corrmat(:,4)<= 0.05 & corrmat(:,3)<0);
poscorr2 = find(corrmat(:,8) >= activitythresh & corrmat(:,4)<= 0.05 & corrmat(:,3)>0);
sigcorr2 = find(corrmat(:,8) >= activitythresh & corrmat(:,4)<= 0.05);

%indices for single units based on pct_error<=0.01 and above activitythresh that have significant
%correlations with dur
numcases3 = length(find(corrmat(:,8) >= activitythresh));
numsignificant3 = length(find(corrmat(:,8) >= activitythresh & corrmat(:,6)<=0.05));
negcorr3 = find(corrmat(:,8) >= activitythresh & corrmat(:,6)<= 0.05 & corrmat(:,5)<0);
poscorr3 = find(corrmat(:,8) >= activitythresh & corrmat(:,6)<= 0.05 & corrmat(:,5)>0);
sigcorr3 = find(corrmat(:,8) >= activitythresh & corrmat(:,6)<= 0.05);


%% proportion of significant correlations in shuffled data for vol1
aph = 0.01;ntrials=1000;
shuffcorr = corrmat_shuff(:,1:6:end);
shuffpval = corrmat_shuff(:,4:6:end);
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
[n b] = hist(shuffcorr(:),[min(shuffcorr(:)):1:max(shuffcorr(:))]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(active,1),[min(shuffcorr(:)):1:max(shuffcorr(:))]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(active,1)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('beta');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(active,1),shuffcorr(:));
[h p2] = ttest2(corrmat(active,1),shuffcorr(:));
[h p3] = kstest2(corrmat(active,1),shuffcorr(:));
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
'verticalalignment','top');
title('volume1');

%% proportion of significant correlations in shuffled data for vol2
aph = 0.01;ntrials=1000;
shuffcorr = corrmat_shuff(:,2:6:end);
shuffpval = corrmat_shuff(:,5:6:end);
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
[n b] = hist(shuffcorr(:),[min(shuffcorr(:)):1:max(shuffcorr(:))]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(active,3),[min(shuffcorr(:)):1:max(shuffcorr(:))]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(active,3)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('beta');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(active,3),shuffcorr(:));
[h p2] = ttest2(corrmat(active,3),shuffcorr(:));
[h p3] = kstest2(corrmat(active,3),shuffcorr(:));
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
'verticalalignment','top');
title('volume2');

%% proportion of significant correlations in shuffled data for dur
aph = 0.01;ntrials=1000;
shuffcorr = corrmat_shuff(:,3:6:end);
shuffpval = corrmat_shuff(:,6:6:end);
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
[n b] = hist(shuffcorr(:),[-20:1:20]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(corrmat(active,5),[-20:1:20]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean(corrmat(active,5)),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('beta');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2(corrmat(active,5),shuffcorr(:));
[h p2] = ttest2(corrmat(active,5),shuffcorr(:));
[h p3] = kstest2(corrmat(active,5),shuffcorr(:));
p4 = length(find(randdiffprop>=abs((length(negcorr3)/numcases3)-(length(poscorr3)/numcases3))))/ntrials;
p5 = length(find(randpropsignificant>=length(sigcorr3)/numcases3))/ntrials;
p6 = length(find(randpropsignificantposcorr>=length(poscorr3)/numcases3))/ntrials;
p7 = length(find(randpropsignificantnegcorr>=length(negcorr3)/numcases3))/ntrials;
text(0,1,{['total active cases:',num2str(numcases3)];...
['proportion significant cases:',num2str(numsignificant3/numcases3)];...
['proportion significantly negative:',num2str(length(negcorr3)/numcases3)];...
['proportion significantly positive:',num2str(length(poscorr3)/numcases3)];...
['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(ks)=',num2str(p3)];...
['p(sig)=',num2str(p5)];['p(neg)=',num2str(p7)];['p(pos)=',num2str(p6)];...
['p(neg-pos)=',num2str(p4)]},'units','normalized',...
'verticalalignment','top');
title('dur');

%% multilevel model
data_active = data(data.activity>=6,:);
formula = 'spikes ~ volume1 + volume2 + dur + (1|unitid:seqid) + (volume1-1|unitid:seqid) + (volume2-1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl = fitlme(data_active,formula)

data_active = data(data.activity>=6,:);
formula = 'spikes ~ dur + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl = fitlme(data_active,formula)

data_active = data(data.activity>=6,:);
formula = 'spikes ~ volume1 + (1|unitid:seqid) + (volume1-1|unitid:seqid)';
mdl = fitlme(data_active,formula)

data_active = data(data.activity>=6,:);
formula = 'spikes ~ volume2 + (1|unitid:seqid) + (volume2-1|unitid:seqid)';
mdl = fitlme(data_active,formula)