%scripts to plot analysis results for gap/syll duration correlation
%multiple regression results controlling for volume of neighboring
%syllables (gap_multicorrelation_analysis_fr.mat,
%dur_multicorrelation_analysis_fr.mat)

%% distribution of correlation values, bar plots of permutation test on 
%proportion of significant correlations for GAPS
load('gap_multicorrelation_analysis_fr.mat');
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);

[activecases,sigcorr,negcorr,poscorr] = plot_distr_corrs(corrtable,activitythresh,1000,0.01);
title('gaps')


%% number of unique active units and birds that went into analysis
disp([num2str(size((corrtable(activecases,{'unitid','seqid'})),1)),...
    ' cases in ',num2str(size(unique(corrtable(activecases,{'unitid'})),1)),...
    ' units in ',num2str(size(unique(corrtable(activecases,...
    {'birdid'})),1)),' birds']);

%% number of unique active units and birds from which significant correlations were found
disp([num2str(size((corrtable(sigcorr,{'unitid','seqid'})),1)),...
    ' cases in ',num2str(size(unique(corrtable(sigcorr,{'unitid'})),1)),...
    ' units in ',num2str(size(unique(corrtable(sigcorr,{'birdid'})),1)),' birds']);

%% distribution of proportion of significant cases (results of perm test)
plot_permtest_proportion(corrtable,50,1000,0.01);

%% distribution of sample sizes for cases that are negative vs positively correlated 
%(regardless of significance)
negsampsize = corrtable([corrtable.corrs{:,3}]'<0,:).ntrials;
possampsize = corrtable([corrtable.corrs{:,3}]'>0,:).ntrials;
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
set(gca,'fontweight','bold');

%% power analysis for regression
sampsize = [25:5:500];
corrvals = regressionpower(0.05,0.2,sampsize);
figure;
plot(corrtable.ntrials,abs([corrtable.corrs{:,3}]),'ok');hold on;
plot(corrtable(sigcorr,:).ntrials,abs([corrtable(sigcorr,:).corrs{:,3}]),'or');hold on;
plot(sampsize,corrvals,'color',[0.5 0.5 0.5],'linewidth',2);hold on;
xlabel('sample size');ylabel('correlation');
set(gca,'fontweight','bold');

%% visualize distribution for each unit
%each row is a unit, circle is instance of a "case" (premotor activity
%before a gap), red (significant negative corr), blue (significant pos
%corr)

[cases,ia,ib] = unique(corrtable(:,{'birdid','unitid'}));
figure;hold on;rowcnt = 1;
for i = 1:max(ib)
    numactive = length(find(ib==i));
    plot(1:numactive,rowcnt,'ok','markersize',10);hold on;
    corrs =cell2mat(corrtable{find(ib==i),'corrs'}(:,3:4));
    nid = find(corrs(:,2)<=0.05 & corrs(:,1)<0);
    pid = find(corrs(:,2)<=0.05 & corrs(:,1)>0);
    if ~isempty(nid)
        plot(nid,rowcnt,'r.','markersize',35);hold on;
    end
    if ~isempty(pid)
        plot(pid,rowcnt,'b.','markersize',35);hold on;
    end
    rowcnt = rowcnt+1;
end

[uniquebirds,~,ib] = unique(cases(:,'birdid'));
ytcks = [];
for i = 1:max(ib)
    id = max(find(ib==i));
    ytcks = [ytcks id];
end
set(gca,'ytick',ytcks,'yticklabels',uniquebirds{:,1});

%% plot correlation at time lags relative to target gap 

shuffcorr_lag = cellfun(@(x) x(:,1:2:end),crosscorr_shuff,'un',0);
shuffpval_lag = cellfun(@(x) x(:,2:2:end),crosscorr_shuff,'un',0);

ind1 = cellfun(@(x) x<0,shuffcorr_lag,'un',0);
ind2 = cellfun(@(x) x<=0.05,shuffpval_lag,'un',0);
propnegsigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
propnegsigshuff = cellfun(@(x) sum(x,2)/size(x,2),propnegsigshuff,'un',0);
propnegsigshuff = cellfun(@(x) sort(x),propnegsigshuff,'un',0);
propnegsigshuffhi = cellfun(@(x) x(ceil(0.995*length(x))),propnegsigshuff,'un',1);
propnegsigshufflo = cellfun(@(x) x(floor(0.005*length(x))),propnegsigshuff,'un',1);

ind1 = cellfun(@(x) x>0,shuffcorr_lag,'un',0);
proppossigshuff = cellfun(@(x,y) x.*y,ind1,ind2,'un',0);
proppossigshuff = cellfun(@(x) sum(x,2)/size(x,2),proppossigshuff,'un',0);
proppossigshuff = cellfun(@(x) sort(x),proppossigshuff,'un',0);
proppossigshuffhi = cellfun(@(x) x(ceil(0.995*length(x))),proppossigshuff,'un',1);
proppossigshufflo = cellfun(@(x) x(floor(0.005*length(x))),proppossigshuff,'un',1);

ind = find(cellfun(@(x) ~isempty(x),crosscorr));
[propnegsig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)<0),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),propnegsig,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[propnegsigshuffhi' fliplr(propnegsigshufflo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly negative cases');

