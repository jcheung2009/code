%analyzing whether gap and syllable regression with neural activity is
%different using IFR or FR 

%% cases that were active with fr but not with ifr
load('gap_multicorrelation_analysis_ifr');
gap_singleifr = corrtable10(find(corrtable10.pct_error<=0.02 & corrtable10.pkFR>=50),:);
load('gap_multicorrelation_analysis_fr');
gap_singlefr = corrtable10(find(corrtable10.pct_error<=0.02 & corrtable10.pkFR>=50),:);

[x ix] = setdiff(gap_singlefr(:,{'unitid','seqid'}),gap_singleifr(:,{'unitid','seqid'}));
x = gap_singlefr(ix,{'unitid','seqid','burstid'});

RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,10,'burst','ifr','gap')
RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,10,'burst','fr','gap')

%% cases that were significantly positive with either fr OR ifr (exclusive) 
load('gap_multicorrelation_analysis_ifr');
gap_singleifr = corrtable10(find(corrtable10.pct_error<=0.02 & corrtable10.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable10.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable10.corrs(:,1))>0),:);
load('gap_multicorrelation_analysis_fr');
gap_singlefr = corrtable10(find(corrtable10.pct_error<=0.02 & corrtable10.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable10.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable10.corrs(:,1))>0),:);

[~,ia,ib] = setxor(gap_singleifr(:,{'unitid','seqid'}),gap_singlefr(:,{'unitid','seqid'}));

x = [gap_singleifr(ia,{'unitid','seqid','burstid'});gap_singlefr(ib,{'unitid','seqid','burstid'})];

RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,10,'burst','ifr','gap')
RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,10,'burst','fr','gap')


%% cases that were significantly negative with either fr OR ifr (exclusive) 
load('gap_multicorrelation_analysis_ifr');
gap_singleifr = corrtable10(find(corrtable10.pct_error<=0.02 & corrtable10.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable10.corrs(:,4))<=0.05 & cellfun(@(x) x(1),corrtable10.corrs(:,3))<0),:);
load('gap_multicorrelation_analysis_fr');
gap_singlefr = corrtable10(find(corrtable10.pct_error<=0.02 & corrtable10.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable10.corrs(:,4))<=0.05 & cellfun(@(x) x(1),corrtable10.corrs(:,3))<0),:);

[~,ia,ib] = setxor(gap_singleifr(:,{'unitid','seqid'}),gap_singlefr(:,{'unitid','seqid'}));

x = [gap_singleifr(ia,{'unitid','seqid','burstid'});gap_singlefr(ib,{'unitid','seqid','burstid'})];

RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,10,'burst','ifr','gap')
RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,10,'burst','fr','gap')

%% distribution of ISI for all RA spikes to get an idea of what window size 
%to use for convolving spike trains
ff = load_batchf('batchfile');
ISI = [];
for i = 1:length(ff)
    load(ff(i).name);
    ISI = [ISI diff(spiketimes)];
end
ISI = ISI*1000;
ISI = ISI(find(ISI<=1000));

figure;
[n b] = hist(ISI,[0:1:1000]);
stairs(b,n/sum(n),'k');xlabel('ISI (ms)');ylabel('probability');title('all units');hold on;
title('all units')

%% results for analyzing gap and syllable premotor activity with gap and syll
%duration comparing using IFR vs FR

load gap_multicorrelation_analysis_fr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

load gap_multicorrelation_analysis_ifr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

load dur_multicorrelation_analysis_fr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

load dur_multicorrelation_analysis_ifr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
