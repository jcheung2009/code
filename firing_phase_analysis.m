%preference for single units to fire relative to target gap or syll onset
[PSTHs, spiketrains, PSTHs_rand, spiketrains_rand, burstprob_gap] = firing_phase(...
    'singleunits_leq_1pctISI_2pcterr',6,25,0,10,'gap');

[hi lo] = mBootstrapCI2(PSTHs);
figure;hold on;
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'r','edgecolor','none','facealpha',0.5);hold on;

[hi lo] = mBootstrapCI2(PSTHs_rand);
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'k','edgecolor','none','facealpha',0.5);hold on;

ylabel('firing rate (hz)');xlabel('time relative to gap onset (ms)');

[PSTHs, spiketrains, PSTHs_rand, spiketrains_rand,burstprob_syll] = firing_phase(...
    'singleunits_leq_1pctISI_2pcterr',5,25,0,10,'syll');

[hi lo] = mBootstrapCI2(PSTHs);
figure;hold on;
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'r','edgecolor','none','facealpha',0.5);hold on;

[hi lo] = mBootstrapCI2(PSTHs_rand);
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'k','edgecolor','none','facealpha',0.5);hold on;
ylabel('firing rate (hz)');xlabel('time relative to syll onset (ms)');

%% probability for bursting in premotor window given unit is significantly
%correlated with at least one gap or syll
load('gap_multicorrelation_analysis_fr.mat');
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);

[~,sigcorr,negcorr,poscorr] = plot_distr_corrs(corrtable,50,1000,0.01);
[~,ia,ib] = intersect(corrtable(negcorr,{'birdid','unitid'}),burstprob_gap(:,...
    {'birdid','unitid'}));
negcorrelated_units = burstprob_gap(ib,:);
negcorrelated_units = negcorrelated_units(~cellfun(@isempty,negcorrelated_units.counts),:)
negcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',negcorrelated_units.counts,'un',0));

notcorrelated_units = burstprob_gap(setdiff(1:height(burstprob_gap),ib),:)
notcorrelated_units = notcorrelated_units(~cellfun(@isempty,notcorrelated_units.counts),:)
notcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',notcorrelated_units.counts,'un',0));

[mn hi lo] = jc_BootstrapfreqCI(negcorrelated_units_burstprob);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(notcorrelated_units_burstprob);

figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
plot([2,2],[hi2 lo2],'k','linewidth',2);
ylabel('probability of bursting before gap');
set(gca,'xtick',[1,2],'xticklabels',{'negatively correlated','not or positively correlated'});

[p class] = perm_diffprop(negcorrelated_units_burstprob,notcorrelated_units_burstprob);

[~,ia,ib] = intersect(corrtable(sigcorr,{'birdid','unitid'}),burstprob_gap(:,...
    {'birdid','unitid'}));
correlated_units = burstprob_gap(ib,:);
correlated_units = correlated_units(~cellfun(@isempty,correlated_units.counts),:)
correlated_units_burstprob = cell2mat(cellfun(@(x) x',correlated_units.counts,'un',0));

notcorrelated_units = burstprob_gap(setdiff(1:height(burstprob_gap),ib),:)
notcorrelated_units = notcorrelated_units(~cellfun(@isempty,notcorrelated_units.counts),:)
notcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',notcorrelated_units.counts,'un',0));

[mn hi lo] = jc_BootstrapfreqCI(correlated_units_burstprob);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(notcorrelated_units_burstprob);

figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
plot([2,2],[hi2 lo2],'k','linewidth',2);
ylabel('probability of bursting before gap');
set(gca,'xtick',[1,2],'xticklabels',{'correlated','not correlated'});

[p class] = perm_diffprop(correlated_units_burstprob,notcorrelated_units_burstprob);

[~,ia,ib] = intersect(corrtable(poscorr,{'birdid','unitid'}),burstprob_gap(:,...
    {'birdid','unitid'}));
correlated_units = burstprob_gap(ib,:);
correlated_units = correlated_units(~cellfun(@isempty,correlated_units.counts),:)
correlated_units_burstprob = cell2mat(cellfun(@(x) x',correlated_units.counts,'un',0));

notcorrelated_units = burstprob_gap(setdiff(1:height(burstprob_gap),ib),:)
notcorrelated_units = notcorrelated_units(~cellfun(@isempty,notcorrelated_units.counts),:)
notcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',notcorrelated_units.counts,'un',0));

[mn hi lo] = jc_BootstrapfreqCI(correlated_units_burstprob);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(notcorrelated_units_burstprob);

figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
plot([2,2],[hi2 lo2],'k','linewidth',2);
ylabel('probability of bursting before gap');
set(gca,'xtick',[1,2],'xticklabels',{'pos correlated','neg or not correlated'});

[p class] = perm_diffprop(correlated_units_burstprob,notcorrelated_units_burstprob);

%%
load('dur_multicorrelation_analysis_fr.mat');
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);

[~,sigcorr,negcorr,poscorr] = plot_distr_corrs(corrtable,50,1000,0.01);
[~,ia,ib] = intersect(corrtable(negcorr,{'birdid','unitid'}),burstprob_syll(:,...
    {'birdid','unitid'}));
negcorrelated_units = burstprob_syll(ib,:);
negcorrelated_units = negcorrelated_units(~cellfun(@isempty,negcorrelated_units.counts),:)
negcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',negcorrelated_units.counts,'un',0));

notcorrelated_units = burstprob_syll(setdiff(1:height(burstprob_syll),ib),:)
notcorrelated_units = notcorrelated_units(~cellfun(@isempty,notcorrelated_units.counts),:)
notcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',notcorrelated_units.counts,'un',0));

[mn hi lo] = jc_BootstrapfreqCI(negcorrelated_units_burstprob);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(notcorrelated_units_burstprob);

figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
plot([2,2],[hi2 lo2],'k','linewidth',2);
ylabel('probability of bursting before syll');
set(gca,'xtick',[1,2],'xticklabels',{'negatively correlated','not or positively correlated'});

[p class] = perm_diffprop(negcorrelated_units_burstprob,notcorrelated_units_burstprob);

[~,ia,ib] = intersect(corrtable(sigcorr,{'birdid','unitid'}),burstprob_syll(:,...
    {'birdid','unitid'}));
correlated_units = burstprob_syll(ib,:);
correlated_units = correlated_units(~cellfun(@isempty,correlated_units.counts),:)
correlated_units_burstprob = cell2mat(cellfun(@(x) x',correlated_units.counts,'un',0));

notcorrelated_units = burstprob_syll(setdiff(1:height(burstprob_syll),ib),:)
notcorrelated_units = notcorrelated_units(~cellfun(@isempty,notcorrelated_units.counts),:)
notcorrelated_units_burstprob = cell2mat(cellfun(@(x) x',notcorrelated_units.counts,'un',0));

[mn hi lo] = jc_BootstrapfreqCI(correlated_units_burstprob);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(notcorrelated_units_burstprob);

figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
plot([2,2],[hi2 lo2],'k','linewidth',2);
ylabel('probability of bursting before syll');
set(gca,'xtick',[1,2],'xticklabels',{'correlated','not correlated'});

[p class] = perm_diffprop(correlated_units_burstprob,notcorrelated_units_burstprob);

