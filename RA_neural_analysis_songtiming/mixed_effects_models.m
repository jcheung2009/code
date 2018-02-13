%params and input
load('gap_correlation_analysis_multiunits2.mat');
activitythresh = 6;%zscore from shuffled


%% mixed model IFR ~ DUR 
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    subset(ind,:).dur = dur;
end

%test whether to add random effect of seqid on intercept. Yes
formula = 'spikes ~ dur + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>200);

%test whether to add random effect of seqid on slope. Yes (BIC is lower
%with independent estimation)
formula = 'spikes ~ dur + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on slope. No 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of birdid on intercept. No 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid) + (1|birdid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model, significant negative beta for dur 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared

%% mixed model IFR ~ DUR + Vol1 + Vol2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
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

%test whether to add random effect of seqid on intercept. Yes. CI for
%random effect on intercept is above 0 
%intercept
formula = 'spikes ~ dur + vol1 + vol2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>2000);%outliers

%test whether to add random effect of seqid on dur slope. Yes. 
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol1 slope. Yes. 
%BIC is lower when dur and vol are estimated together 
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol2 slope. Yes
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur slope. No
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1 slope. No
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol2 slope. Yes
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model: dur is still negatively correlated, vol2 is positively
%correlated 
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared

%% mixed model IFR ~ dur + dur1 + dur2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
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

%test whether to add random effect of seqid on intercept. Yes.
%intercept
formula = 'spikes ~ dur + dur1 + dur2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);%outliers

%test whether to add random effect of seqid on dur slope. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur1 slope. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur2 slope. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur slope. No. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur1 slope. No. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid) + (dur1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur2 slope. No. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid) + (dur2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model: significant  negative correlation with dur but not with dur1
%or dur2
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared

%% mixed model IFR ~ dur + vol1 + vol2 + dur1 + dur2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
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

%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>2000);%outliers

%test whether to add random effect of seqid on dur slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol1 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur1 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur slope. No.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur1 slope. No.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model: only dur is signficantly correlated
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')

%% mixed model IFR ~ vol1 
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

%test whether to add random effect of seqid on intercept. Yes
formula = 'spikes ~ vol1 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);

%test whether to add random effect of seqid on vol1. Yes
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1. Yes
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i)
mdl.Rsquared

%% %% mixed model IFR ~ vol2
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

%test whether to add random effect of seqid on intercept. Yes
formula = 'spikes ~ vol2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);

%test whether to add random effect of seqid on vol1. Yes
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1. Yes
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i)
mdl.Rsquared

%% mixed model dur ~ vol1
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    subset(ind,:).vol1 = vol1;
end


%test whether to add random effect of seqid on intercept. Yes
formula = 'dur ~ vol1 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol1. Yes
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula);
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula);
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. No
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula);
formula = 'dur ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

formula = 'dur ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula)