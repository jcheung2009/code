

%% cases that were active with fr but not with ifr
load('gap_multicorrelation_analysis_ifr');
gap_singleifr = corrtable20(find(corrtable20.pct_error<=0.02 & corrtable20.pkFR>=50),:);
load('gap_multicorrelation_analysis_fr');
gap_singlefr = corrtable20(find(corrtable20.pct_error<=0.02 & corrtable20.pkFR>=50),:);

[x ix] = setdiff(gap_singlefr(:,{'unitid','seqid'}),gap_singleifr(:,{'unitid','seqid'}));
x = gap_singlefr(ix,{'unitid','seqid','burstid'});

RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,'burst','gap')

%% cases that were significantly positive with either fr OR ifr (exclusive) 
load('gap_multicorrelation_analysis_ifr');
gap_singleifr = corrtable20(find(corrtable20.pct_error<=0.02 & corrtable20.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable20.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable20.corrs(:,1))>0),:);
load('gap_multicorrelation_analysis_fr');
gap_singlefr = corrtable20(find(corrtable20.pct_error<=0.02 & corrtable20.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable20.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable20.corrs(:,1))>0),:);

[~,ia,ib] = setxor(gap_singleifr(:,{'unitid','seqid'}),gap_singlefr(:,{'unitid','seqid'}));

x = [gap_singleifr(ia,{'unitid','seqid','burstid'});gap_singlefr(ib,{'unitid','seqid','burstid'})];
RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,'burst','gap')


%% cases that were significantly negative with either fr OR ifr (exclusive) 
load('gap_multicorrelation_analysis_ifr');
gap_singleifr = corrtable20(find(corrtable20.pct_error<=0.02 & corrtable20.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable20.corrs(:,4))<=0.05 & cellfun(@(x) x(1),corrtable20.corrs(:,3))<0),:);
load('gap_multicorrelation_analysis_fr');
gap_singlefr = corrtable20(find(corrtable20.pct_error<=0.02 & corrtable20.pkFR>=50 ...
    & cellfun(@(x) x(1),corrtable20.corrs(:,4))<=0.05 & cellfun(@(x) x(1),corrtable20.corrs(:,3))<0),:);

[~,ia,ib] = setxor(gap_singleifr(:,{'unitid','seqid'}),gap_singlefr(:,{'unitid','seqid'}));

x = [gap_singleifr(ia,{'unitid','seqid','burstid'});gap_singlefr(ib,{'unitid','seqid','burstid'})];
RA_correlate_gapdur_plot('singleunits_leq_2pcterr',x,-40,'burst','gap')

%% distribution of ISI for all RA spikes
ff = load_batchf('batchfile');
ISI = [];
for i = 1:length(ff)
    load(ff(i).name);
    ISI = [ISI diff(spiketimes)];
end
ISI = ISI*1000;
ISI = ISI(find(ISI<=1000));
[n b] = hist(ISI,[0:1:1000]);
figure;stairs(b,n/sum(n),'k');xlabel('ISI (ms)');ylabel('probability');title('all units');
figure;plot(b,cumsum(n/sum(n)));xlabel('ISI (ms)');ylabel('cdf');xlim([0 100]);
title('all units')

ff = load_batchf('singleunits_leq_2pcterr');
ISI = [];
for i = 1:length(ff)
    load(ff(i).name);
    ISI = [ISI diff(spiketimes)];
end
ISI = ISI*1000;
ISI = ISI(find(ISI<=1000));
[n b] = hist(ISI,[0:1:1000]);
figure;stairs(b,n/sum(n),'k');xlabel('ISI (ms)');ylabel('probability');title('single units');
figure;plot(b,cumsum(n/sum(n)));xlabel('ISI (ms)');ylabel('cdf');xlim([0 100]);
title('single units');

ff = load_batchf('multiunits_gt_2pcterr');
ISI = [];
for i = 1:length(ff)
    load(ff(i).name);
    ISI = [ISI diff(spiketimes)];
end
ISI = ISI*1000;
ISI = ISI(find(ISI<=1000));
[n b] = hist(ISI,[0:1:1000]);
figure;stairs(b,n/sum(n),'k');xlabel('ISI (ms)');ylabel('probability');title('single units');
figure;plot(b,cumsum(n/sum(n)));xlabel('ISI (ms)');ylabel('cdf');xlim([0 100]);
title('multi units');
%use 20 or 40 ms gaussian window for convolving spike trains

