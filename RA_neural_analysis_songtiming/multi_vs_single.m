% analyzing characteristics between multi vs single units to identify what
% criterion to use to separate them 

%% plot distribution of percent error and ISI violation across all units
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

%fit 2 gaussians to distribution of percent (cluster) error 
mdl = fitgmdist(clustererr(:,1),2);
classes = cluster(mdl,clustererr(:,1));
[n b] = hist(clustererr(classes==1,1),[0:0.005:0.16]);hold on;
stairs(b,n,'r');hold on;
[n b] = hist(clustererr(classes==2,1),[0:0.005:0.16]);hold on;
stairs(b,n,'b');hold on;

[n b] = hist(clustererr(:,2),[0:0.005:0.16]);
figure;hold on;
stairs(b,n,'k');hold on;
xlabel('% ISI violation');ylabel('counts');

%division between single vs multi unit after fitting 2 gaussians to
%distribution of percent cluster error is 2%. Not obvious that there are
%two gaussian distributions for % ISI violations%% write batchfile for units with <1% cluster error
fid = fopen('singleunits_leq_1pcterr','w');
fid2 = fopen('multiunits_gt_1pcterr','w');
for i = 1:size(clustererr,1)
    if clustererr(i,1)<=0.01
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%% write batchfile for units with <2% cluster error
fid = fopen('singleunits_leq_2pcterr','w');
fid2 = fopen('multiunits_gt_2pcterr','w');
for i = 1:size(clustererr,1)
    if clustererr(i,1)<=0.02
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%% write batchfile for units with <4% cluster error
fid = fopen('singleunits_leq_4pcterr','w');
fid2 = fopen('multiunits_gt_4pcterr','w');
for i = 1:size(clustererr,1)
    if clustererr(i,1)<=0.04
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)


%% write batchfile for units with <1% ISI violation
fid = fopen('singleunits_leq_1pctISI','w');
fid2 = fopen('multiunits_gt_1pctISI','w');
for i = 1:size(clustererr,1)
    if clustererr(i,2)<=0.01
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%% write batchfile for units with <1% ISI violation AND/OR <2% err
fid = fopen('singleunits_leq_1pctISI_2pcterr','w');
fid2 = fopen('multiunits_gt_1pctISI_2pcterr','w');
for i = 1:size(clustererr,1)
    if clustererr(i,2)<=0.01 | clustererr(i,1)<=0.02
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%% compare differences in analysis results (correlating gap duration vs FR) 
%between single vs multi units based on 2% error criterion, 10 ms gaussian
%50hz activity threshold, FR

load('gap_multicorrelation_analysis_fr');
activitythresh = 50;
ff = load_batchf('singleunits_leq_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('single units < 2% error')

ff = load_batchf('multiunits_gt_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('multi units > 2% error')

%% compare differences in analysis results (correlating gap duration vs FR) 
%between single vs multi units based on 1% ISI violation criterion, 10 ms gaussian
%50hz activity threshold, FR

load('gap_multicorrelation_analysis_fr');
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('single units < 1% ISI violation')

ff = load_batchf('multiunits_gt_1pctISI');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('multi units > 1% ISI violation')


%% plot distribution of average trial by trial variability from gap premotor 
%activity single vs multi unit bursts classified by leq 2% error with a 10 ms gaussian win
load('gap_multicorrelation_analysis_fr.mat');
allunits = corrtable10;
singleunits = corrtable10(find(allunits.pct_error<=0.02),:);
multiunits = corrtable10(find(allunits.pct_error>0.02),:);
[n b] = hist(allunits.trialbytrialcorr,[0:0.02:1]);
figure;hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n,'b');hold on;
xlabel('average trial by trial correlation');ylabel('counts');
title('gap bursts');

%not good separability between multi vs single units using average pairwise
%trial variability 

%% plot distribution of average trial by trial variability for gap single vs
%multi unit bursts classified by leq 1% ISI violation with a 10 ms gaussian win
load('gap_multicorrelation_analysis_fr.mat');
allunits = corrtable10;
ff = load_batchf('singleunits_leq_1pctISI');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),allunits.unitid))];
end
singleunits = allunits(id,:);
ff = load_batchf('multiunits_gt_1pctISI');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),allunits.unitid))];
end
multiunits = allunits(id,:);
figure;hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n,'b');hold on;
xlabel('average trial by trial correlation');ylabel('counts');
title('gap bursts');

%not good separability between multi vs single units using average pairwise
%trial variability 

%% plot distribution of burst FR for gaps single vs multi unit bursts 2% error,
%10 ms gaussian
load('gap_multicorrelation_analysis_fr.mat');
allunits = corrtable10;
singleunits = corrtable10(find(allunits.pct_error<=0.02),:);
multiunits = corrtable10(find(allunits.pct_error>0.02),:);
[n b] = hist(allunits.pkFR,[0:0.02:1]);
figure;hold on;
% stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.pkFR,[10:10:500]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.pkFR,[10:10:500]);
stairs(b,n,'b');hold on;
xlabel('burst FR');ylabel('counts');
title('gap bursts');

%not really different between multi vs single unit
%% plot distribution of burst width for gaps single vs multi unit bursts 2% error,
%10 ms gaussian
load('gap_multicorrelation_analysis_fr.mat');
allunits = corrtable10;
singleunits = corrtable10(find(allunits.pct_error<=0.02),:);
multiunits = corrtable10(find(allunits.pct_error>0.02),:);
figure;hold on;
% stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.width,[10:5:130]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.width,[10:5:130]);
stairs(b,n,'b');hold on;
xlabel('burst width');ylabel('counts');
title('gap bursts');

