%preference for single units to fire relative to target gap or syll onset
%% extract PSTHs from each unit aligned to target gap or syll
[PSTHs_gaps, spiketrains_gaps, PSTHs_rand_gaps, spiketrains_rand_gaps, burstprob_gap] = firing_phase(...
    'singleunits_leq_1pctISI_2pcterr',6,25,0,10,'gap');

[PSTHs_sylls, spiketrains_sylls, PSTHs_rand_sylls, spiketrains_rand_sylls,burstprob_syll] = firing_phase(...
    'singleunits_leq_1pctISI_2pcterr',5,25,0,10,'syll');

save('PSTH_singleunit_gap_and_syll','PSTHs_gaps','spiketrains_gaps','PSTHs_rand_gaps',...
    'spiketrains_rand_gaps','burstprob_gap','PSTHs_sylls','spiketrains_sylls',...
    'PSTHs_rand_sylls','spiketrains_rand_sylls','burstprob_syll');

%% plot PSTHs 
load PSTH_singleunit_gap_and_syll.mat

[hi lo] = mBootstrapCI2(PSTHs_gaps);
figure;hold on;
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'r','edgecolor','none','facealpha',0.5);hold on;

[hi lo] = mBootstrapCI2(PSTHs_rand_gaps);
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'k','edgecolor','none','facealpha',0.5);hold on;

ylabel('firing rate (hz)');xlabel('time relative to gap onset (ms)');

[hi lo] = mBootstrapCI2(PSTHs_sylls);
figure;hold on;
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'r','edgecolor','none','facealpha',0.5);hold on;

[hi lo] = mBootstrapCI2(PSTHs_rand_sylls);
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'k','edgecolor','none','facealpha',0.5);hold on;
ylabel('firing rate (hz)');xlabel('time relative to syll onset (ms)');

%% 
%gap, neg vs others
load gap_multicorrelation_analysis_fr.mat
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
[~,sigcorr,negcorr,poscorr] = plot_distr_corrs(corrtable,50,1000,0.01);
negcorr_id = unique(corrtable(negcorr,{'birdid','unitid'}));

[~,ia,ib] = intersect(negcorr_id(:,{'birdid','unitid'}),burstprob_gap(:,{'birdid','unitid'}));
negcorr_units = burstprob_gap(ib,:);
other_units = burstprob_gap(setdiff(1:height(burstprob_gap),ib),:);
other_units = other_units(find(~cellfun(@isempty,other_units.counts)),:);

