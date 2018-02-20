%% multi vs single
%% plot distribution of percent error
ff = load_batchf('batchfile');
clustererr = [];
for i = 1:length(ff)
    load(ff(i).name);
    clustererr = [clustererr; mean(pct_error) pct_ISIs_leq_1ms(end)];
end
[n b] = hist(clustererr(:,1),[0:0.005:0.16]);
figure;hold on;
stairs(b,n,'k');hold on;
xlabel('cluster error');ylabel('counts');
mdl = fitgmdist(clustererr(:,1),2);
classes = cluster(mdl,clustererr(:,1));
[n b] = hist(clustererr(classes==1,1),[0:0.005:0.16]);hold on;
stairs(b,n,'r');hold on;
[n b] = hist(clustererr(classes==2,1),[0:0.005:0.16]);hold on;
stairs(b,n,'b');hold on;

%% plot distribution of average trial by trial variability for gap single vs
%multi unit bursts
load('gap_correlation_analysis_singleunits_ifr.mat');
singleunits = corrtable;
load('gap_correlation_analysis_multiunits_ifr.mat');
multiunits = corrtable;
allunits = [singleunits;multiunits];
[n b] = hist(allunits.trialbytrialcorr,[0:0.02:1]);
figure;hold on;
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n/sum(n),'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n/sum(n),'b');hold on;
xlabel('average trial by trial correlation');ylabel('probability');
title('gap bursts');