[proppossig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)>0),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),proppossig,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[proppossigshuffhi' fliplr(proppossigshufflo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('proportion significantly positive cases');

medcorrshuff = cellfun(@(x) mean(abs(x),2),shuffcorr_lag,'un',0);
medcorrshuff = cellfun(@(x) sort(x),medcorrshuff,'un',0);
medcorrshuff_hi = cellfun(@(x) x(ceil(0.995*length(x))),medcorrshuff,'un',1);
medcorrshuff_lo = cellfun(@(x) x(floor(0.005*length(x))),medcorrshuff,'un',1);

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(abs(x(x(:,1)<0,1))),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'b','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[medcorrshuff_hi' fliplr(medcorrshuff_lo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('average abs(neg) correlation');

[hi lo mncorr] = cellfun(@(x) mBootstrapCI(abs(x(x(:,1)>0,1))),crosscorr(ind),'un',1);
figure;hold on;plot(crosscorr_lags(ind),mncorr,'r','marker','o','linewidth',2);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
patch([crosscorr_lags(ind) fliplr(crosscorr_lags(ind))],[medcorrshuff_hi' fliplr(medcorrshuff_lo')],[0.3 0.3 0.3],'edgecolor','none','facealpha',0.3);
xlabel('time relative to target gap (ms)');ylabel('average abs(pos) correlation');

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

%% distribution of burst windows relative to target onset
burstwidth = corrtable.width;
latency = corrtable.latency;
windows_st = floor(latency - burstwidth/2);
windows_ed = ceil(latency + burstwidth/2);
mintm = min(windows_st);
maxtm = max(windows_ed);
windows = cell2mat(arrayfun(@(x,y) [x:y]',windows_st,windows_ed,'un',0));
figure;
[n b] = hist(windows,[mintm:5:maxtm]);stairs(b,n/sum(n),'k');hold on;
xlabel('ms');ylabel('probability');
set(gca,'fontweight','bold');

%% distribution of sample sizes for gaps vs sylls

load('gap_multicorrelation_analysis_fr.mat');
activitythresh = 50;%zscore from shuffled
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable_gap = corrtable10(id,:);

load('dur_multicorrelation_analysis_fr.mat');
activitythresh = 50;%zscore from shuffled
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable_syll = corrtable10(id,:);

gapsampsize = corrtable_gap.ntrials;
syllsampsize = corrtable_syll.ntrials;
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
set(gca,'fontweight','bold');

%% firing rate vs negatively/positively correlated single units 
figure;subplot(1,2,1);hold on;
plot(1,corrtable{sigcorr,'pkFR'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrtable{setdiff(1:height(corrtable),sigcorr),'pkFR'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrtable{sigcorr,'pkFR'}),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrtable{setdiff(1:height(corrtable),sigcorr),'pkFR'}),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrtable{sigcorr,'pkFR'});
err2 = stderr(corrtable{setdiff(1:height(corrtable),sigcorr),'pkFR'});
errorbar(1,mean(corrtable{sigcorr,'pkFR'}),err1,'b','linewidth',2);
errorbar(2,mean(corrtable{setdiff(1:height(corrtable),sigcorr),'pkFR'}),err2,'r','linewidth',2);
title('single units');
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(corrtable{sigcorr,'pkFR'},corrtable{setdiff(1:height(corrtable),sigcorr),'pkFR'});
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,corrtable{negcorr,'pkFR'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrtable{poscorr,'pkFR'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrtable{negcorr,'pkFR'}),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrtable{poscorr,'pkFR'}),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrtable{negcorr,'pkFR'});
err2 = stderr(corrtable{poscorr,'pkFR'});
errorbar(1,mean(corrtable{negcorr,'pkFR'}),err1,'b','linewidth',2);
errorbar(2,mean(corrtable{poscorr,'pkFR'}),err2,'r','linewidth',2);
title('single units');
title('single units');
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('activity (zsc)');xlabel('correlation');
[h p] = ttest2(corrtable{negcorr,'pkFR'},corrtable{poscorr,'pkFR'});
text(0,1,['p=',num2str(p)],'units','normalized');

%% burst width vs negatively/positively, significantly/not sig correlated single units
figure;subplot(1,2,1);hold on;
plot(1,corrtable{sigcorr,'width'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrtable{setdiff(1:height(corrtable),sigcorr),'width'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrtable{sigcorr,'width'}),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrtable{setdiff(1:height(corrtable),sigcorr),'width'}),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrtable{sigcorr,'width'});
err2 = stderr(corrtable{setdiff(1:height(corrtable),sigcorr),'width'});
errorbar(1,mean(corrtable{sigcorr,'width'}),err1,'b','linewidth',2);
errorbar(2,mean(corrtable{setdiff(1:height(corrtable),sigcorr),'width'}),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('burst width (ms)');xlabel('correlation');
title('all units');
[h p] = ttest2(corrtable{sigcorr,'width'},corrtable{setdiff(1:height(corrtable),sigcorr),'width'});
text(0,1,['p=',num2str(p)],'units','normalized');

subplot(1,2,2);hold on;
plot(1,corrtable{negcorr,'width'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
plot(2,corrtable{poscorr,'width'},'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
bar(1,mean(corrtable{negcorr,'width'}),'facecolor','none','edgecolor','b','linewidth',2);hold on;
bar(2,mean(corrtable{poscorr,'width'}),'facecolor','none','edgecolor','r','linewidth',2);hold on;
err1 = stderr(corrtable{negcorr,'width'});
err2 = stderr(corrtable{poscorr,'width'});
errorbar(1,mean(corrtable{negcorr,'width'}),err1,'b','linewidth',2);
errorbar(2,mean(corrtable{poscorr,'width'}),err2,'r','linewidth',2);
xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('burst width (ms)');xlabel('correlation');
title('all units');
[h p] = ttest2(corrtable{negcorr,'width'},corrtable{poscorr,'width'});
text(0,1,['p=',num2str(p)],'units','normalized');

%% is there a relationship between FR or burst width with correlation value
figure
subplot(2,2,1);hold on;
plot(corrtable{negcorr,'width'},[corrtable(negcorr,:).corrs{:,3}],'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrtable{negcorr,'pkFR'},[corrtable(negcorr,:).corrs{:,3}]);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,2);hold on;
plot(corrtable{poscorr,'width'},[corrtable(poscorr,:).corrs{:,3}],'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('burst width (ms)');ylabel('correlation');
[r p] = corrcoef(corrtable{poscorr,'pkFR'},[corrtable(poscorr,:).corrs{:,3}]);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,3);hold on;
plot(corrtable{negcorr,'pkFR'},[corrtable(negcorr,:).corrs{:,3}],'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('FR');ylabel('correlation');
[r p] = corrcoef(corrtable{negcorr,'pkFR'},[corrtable(negcorr,:).corrs{:,3}]);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

subplot(2,2,4);hold on;
plot(corrtable{poscorr,'pkFR'},[corrtable(poscorr,:).corrs{:,3}],'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
xlabel('FR');ylabel('correlation');
[r p] = corrcoef(corrtable{poscorr,'pkFR'},[corrtable(poscorr,:).corrs{:,3}]);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');