negcorr_units_burstcnts = cell2mat(negcorr_units.counts');
other_units_burstcnts = cell2mat(other_units.counts');

[mn hi lo] = jc_BootstrapfreqCI(negcorr_units_burstcnts);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(other_units_burstcnts);
figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([2 2],[hi2 lo2],'k','linewidth',2);hold on;
set(gca,'xtick',[1,2],'xticklabel',{'neg corr units','other units'});
ylabel('probability of firing before a gap');

%gap, pos vs others
poscorr_id = unique(corrtable(poscorr,{'birdid','unitid'}));

[~,ia,ib] = intersect(poscorr_id(:,{'birdid','unitid'}),burstprob_gap(:,{'birdid','unitid'}));
poscorr_units = burstprob_gap(ib,:);
other_units = burstprob_gap(setdiff(1:height(burstprob_gap),ib),:);
other_units = other_units(find(~cellfun(@isempty,other_units.counts)),:);

poscorr_units_burstcnts = cell2mat(poscorr_units.counts');
other_units_burstcnts = cell2mat(other_units.counts');

[mn hi lo] = jc_BootstrapfreqCI(poscorr_units_burstcnts);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(other_units_burstcnts);
figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([2 2],[hi2 lo2],'k','linewidth',2);hold on;
set(gca,'xtick',[1,2],'xticklabel',{'pos corr units','other units'});
ylabel('probability of firing before a gap');

%gap, sig vs others
sigcorr_id = unique(corrtable(sigcorr,{'birdid','unitid'}));

[~,ia,ib] = intersect(sigcorr_id(:,{'birdid','unitid'}),burstprob_gap(:,{'birdid','unitid'}));
sigcorr_units = burstprob_gap(ib,:);
other_units = burstprob_gap(setdiff(1:height(burstprob_gap),ib),:);
other_units = other_units(find(~cellfun(@isempty,other_units.counts)),:);

sigcorr_units_burstcnts = cell2mat(sigcorr_units.counts');
other_units_burstcnts = cell2mat(other_units.counts');

[mn hi lo] = jc_BootstrapfreqCI(sigcorr_units_burstcnts);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(other_units_burstcnts);
figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([2 2],[hi2 lo2],'k','linewidth',2);hold on;
set(gca,'xtick',[1,2],'xticklabel',{'sig corr units','other units'});
ylabel('probability of firing before a gap');


% syllables, neg vs others
load dur_multicorrelation_analysis_fr.mat
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
[~,sigcorr,negcorr,poscorr] = plot_distr_corrs(corrtable,50,1000,0.01);
negcorr_id = unique(corrtable(negcorr,{'birdid','unitid'}));

[~,ia,ib] = intersect(negcorr_id(:,{'birdid','unitid'}),burstprob_syll(:,{'birdid','unitid'}));
negcorr_units = burstprob_syll(ib,:);
other_units = burstprob_syll(setdiff(1:height(burstprob_syll),ib),:);
other_units = other_units(find(~cellfun(@isempty,other_units.counts)),:);

negcorr_units_burstcnts = cell2mat(negcorr_units.counts');
other_units_burstcnts = cell2mat(other_units.counts');

[mn hi lo] = jc_BootstrapfreqCI(negcorr_units_burstcnts);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(other_units_burstcnts);
figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([2 2],[hi2 lo2],'k','linewidth',2);hold on;
set(gca,'xtick',[1,2],'xticklabel',{'neg corr units','other units'});
ylabel('probability of firing before a syll');


%syll, pos vs others
poscorr_id = unique(corrtable(poscorr,{'birdid','unitid'}));

[~,ia,ib] = intersect(poscorr_id(:,{'birdid','unitid'}),burstprob_syll(:,{'birdid','unitid'}));
poscorr_units = burstprob_syll(ib,:);
other_units = burstprob_syll(setdiff(1:height(burstprob_syll),ib),:);
other_units = other_units(find(~cellfun(@isempty,other_units.counts)),:);

poscorr_units_burstcnts = cell2mat(poscorr_units.counts');
other_units_burstcnts = cell2mat(other_units.counts');

[mn hi lo] = jc_BootstrapfreqCI(poscorr_units_burstcnts);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(other_units_burstcnts);
figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([2 2],[hi2 lo2],'k','linewidth',2);hold on;
set(gca,'xtick',[1,2],'xticklabel',{'pos corr units','other units'});
ylabel('probability of firing before a syll');

%syll, sig vs others
sigcorr_id = unique(corrtable(sigcorr,{'birdid','unitid'}));

[~,ia,ib] = intersect(sigcorr_id(:,{'birdid','unitid'}),burstprob_syll(:,{'birdid','unitid'}));
sigcorr_units = burstprob_syll(ib,:);
other_units = burstprob_syll(setdiff(1:height(burstprob_syll),ib),:);
other_units = other_units(find(~cellfun(@isempty,other_units.counts)),:);

sigcorr_units_burstcnts = cell2mat(sigcorr_units.counts');
other_units_burstcnts = cell2mat(other_units.counts');

[mn hi lo] = jc_BootstrapfreqCI(sigcorr_units_burstcnts);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(other_units_burstcnts);
figure;hold on;
bar(1,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
plot([1 1],[hi lo],'r','linewidth',2);hold on;
bar(2,mn2,'facecolor','none','edgecolor','k','linewidth',2);hold on;
plot([2 2],[hi2 lo2],'k','linewidth',2);hold on;
set(gca,'xtick',[1,2],'xticklabel',{'sig corr units','other units'});
ylabel('probability of firing before a syll');

