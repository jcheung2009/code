%plotting analysis of frequency of significant correlations, individual
%cases were multiple regression with target dur, volume, and adjacent durs

%% parameters and input
load('pitchvol_correlation_analysis.mat');
corrtable = corrtable_seq5_spks;
dattable = dattable_seq5_spks;
%% pitch correlations
ind = find(~isnan([corrtable.pitch_corr{:,1}]));
negcorr = find([corrtable.pitch_corr{:,2}]'<=0.05 & [corrtable.pitch_corr{:,1}]'<0);
poscorr = find([corrtable.pitch_corr{:,2}]'<=0.05 & [corrtable.pitch_corr{:,1}]'>0);
sigcorr = find([corrtable.pitch_corr{:,2}]'<=0.05);
numcases = length(ind);
numsignificant = length(find([corrtable.pitch_corr{:,2}]'<=0.05));

aph = 0.01;ntrials=1000;
shuffcorr = cell2mat(cellfun(@(x) x(:,1),corrtable.shuffle_pitch(:,1),'un',0)');
shuffpval = cell2mat(cellfun(@(x) x(:,1),corrtable.shuffle_pitch(:,2),'un',0)');

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
[n b] = hist([cellfun(@(x) x(1),corrtable.pitch_corr(:,1))],[-1:.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean([cellfun(@(x) x(1),corrtable.pitch_corr(:,1))]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation with pitch');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([cellfun(@(x) x(1),corrtable.pitch_corr(:,1))],shuffcorr(:));
[h p2] = ttest2([cellfun(@(x) x(1),corrtable.pitch_corr(:,1))],shuffcorr(:));
[h p3] = kstest2([cellfun(@(x) x(1),corrtable.pitch_corr(:,1))],shuffcorr(:));
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

%%  mean vol correlations
ind = find(~isnan([corrtable.mnvol_corr{:,1}]));
negcorr = find([corrtable.mnvol_corr{:,2}]'<=0.05 & [corrtable.mnvol_corr{:,1}]'<0);
poscorr = find([corrtable.mnvol_corr{:,2}]'<=0.05 & [corrtable.mnvol_corr{:,1}]'>0);
sigcorr = find([corrtable.mnvol_corr{:,2}]'<=0.05);
numcases = length(ind);
numsignificant = length(find([corrtable.mnvol_corr{:,2}]'<=0.05));

aph = 0.01;ntrials=1000;
shuffcorr = cell2mat(cellfun(@(x) x(:,1),corrtable.shuffle_mnvol(:,1),'un',0)');
shuffpval = cell2mat(cellfun(@(x) x(:,1),corrtable.shuffle_mnvol(:,2),'un',0)');

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
[n b] = hist([cellfun(@(x) x(1),corrtable.mnvol_corr(:,1))],[-1:.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean([cellfun(@(x) x(1),corrtable.mnvol_corr(:,1))]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation with mean vol');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([cellfun(@(x) x(1),corrtable.mnvol_corr(:,1))],shuffcorr(:));
[h p2] = ttest2([cellfun(@(x) x(1),corrtable.mnvol_corr(:,1))],shuffcorr(:));
[h p3] = kstest2([cellfun(@(x) x(1),corrtable.mnvol_corr(:,1))],shuffcorr(:));
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

%%  amp correlations
ind = find(~isnan([corrtable.amp_corr{:,1}]));
negcorr = find([corrtable.amp_corr{:,2}]'<=0.05 & [corrtable.amp_corr{:,1}]'<0);
poscorr = find([corrtable.amp_corr{:,2}]'<=0.05 & [corrtable.amp_corr{:,1}]'>0);
sigcorr = find([corrtable.amp_corr{:,2}]'<=0.05);
numcases = length(ind);
numsignificant = length(find([corrtable.amp_corr{:,2}]'<=0.05));

aph = 0.01;ntrials=1000;
shuffcorr = cell2mat(cellfun(@(x) x(:,1),corrtable.shuffle_amp(:,1),'un',0)');
shuffpval = cell2mat(cellfun(@(x) x(:,1),corrtable.shuffle_amp(:,2),'un',0)');

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
[n b] = hist([cellfun(@(x) x(1),corrtable.amp_corr(:,1))],[-1:.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean([cellfun(@(x) x(1),corrtable.amp_corr(:,1))]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation with amp');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([cellfun(@(x) x(1),corrtable.amp_corr(:,1))],shuffcorr(:));
[h p2] = ttest2([cellfun(@(x) x(1),corrtable.amp_corr(:,1))],shuffcorr(:));
[h p3] = kstest2([cellfun(@(x) x(1),corrtable.amp_corr(:,1))],shuffcorr(:));
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

%% mixed model FR ~ pitch + vol 
subset = dattable_seq1;
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    pitch = subset(ind,:).pitch;
    pitch = (pitch-nanmean(pitch))/nanstd(pitch);
    
    meanvol = subset(ind,:).meanvol;
    meanvol = (meanvol-nanmean(meanvol))/nanstd(meanvol);
    
    amp = subset(ind,:).amp;
    amp = (amp-nanmean(amp))/nanstd(amp);
    
    sylldur = subset(ind,:).sylldur;
    sylldur = (sylldur-nanmean(sylldur))/nanstd(sylldur);
    
    subset(ind,:).pitch = pitch;
    subset(ind,:).amp = amp;
    subset(ind,:).meanvol = meanvol;
    subset(ind,:).sylldur = sylldur;
end

figure;plotResiduals(mdl,'fitted');

formula = ['spikes ~ pitch + burstid + (pitch-1|unitid:seqid)',...
    '+ (burstid-1|unitid:seqid)+(1|unitid:seqid)+(burstid-1|unitid)+(1|unitid)'];
mdl = fitlme(subset,formula)

formula = ['spikes ~ amp + burstid + (amp+burstid|unitid:seqid)',...
    '+(amp-1|unitid)+(1|unitid)'];
mdl = fitlme(subset,formula)

formula = ['spikes ~ meanvol + sylldur+ burstid + (meanvol+sylldur+burstid|unitid:seqid)',...
    '+(meanvol+sylldur+burstid|unitid)'];
mdl = fitlme(subset,formula)

formula = ['spikes ~ pitch + amp + burstid + (pitch+amp+burstid|unitid:seqid)',...
    '+ (pitch+amp+burstid|unitid)'];
mdl = fitlme(subset,formula)

formula = ['spikes ~ pitch + meanvol + sylldur + burstid + (pitch+meanvol+sylldur+burstid|unitid:seqid)',...
    '+ (1|unitid)'];
mdl = fitlme(subset,formula)