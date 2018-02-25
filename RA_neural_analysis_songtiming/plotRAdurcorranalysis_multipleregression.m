%plotting analysis of frequency of significant correlations, individual
%cases were multiple regression with target dur, volume, and adjacent durs

%% parameters and input
load('dur_multicorrelation_analysis_ifr.mat');
activitythresh = 50;%zscore from shuffled

ff = load_batchf('multiunits_gt_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable20.unitid))];
end
corrtable = corrtable20(id,:);

ff = load_batchf('multiunits_gt_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),dattable20.unitid))];
end
dattable = dattable20(id,:);

%% BETAS: threshold by FR 
negcorr = find(corrtable.pkFR>=activitythresh & ...
    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable.corrs(:,1))<0);
poscorr = find(corrtable.pkFR>=activitythresh & ...
    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable.corrs(:,1))>0);
sigcorr = find(corrtable.pkFR>=activitythresh & ...
    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05);
activecases = find(corrtable.pkFR>=activitythresh);

numcases = length(activecases);
numsignificant = length(find(corrtable.pkFR>=activitythresh & ...
    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05));

aph = 0.01;ntrials=1000;
shuffcorr = cell2mat(cellfun(@(x) x(:,1),corrtable(activecases,:).shuffle(:,1),'un',0)');
shuffpval = cell2mat(cellfun(@(x) x(:,1),corrtable(activecases,:).shuffle(:,2),'un',0)');

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
[n b] = hist(shuffcorr(:),[-100:2:100]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist([cellfun(@(x) x(1),corrtable(activecases,:).corrs(:,1))],[-100:2:100]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean([cellfun(@(x) x(1),corrtable(activecases,:).corrs(:,1))]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('beta');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([cellfun(@(x) x(1),corrtable(activecases,:).corrs(:,1))],shuffcorr(:));
[h p2] = ttest2([cellfun(@(x) x(1),corrtable(activecases,:).corrs(:,1))],shuffcorr(:));
[h p3] = kstest2([cellfun(@(x) x(1),corrtable(activecases,:).corrs(:,1))],shuffcorr(:));
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

%% PARTIAL CORR: threshold by FR
negcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'<0);
poscorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'>0);
sigcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05);
activecases = find(corrtable.pkFR>=activitythresh);

numcases = length(activecases);
numsignificant = length(find(corrtable.pkFR>=activitythresh & ...
    [corrtable.corrs{:,4}]'<=0.05));

aph = 0.01;ntrials=1000;
shuffcorr = [corrtable(activecases,:).shuffle{:,3}];
shuffpval = [corrtable(activecases,:).shuffle{:,4}];

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
[n b] = hist([corrtable(activecases,:).corrs{:,3}],[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
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

