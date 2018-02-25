%% compare differences between single vs multi unit analysis, 2% error, 20 ms gaussian
%50hz activity threshold, IFR

load('gap_multicorrelation_analysis_ifr');
%load('dur_correlation_analysis_ifr');
activitythresh = 50;
ff = load_batchf('singleunits_leq_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable20.unitid))];
end
corrtable = corrtable20(id,:);

negcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
poscorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
sigcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05);
notsigcorr = find(corrtable.pkFR>=activitythresh & ...
    [corrtable.durcorr{:,2}]'>0.05);
activecases = find(corrtable.pkFR>=activitythresh);

numcases = length(activecases);
numsignificant = length(find(corrtable.pkFR>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05));

aph = 0.01;ntrials=1000;
shuffcorr = [corrtable(activecases,:).durcorr{:,3}];
shuffpval = [corrtable(activecases,:).durcorr{:,4}];

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
[n b] = hist([corrtable(activecases,:).durcorr{:,1}],[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean([corrtable(activecases,:).durcorr{:,1}]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([corrtable(activecases,:).durcorr{:,1}],shuffcorr(:));
[h p2] = ttest2([corrtable(activecases,:).durcorr{:,1}],shuffcorr(:));
[h p3] = kstest2([corrtable(activecases,:).durcorr{:,1}],shuffcorr(:));
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

%% plot distribution of percent error and ISI violation
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

[n b] = hist(clustererr(:,2),[0:0.005:0.16]);
figure;hold on;
stairs(b,n,'k');hold on;
xlabel('% ISI violation');ylabel('counts');

%write batchfile for units with <1% cluster error
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

%write batchfile for units with <2% cluster error
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

%write batchfile for units with <4% cluster error
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


%write batchfile for units with <1% ISI violation
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

%% plot distribution of average trial by trial variability for gap single vs
%multi unit bursts classified by leq 2% error with a 20 ms gaussian win
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
singleunits = corrtable20(find(allunits.pct_error<=0.02),:);
multiunits = corrtable20(find(allunits.pct_error>0.02),:);
[n b] = hist(allunits.trialbytrialcorr,[0:0.02:1]);
figure;hold on;
% stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n,'b');hold on;
xlabel('average trial by trial correlation');ylabel('counts');
title('gap bursts');

%use average pairwise trial by trial correlation >65% as single vs multi
%unit threshold 

%% plot distribution of average trial by trial variability for gap single vs
%multi unit bursts classified by leq 1% ISI violation with a 20 ms gaussian win
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
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

%% plot distribution of burst FR for gaps single vs multi unit bursts 2% error,
%20 ms gaussian
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
singleunits = corrtable20(find(allunits.pct_error<=0.02),:);
multiunits = corrtable20(find(allunits.pct_error>0.02),:);
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
%20 ms gaussian
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
singleunits = corrtable20(find(allunits.pct_error<=0.02),:);
multiunits = corrtable20(find(allunits.pct_error>0.02),:);
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
%20 ms gaussian
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
singleunits = corrtable20(find(allunits.pct_error<=0.02),:);
multiunits = corrtable20(find(allunits.pct_error>0.02),:);
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
%20 ms gaussian
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
singleunits = corrtable20(find(allunits.pct_error<=0.02),:);
multiunits = corrtable20(find(allunits.pct_error>0.02),:);
figure;hold on;
% stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.bgactivity,[-20:1:0]);
stairs(b,n,'r');hold on;
[n b] = hist(multiunits.bgactivity,[-20:1:0]);
stairs(b,n,'b');hold on;
xlabel('bgactivity relative to random');ylabel('counts');
title('gap bursts');


%% plot cdfs spike posterior probs

ff = load_batchf('batchfile');
allposteriors = [];
mnwaveforms = {};
for i = 1:length(ff)
    load(ff(i).name);
    [n b] = hist(spikeposterior(:,end),[0:0.01:1]);
    allposteriors = [allposteriors (n/sum(n))'];
    mnwaveforms = [mnwaveforms;mean(mainwaveform,1)];
end

cdfposteriors = cumsum(allposteriors,1);
figure;plot(b,cdfposteriors);
xlabel('posterior probability');ylabel('probability');


%plot distribution of posterior probability at 20% of spikes 
b = [0:0.01:1];
map = bsxfun(@gt, cdfposteriors,0.2);
[~,ix] = max(map,[],1);
posterior20 = b(ix);
[cnt bx] = hist(posterior20,[0:0.05:1]);
figure;stairs(bx,cnt);xlabel('posterior probability for 20% of spikes');ylabel('counts');

%plot distribution of posterior probability at 10% of spikes 
b = [0:0.01:1];
map = bsxfun(@gt, cdfposteriors,0.1);
[~,ix] = max(map,[],1);
posterior20 = b(ix);
[cnt bx] = hist(posterior20,[0:0.05:1]);
figure;stairs(bx,cnt);xlabel('posterior probability for 10% of spikes');ylabel('counts');

%plot distribution of % spike probability with greater than 95% 
ind = find(b==0.95);
[cnt bn] = hist(1-cdfposteriors(ind,:),[0:0.05:1]);
figure;hold on;stairs(bn,cnt);
xlabel('% of spikes with greater than 95% posterior probability');ylabel('probability')

%write batchfile for units at least 80% of spikes with greater than 95%
%posterior probability
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

%write batchfile for units at least 90% of spikes with greater than 85%
%posterior probability
fid = fopen('singleunits_90pctpost_85pct','w');
fid2 = fopen('multiunits_90pctpost_85pct','w');
for i = 1:size(cdfposteriors,2)
    if cdfposteriors(find(b==0.90),i)<=0.15
        fprintf(fid,'%s\n',ff(i).name);
    else
        fprintf(fid2,'%s\n',ff(i).name);
    end
end
fclose(fid)


%units that have percent error < 2% but fewer than 80% of spikes with 95%
%posterior probability
ff = load_batchf('singleunits_leq_2pcterr');
ff2 = load_batchf('singleunits_95pctpost_80pct');
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

%% plot distribution of average trial by trial variability for gap single vs
%multi unit bursts (classified by spike posterior prob)
load('gap_correlation_analysis_ifr.mat');
allunits = corrtable20;
ff = load_batchf('singleunits_95pctpost_80pct');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),allunits.unitid))];
end
singleunits = allunits(id,:);
ff = load_batchf('multiunits_95pctpost_80pct');
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

