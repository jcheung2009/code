%% parameters and data files 
load('gap_correlation_analysis_singleunits.mat');
activitythresh = 6;%zscore from shuffled

%% data format
% each row contains information about the FR, duration of target element, 
%volume and duration of adjacent elements for a single trial in a specific 
%burst/sequence/unit/bird. 
head(dattable)

%% Is there a significant relationship between firing rate and duration of target element? 
%
%filter cases where activity is above threshold and normalize predictors
%
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    subset(ind,:).dur = dur;
end

%% 
% test whether to add random effect of seqid on intercept
formula = 'spikes ~ dur + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula)

%% 
%Std of the random effect on intercept is large
%% 
compare(mdl1,mdl2,'CheckNesting',true)
% Adding random effect of seqid on intercept improves model fit 

%% 
%Plot residuals, exclude outliers for better fit before testing whether to 
%add more random effects
figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);
%%
%test whether to add random effect of seqid on slope. YES
formula = 'spikes ~ dur + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of unitid on intercept. YES 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%%
%test whether to add random effect of unitid on slope. NO 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of birdid on intercept. NO 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid) + (1|birdid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%BIC is not lower with mdl2 
%%
%test whether to add random effect of birdid on slope. NO 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid) + (dur-1|birdid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%% 
%final model
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl = fitlme(subset,formula,'exclude',i)
mdl.Rsquared
%% 
%Duration of the target element is negatively correlated with FR such that
% a 1 std change in duration is correlated with a 0.6 Hz decrease. 

%% Is duration of target element still correlated with FR if we control for the volume of adjacent elements?
%
%filter cases where activity is above threshold and normalize predictors
%
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end
%%
%test whether to add random effect of seqid on intercept. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%Plot residuals, exclude outliers for better fit before testing whether to 
%add more random effects
figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);
%%
%test whether to add random effect of seqid on dur slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of seqid on vol1 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of seqid on vol2 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of seqid on dur1 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of seqid on dur2 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of unitid on intercept. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of unitid on dur slope. NO.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%%
%test whether to add random effect of unitid on vol1 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of unitid on vol2 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of unitid on dur1 slope. NO.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%test whether to add random effect of unitid on dur2 slope. YES.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)
%%
%final model
%
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i)
mdl.Rsquared
%
%If we hold the volume and duration of adjacent elements constant, the
%duration of the target element is still significantly negatively
%correlated with FR