%not really different between multi vs single unit

%% plot distribution of pkactivity for gaps single vs multi unit bursts 2% error,
%10 ms gaussian
load('gap_multicorrelation_analysis_fr.mat');
allunits = corrtable10;
singleunits = corrtable10(find(allunits.pct_error<=0.02),:);
multiunits = corrtable10(find(allunits.pct_error>0.02),:);
figure;hold on;
% stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.pkactivity,[-5:5:100]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.pkactivity,[-5:5:100]);
stairs(b,n,'b');hold on;
xlabel('pkactivity relative to random');ylabel('counts');
title('gap bursts');

%not really different between multi vs single unit

%% plot distribution of bgactivity for gaps single vs multi unit bursts 2% error,
%10 ms gaussian
load('gap_multicorrelation_analysis_fr.mat');
allunits = corrtable10;
singleunits = corrtable10(find(allunits.pct_error<=0.02),:);
multiunits = corrtable10(find(allunits.pct_error>0.02),:);
figure;hold on;
% stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.bgactivity,[-20:1:0]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.bgactivity,[-20:1:0]);
stairs(b,n,'b');hold on;
xlabel('bgactivity relative to random');ylabel('counts');
title('gap bursts');


%% plot cdfs spike posterior probs 
%spikeposteriors in summary matfile from spike_posteriors.m

%for all spikes from each unit, compute cdf of posterior probability that
%spikes belonged to that unit cluster
ff = load_batchf('batchfile');
allposteriors = [];
mnposterior = [];
for i = 1:length(ff)
    load(ff(i).name);
    [n b] = hist(spikeposterior(:,end),[0:0.01:1]);
    allposteriors = [allposteriors (n/sum(n))'];
    mnposterior = [mnposterior mean(spikeposterior(:,end))];
end

%distr of average posterior probability
figure;subplot(1,3,1);hold on;
[n b] = hist(mnposterior,20);
stairs(b,n/sum(n));
xlabel('average posterior probability');
ylabel('pdf')

%assuming that single units are more tightly clustered than multi units,
%then single units should have cdf curves that are skewed towards high end
%of posterior probability
subplot(1,3,2);
b = [0:0.01:1];
cdfposteriors = cumsum(allposteriors,1);
plot(b,cdfposteriors);
xlabel('posterior probability');ylabel('cdf');

%plot distribution of "% spikes with greater than 95% posterior
%probability"; looks like two classes of units separated by whether more than 20% of
%their spikes have greater than 95% posterior probability 
subplot(1,3,3);
b = [0:0.01:1];
ind= find(b==0.95);
[cnt bn] = hist(1-cdfposteriors(ind,:),[0:0.05:1]);
stairs(bn,cnt);
xlabel('% of spikes with greater than 95% posterior probability');ylabel('counts')

%% write batchfile for units at least 20% of spikes with greater than 95%
%posterior probability
fid = fopen('singleunits_95pctpost_20pct','w');
fid2 = fopen('multiunits_95pctpost_20pct','w');
b = [0:0.01:1];
for i = 1:size(cdfposteriors,2)
    if 1-cdfposteriors(find(b==0.95),i)>0.2
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%% write batchfile for units at least 80% of spikes with greater than 95%
%posterior probability (arbitrarily set at 80%) 
fid = fopen('singleunits_95pctpost_80pct','w');
fid2 = fopen('multiunits_95pctpost_80pct','w');
for i = 1:size(cdfposteriors,2)
    if cdfposteriors(find(b==0.95),i)<=0.2
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)

%% compare differences in analysis results (correlating gap duration vs FR) 
%between single vs multi units based on spike posterior probability, 10 ms gaussian
%50hz activity threshold, FR

load('gap_multicorrelation_analysis_fr');
activitythresh = 50;
ff = load_batchf('singleunits_95pctpost_20pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('single units with more than 20% of its spikes with greater than 95% posterior probability')

ff = load_batchf('multiunits_95pctpost_20pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('multi units with less than 20% of its spikes with greater than 95% posterior probability')

load('gap_multicorrelation_analysis_fr');
activitythresh = 50;
ff = load_batchf('singleunits_95pctpost_80pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('single units with more than 80% of its spikes with greater than 95% posterior probability')

ff = load_batchf('multiunits_95pctpost_80pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('multi units with less than 80% of its spikes with greater than 95% posterior probability')

%% compare differences in analysis results (correlating syllable duration vs FR) 
%between single vs multi units based on spike posterior probability, 10 ms gaussian
%50hz activity threshold, FR
load('dur_multicorrelation_analysis_fr');
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('single units with < 2% error or < 1% ISI')

ff = load_batchf('multiunits_gt_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('multi units > 2% error and >1% ISI ')


load('dur_multicorrelation_analysis_fr');
activitythresh = 50;
ff = load_batchf('singleunits_95pctpost_20pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('single units with more than 20% of its spikes with greater than 95% posterior probability')

ff = load_batchf('multiunits_95pctpost_20pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('multi units with less than 20% of its spikes with greater than 95% posterior probability')

%% single vs multi units results for gap and syllable regression analysis 
%is very similar for criterions using 2% error, 1% ISI violation, and >80%
%of spikes with higher than 95% posterior probability. Manuscript uses
%single units defined as EITHER: < 2% error OR < 1% ISI violation 