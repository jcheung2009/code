%plotting analysis of frequency of significant correlations, individual
%cases were multiple regression with target dur, volume, and adjacent durs

%% parameters and input
load('dur_multicorrelation_analysis_fr.mat');
activitythresh = 50;%zscore from shuffled

ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);

% ff = load_batchf('multiunits_gt_2pcterr');
% id = [];
% for i = 1:length(ff)
%     id = [id;find(cellfun(@(x) contains(ff(i).name,x),dattable20.unitid))];
% end
% dattable = dattable20(id,:);

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

% randpropsignificant = NaN(ntrials,1);
% randpropsignificantnegcorr = NaN(ntrials,1);
% randpropsignificantposcorr = NaN(ntrials,1);
% for nrep = 1:ntrials
%     birdgroups = unique(corrtable.birdid);
%     cls = randsample(birdgroups,length(birdgroups),'true');
%     sub = arrayfun(@(x) corrtable(find(strcmp(corrtable.birdid,x)),:),cls,'un',0);
%     sub = vertcat(sub{:});
%     unitgroups = unique(sub.unitid);
%     cls = randsample(unitgroups,length(unitgroups),'true');
%     sub = arrayfun(@(x) sub(find(strcmp(sub.unitid,x)),:),cls,'un',0);
%     sub = vertcat(sub{:});
%     seqgroups = unique(sub(:,{'unitid','seqid'}),'rows');
%     cls = seqgroups{randsample(size(seqgroups,1),size(seqgroups,1),'true'),:};
%     sub = arrayfun(@(x,y) sub(find(strcmp(sub.unitid,x) & strcmp(sub.seqid,y)),:),cls(:,1),cls(:,2),'un',0);
%     sub = vertcat(sub{:});
%     shufftrialid = randsample(ntrials,size(sub,1),'true');
%     tempcorr = [sub.shuffle{:,3}];
%     temppval = [sub.shuffle{:,4}];
%     ind = sub2ind(size(tempcorr),shufftrialid',1:size(tempcorr,2));
%     corr = tempcorr(ind);
%     pval = temppval(ind);
%     randpropsignificant(nrep) = length(find(pval<=0.05))/length(pval);
%     randpropsignificantnegcorr(nrep) = sum((pval<=0.05).*(corr<0))/length(corr);
%     randpropsignificantposcorr(nrep) = sum((pval<=0.05).*(corr>0))/length(corr);
% end
%     
% randpropsignificant_sorted = sort(randpropsignificant);
% randpropsignificant_lo = randpropsignificant_sorted(floor(aph*ntrials/2));
% randpropsignificant_hi = randpropsignificant_sorted(ceil(ntrials-(aph*ntrials/2)));
% randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
% randpropsignificantnegcorr_lo = randpropsignificantnegcorr_sorted(floor(aph*ntrials/2));
% randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
% randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
% randpropsignificantposcorr_lo = randpropsignificantposcorr_sorted(floor(aph*ntrials/2));
% randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));  
% randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);





%____________________________-

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
randdiffprop_sorted = sort(randdiffprop);
randdiffprop_lo = randdiffprop_sorted(floor(aph*ntrials/2));
randdiffprop_hi = randdiffprop_sorted(ceil(ntrials-(aph*ntrials/2)));
%________________________________________
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

figure;hold on;
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
plot(b,cumsum(n/sum(n)),'k','linewidth',2);hold on;
[n b] = hist([corrtable(activecases,:).corrs{:,3}],[-1:0.05:1]);
plot(b,cumsum(n/sum(n)),'r','linewidth',2);hold on;
xlabel('correlation');ylabel('cumulative probability');
set(gca,'fontweight','bold');

figure;hold on;
bar(2,numsignificant/numcases,'facecolor','none','edgecolor','k','linewidth',2);hold on;
bar(5,length(negcorr)/numcases,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(8,length(poscorr)/numcases,'facecolor','none','edgecolor','b','linewidth',2);hold on;
plot([0 3],[0.1032 0.1032],'k','linewidth',2);hold on;
plot([3 6],[0.0635 0.0635],'k','linewidth',2);hold on;
plot([6 9],[0.0714 0.0714],'k','linewidth',2);hold on;
set(gca,'XTick',[1,2,4,5,7,8],'XTickLabel',{'gap','syllable'})
ylabel('proportion of cases with significant correlations')

%% distribution of proportion of significant correlations for empirical vs shuffled
figure;subplot(1,4,1);hold on;
[n b] = hist(randpropsignificant,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
mn = sum([corrtable.corrs{:,4}]'<=0.05)/numcases;
plot(mn,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
title('shuffled vs empirical');
xlabel('proportion of significant correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,4,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
mn = sum([corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'<0)/numcases;
plot(mn,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
title('shuffled vs empirical');
xlabel('proportion of significantly negative correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,4,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.01:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
mn = sum([corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'>0)/numcases;
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
title('shuffled vs empirical');
xlabel('proportion of significantly positive correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,4,4);hold on;
[n b] = hist(randdiffprop,[0:0.01:0.08]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randdiffprop_lo,y(1),'r^','markersize',8);hold on;
plot(randdiffprop_hi,y(1),'r^','markersize',8);hold on;
mn = abs(sum([corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'<0)-...
    sum([corrtable.corrs{:,4}]'<=0.05 & [corrtable.corrs{:,3}]'>0))/numcases;
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
title('shuffled vs empirical');
xlabel('proportion of significantly positive correlations');ylabel('probability');
set(gca,'fontweight','bold');