load('dur_correlation_analysis_singleunits_ifr.mat');
singleunits = corrtable;
load('dur_correlation_analysis_multiunits_ifr.mat');
multiunits = corrtable;
allunits = [singleunits;multiunits];
[n b] = hist(allunits.trialbytrialcorr,[0:0.05:1]);
figure;hold on;
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.05:1]);
stairs(b,n/sum(n),'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.05:1]);
stairs(b,n/sum(n),'b');hold on;
xlabel('average trial by trial correlation');ylabel('probability');
title('syll bursts');


%% identify units where more than 80% of spikes have greater than 95% posterior probability
%of being in cluster

ff = load_batchf('batchfile');
allposteriors = [];
mnwaveforms = {};
for i = 1:length(ff)
    load(ff(i).name);
    [n b] = hist(spikeposterior(:,end),[0:0.01:1]);
    allposteriors = [allposteriors (n/sum(n))'];
    mnwaveforms = [mnwaveforms;mean(mainwaveform,1)];
end

%plot distribution of cdf spike posterior probs
cdfposteriors = cumsum(allposteriors,1);
figure;plot(b,cdfposteriors);
xlabel('posterior probability');ylabel('probability');

%plot distribution of % spike probability with greater than 95% 
ind = find(b==0.95);
[pr bn] = hist(cdfposteriors(ind,:),[0:0.05:1]);
figure;hold on;
stairs(bn,pr/sum(pr));
xlabel('% of spikes with greater than 95% posterior probability');ylabel('probability')

%write batchfile for units with 80% of spikes that have greater than 95%
%posterior probability
fid = fopen('singleunits_spkpost','w');
fid2 = fopen('multiunits_spkpost','w');
for i = 1:size(cdfposteriors,2)
    if cdfposteriors(find(b==0.95),i)<=0.2
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%units that have percent error < 2% but fewer than 80% of spikes with 95%
%posterior probability
ff = load_batchf('singleunits');
ff2 = load_batchf('singleunits_spkpost');
[~,ia,ib] = setxor({ff(:).name}',{ff2(:).name}');
{ff(ia).name}'
disp([num2str(length(ia)),' units with < 2% error but fewer than 80% of',...
    ' spikes with greater than 95% posterior probability']);
{ff2(ib).name}'
disp([num2str(length(ib)),' units with more than 80% of',...
    ' spikes with greater than 95% posterior probability but > 2% error']);
c = intersect({ff(:).name}',{ff2(:).name}')
disp([num2str(length(c)),' units with more than 80% of',...
    ' spikes with greater than 95% posterior probability AND < 2% error']);

%write batchfile for units with < 2% error AND/OR with more than 80% of spikes
%with greater than 95% posterior probability
c = union({ff(:).name}',{ff2(:).name}');
fid = fopen('singleunits_spkpost_pcterror','w');
for i = 1:length(c)
   fprintf(fid,'%s\n',c{i});
end
fclose(fid)

fid = fopen('multiunits_spkpost_pcterror','w');
ff = load_batchf('batchfile');
[~,ia] = setxor({ff(:).name}',c);
for i = 1:length(ia)
    fprintf(fid,'%s\n',ff(ia(i)).name);
end
fclose(fid)

%% plot average pairwise trial variability vs correlation
load('gap_correlation_analysis_multiunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
sigcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05);
negcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
poscorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
figure;hold on;
plot(corrtable{activecases,{'trialbytrialcorr'}},[corrtable{activecases,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{sigcorr,{'trialbytrialcorr'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{negcorr,{'pct_error'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{negcorr,{'pct_error'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{sigcorr,{'bgactivity'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{sigcorr,{'latency'}}(:,1),[corrtable{sigcorr,{'durcorr'}}{:,1}],'r.')


x = table(corrtable{negcorr,{'trialbytrialcorr'}},corrtable{negcorr,{'ntrials'}},...
    corrtable{negcorr,{'pct_error'}},corrtable{negcorr,{'bgactivity'}},...
    [corrtable{negcorr,{'latency'}}(:,1)],[corrtable{negcorr,{'durcorr'}}{:,1}]',...
    'VariableNames',{'trialbytrialcorr','ntrials','pct_error','bgactivity',...
    'latency','corrval'});


load('gap_correlation_analysis_singleunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
sigcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05);
negcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
poscorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
figure;hold on;
plot(corrtable{activecases,{'trialbytrialcorr'}},[corrtable{activecases,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{sigcorr,{'trialbytrialcorr'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'r.')
figure;hold on;
plot(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'r.')
[r p] = corrcoef(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}])



x = [x; table(corrtable{negcorr,{'trialbytrialcorr'}},corrtable{negcorr,{'ntrials'}},...
    corrtable{negcorr,{'pct_error'}},corrtable{negcorr,{'bgactivity'}},...
    [corrtable{negcorr,{'latency'}}(:,1)],[corrtable{negcorr,{'durcorr'}}{:,1}]',...
    'VariableNames',{'trialbytrialcorr','ntrials','pct_error','bgactivity',...
    'latency','corrval'})];

formula = 'corrval ~ pct_error + ntrials + trialbytrialcorr + bgactivity + latency';
mdl = fitlme(x,formula)


load('gap_correlation_analysis_multiunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
multigap = corrtable(activecases,:);
load('gap_correlation_analysis_singleunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
singlegap = corrtable(activecases,:);

[h p] = ttest2(multigap.bgactivity,singlegap.bgactivity)
figure;hold on;
[n b] = hist([multigap{:,{'bgactivity'}}],[-14:0.5:0]);
stairs(b,n/sum(n),'k');hold on;
[n b] = hist([singlegap{:,{'bgactivity'}}],[-14:0.5:0]);
stairs(b,n/sum(n),'r')


[h p] = ttest2(multigap.trialbytrialcorr,singlegap.trialbytrialcorr)
figure;hold on;
[n b] = hist([multigap{:,{'trialbytrialcorr'}}],[0:0.02:1]);
stairs(b,n,'k');hold on;
[n b] = hist([singlegap{:,{'trialbytrialcorr'}}],[0:0.02:1]);
stairs(b,n,'r')

load('gap_correlation_analysis_multiunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh & corrtable.trialbytrialcorr>=0.85);
multigap = corrtable(activecases,:);
load('gap_correlation_analysis_singleunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh & corrtable.trialbytrialcorr>=0.85);
singlegap = corrtable(activecases,:);

corrtable = [multigap;singlegap];

