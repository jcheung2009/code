%params and input
load('gap_multicorrelation_analysis_fr.mat');
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),dattable10.unitid))];
end
dattable = dattable10(id,:);

%% mixed model FR ~ DUR 
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    subset(ind,:).dur = dur;
end

%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>400);%outliers

vars = {'+ (dur-1|unitid:seqid)',...
    '+ (1|unitid)','+ (dur-1|unitid)','+ (1|birdid)',...
    '+ (dur-1|birdid)'};
formula1 = 'spikes ~ dur + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model: dur beta = -1.21, p = 0.07
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')

%% mixed model FR ~ DUR + VOL1 + VOL2
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
end


%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>400);%outliers

vars = {'+ (dur-1|unitid:seqid)','+ (vol1-1|unitid:seqid)',...
    '+ (vol2-1|unitid:seqid)',...
    '+ (1|unitid)','+ (dur-1|unitid)','+ (vol1-1|unitid)',...
    '+ (vol2-1|unitid)','+ (1|birdid)',...
    '+ (dur-1|birdid)','+ (vol1-1|birdid)','+ (vol2-1|birdid)'};
formula1 = 'spikes ~ dur + vol1 + vol2 + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model: dur beta = -0.98, p = 0.11
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')

%% mixed model IFR ~ dur + dur1 + dur2 
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end

%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur + dur1 + dur2';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + dur1 + dur2 + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>400);%outliers

vars = {'+ (dur-1|unitid:seqid)','+ (dur1-1|unitid:seqid)',...
    '+ (dur2-1|unitid:seqid)',...
    '+ (1|unitid)','+ (dur-1|unitid)','+ (dur1-1|unitid)',...
    '+ (dur2-1|unitid)','+ (1|birdid)',...
    '+ (dur-1|birdid)','+ (dur1-1|birdid)','+ (dur2-1|birdid)'};
formula1 = 'spikes ~ dur + dur1 + dur2 + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model: dur beta = -2, p = 0.0046
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')

%% dur ~ dur1 (strongly negatively correlated) 
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    subset(ind,:).dur1 = dur1;
end

%test whether to add random effect of seqid on intercept. Yes.
formula = 'dur ~ dur1';
mdl1 = fitlme(subset,formula);
formula = 'dur ~ dur1 + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>100);%outliers

vars = {'+ (dur1-1|unitid:seqid)',...
    '+ (1|unitid)','+ (dur1-1|unitid)',...
    '+ (1|birdid)','+ (dur1-1|birdid)'};
formula1 = 'dur ~ dur1 + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model:
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')

%% dur ~ vol1 (negatively correlated but not significantly) 
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    subset(ind,:).vol1 = vol1;
end

%test whether to add random effect of seqid on intercept. Yes.
formula = 'dur ~ vol1';
mdl1 = fitlme(subset,formula);
formula = 'dur ~ vol1 + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>100);%outliers

vars = {'+ (vol1-1|unitid:seqid)',...
    '+ (1|unitid)','+ (vol1-1|unitid)',...
    '+ (1|birdid)','+ (vol1-1|birdid)'};
formula1 = 'dur ~ vol1 + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model:
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')


%% dur1 ~ vol1 (negatively correlated but not significant) 
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & ...
        strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    subset(ind,:).vol1 = vol1;
end

%test whether to add random effect of seqid on intercept. Yes.
formula = 'dur1 ~ vol1';
mdl1 = fitlme(subset,formula);
formula = 'dur1 ~ vol1 + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>40);%outliers

vars = {'+ (vol1-1|unitid:seqid)',...
    '+ (1|unitid)','+ (vol1-1|unitid)',...
    '+ (1|birdid)','+ (vol1-1|birdid)'};
formula1 = 'dur1 ~ vol1 + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model:
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')



%% mixed model IFR ~ dur + vol1 + vol2 + dur1 + dur2 (independent covariance among variables) 
cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
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
subset.burstid = nominal(subset.burstid);

%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>400);%outliers

vars = {'+ (dur-1|unitid:seqid)','+ (vol1-1|unitid:seqid)',...
    '+ (vol2-1|unitid:seqid)','+ (dur1-1|unitid:seqid)','+ (dur2-1|unitid:seqid)',...
    '+ (1|unitid)','+ (dur-1|unitid)','+ (vol1-1|unitid)',...
    '+ (vol2-1|unitid)','+ (dur1-1|unitid)','+ (dur2-1|unitid)','+ (1|birdid)',...
    '+ (dur-1|birdid)','+ (vol1-1|birdid)','+ (vol2-1|birdid)',...
    '+ (dur1-1|birdid)','+ (dur2-1|birdid)'};
formula1 = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + (1|unitid:seqid)';
for m = 1:length(vars)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
    end 
end

%final model: dur beta = -1.76, pval = 0.0088
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')



%% mixed model IFR ~ dur + vol1 + vol2 + dur1 + dur2 (non-independent covariance among variables) 

cases = unique(dattable(:,{'unitid','seqid','burstid'}));
subset = dattable;
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
subset.burstid = nominal(subset.burstid);

%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>600);%outliers

vars = {'dur+','vol1+','vol2+','dur1+','dur2+','burstid+'};
vars2 = {'+(1|unitid:seqid)','+(1|unitid)','+(1|birdid)'};
formula1 = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid';
for m = 1:length(vars2)
    mdl1 = fitlme(subset,formula1,'exclude',i);
    formula2 = [formula1,vars2{m}];
    mdl2 = fitlme(subset,formula2,'exclude',i);
    try
        t=compare(mdl1,mdl2,'CheckNesting',true)
    catch
        continue
    end
    if t.pValue <=0.05
        formula1=formula2;
        for n = 1:length(vars)
            mdl1 = fitlme(subset,formula1,'exclude',i);
            formula2 = insertBefore(formula1,vars2{m}(3:end),vars{n});
            mdl2 = fitlme(subset,formula2,'exclude',i);
            try 
                t=compare(mdl1,mdl2,'CheckNesting',true)
            catch
                continue
            end
            if t.pValue<=0.05
                formula1=formula2;
            end
        end
    end 
end

%final model: 
mdl = fitlme(subset,formula1,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')