%% plot distribution of spike posterior probability for 80% of spikes in single vs
%multi unit classified by 2% error
ff = load_batchf('multiunits_gt_2pcterr');
allposteriors = [];
mnwaveforms = {};
for i = 1:length(ff)
    load(ff(i).name);
    [n b] = hist(spikeposterior(:,end),[0:0.01:1]);
    allposteriors = [allposteriors (n/sum(n))'];
    mnwaveforms = [mnwaveforms;mean(mainwaveform,1)];
end

cdfposteriors_multi = cumsum(allposteriors,1);
figure;hold on;plot(b,cdfposteriors_multi,'b');hold on;
xlabel('posterior probability');ylabel('probability');

ff = load_batchf('singleunits_leq_2pcterr');
allposteriors = [];
mnwaveforms = {};
for i = 1:length(ff)
    load(ff(i).name);
    [n b] = hist(spikeposterior(:,end),[0:0.01:1]);
    allposteriors = [allposteriors (n/sum(n))'];
    mnwaveforms = [mnwaveforms;mean(mainwaveform,1)];
end

cdfposteriors_single = cumsum(allposteriors,1);
plot(b,cdfposteriors_single,'r');hold on;
xlabel('posterior probability');ylabel('probability');


%plot distribution of posterior probability at 20% of spikes 
b = [0:0.01:1];
map = bsxfun(@gt, cdfposteriors_single,0.2);
[~,ix] = max(map,[],1);
posterior20 = b(ix);
[cnt bx] = hist(posterior20,[0:0.05:1]);
figure;stairs(bx,cnt,'r');hold on;xlabel('posterior probability for 20% of spikes');ylabel('counts');
map = bsxfun(@gt, cdfposteriors_multi,0.2);
[~,ix] = max(map,[],1);
posterior20 = b(ix);
[cnt bx] = hist(posterior20,[0:0.05:1]);
stairs(bx,cnt,'b');xlabel('posterior probability for 20% of spikes');ylabel('counts');


%% parameter analysis

load('gap_correlation_analysis_ifr')
tables = {corrtable10 corrtable20 corrtable40};
activitythresh = [6 50];
winsize = [10,20,40];
fr_type = {'IFR'};
aph = 0.01;ntrials=1000;

 summarytable = table([],[],[],[],[],[],[],[],[],[],'VariableNames',{'unit','FR_or_IFR','winsize',...
     'threshold','pneg','ppos','pdiff','numcases','prneg','prpos'});

files = {'singleunits_leq_1pcterr','singleunits_leq_2pcterr','singleunits_leq_4pcterr',...
    'singleunits_leq_1pctISI','singleunits_95pctpost_80pct','singleunits_90pctpost_85pct',...
    'multiunits_gt_1pcterr','multiunits_gt_2pcterr','multiunits_gt_4pcterr',...
    'multiunits_gt_1pctISI'};

for m = 1:length(files)
    ff = load_batchf(files{m});
    id = cell(3,1);
    for i = 1:length(ff)
        id{1} = [id{1};find(cellfun(@(x) contains(ff(i).name,x),tables{1}.unitid))];
        id{2} = [id{2};find(cellfun(@(x) contains(ff(i).name,x),tables{2}.unitid))];
        id{3} = [id{3};find(cellfun(@(x) contains(ff(i).name,x),tables{3}.unitid))];
    end

    for ii = 1:length(winsize)
        corrtable = tables{ii}(id{ii},:);
        
        for n = 1:length(activitythresh)

            if activitythresh(n) == 50
                negcorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
                poscorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
                sigcorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05);
                notsigcorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'>0.05);
                activecases = find(corrtable.pkFR>=activitythresh(n));
                numcases = length(activecases);
                numsignificant = length(find(corrtable.pkFR>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05));
            elseif activitythresh(n)==6
                negcorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
                poscorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
                sigcorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05);
                notsigcorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'>0.05);
                activecases = find(corrtable.pkactivity>=activitythresh(n));
                numcases = length(activecases);
                numsignificant = length(find(corrtable.pkactivity>=activitythresh(n) & ...
                    [corrtable.durcorr{:,2}]'<=0.05));
            end

            shuffcorr = [corrtable(activecases,:).durcorr{:,3}];
            shuffpval = [corrtable(activecases,:).durcorr{:,4}];

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

            pneg = length(find(randpropsignificantnegcorr>=length(negcorr)/numcases))/ntrials;
            ppos = length(find(randpropsignificantposcorr>=length(poscorr)/numcases))/ntrials;
            pdiff = length(find(randdiffprop>=abs((length(negcorr)/numcases)-(length(poscorr)/numcases))))/ntrials;
            prneg = length(negcorr)/numcases;
            prpos = length(poscorr)/numcases;

            summarytable = [summarytable;table(files(m),fr_type,winsize(ii),activitythresh(n),...
                pneg,ppos,pdiff,numcases,prneg,prpos,'VariableNames',{'unit','FR_or_IFR','winsize',...
            'threshold','pneg','ppos','pdiff','numcases','prneg','prpos'})];
        end
    end
end
summarytable
%%
save('parametertest','summarytable');

%% 
load('dur_multicorrelation_analysis_fr')
tables = {corrtable10 corrtable20 corrtable40};
activitythresh = [6 50];
winsize = [10,20,40];
fr_type = {'FR'};
aph = 0.01;ntrials=1000;

%  summarytable = table([],[],[],[],[],[],[],[],[],[],'VariableNames',{'unit','FR_or_IFR','winsize',...
%      'threshold','pneg','ppos','pdiff','numcases','prneg','prpos'});

files = {'singleunits_leq_1pcterr','singleunits_leq_2pcterr','singleunits_leq_4pcterr',...
    'singleunits_leq_1pctISI','singleunits_95pctpost_80pct','singleunits_90pctpost_85pct',...
    'multiunits_gt_1pcterr','multiunits_gt_2pcterr','multiunits_gt_4pcterr',...
    'multiunits_gt_1pctISI'};

for m = 1:length(files)
    ff = load_batchf(files{m});
    id = cell(3,1);
    for i = 1:length(ff)
        id{1} = [id{1};find(cellfun(@(x) contains(ff(i).name,x),tables{1}.unitid))];
        id{2} = [id{2};find(cellfun(@(x) contains(ff(i).name,x),tables{2}.unitid))];
        id{3} = [id{3};find(cellfun(@(x) contains(ff(i).name,x),tables{3}.unitid))];
    end

    for ii = 1:length(winsize)
        corrtable = tables{ii}(id{ii},:);
        
        for n = 1:length(activitythresh)

            if activitythresh(n) == 50
                negcorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable.corrs(:,1))<0);
                poscorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable.corrs(:,1))>0);
                sigcorr = find(corrtable.pkFR>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05);
                activecases = find(corrtable.pkFR>=activitythresh(n));

                numcases = length(activecases);
                numsignificant = length(find(corrtable.pkFR>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05));
            elseif activitythresh(n)==6
                negcorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable.corrs(:,1))<0);
                poscorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05 & cellfun(@(x) x(1),corrtable.corrs(:,1))>0);
                sigcorr = find(corrtable.pkactivity>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05);
                activecases = find(corrtable.pkactivity>=activitythresh(n));

                numcases = length(activecases);
                numsignificant = length(find(corrtable.pkFR>=activitythresh(n) & ...
                    cellfun(@(x) x(1),corrtable.corrs(:,2))<=0.05));
            end

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

            pneg = length(find(randpropsignificantnegcorr>=length(negcorr)/numcases))/ntrials;
            ppos = length(find(randpropsignificantposcorr>=length(poscorr)/numcases))/ntrials;
            pdiff = length(find(randdiffprop>=abs((length(negcorr)/numcases)-(length(poscorr)/numcases))))/ntrials;
            prneg = length(negcorr)/numcases;
            prpos = length(poscorr)/numcases;

            summarytable = [summarytable;table(files(m),fr_type,winsize(ii),activitythresh(n),...
                pneg,ppos,pdiff,numcases,prneg,prpos,'VariableNames',{'unit','FR_or_IFR','winsize',...
            'threshold','pneg','ppos','pdiff','numcases','prneg','prpos'})];
        end
    end
end
summarytable