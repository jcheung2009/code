

invect = trial2;

flds = fieldnames(invect);

for i = 1:length(flds)
    a = cellfun(@(x) x.fv(:,2),invect.(flds{i}),'UniformOutput',false);
    [hi lo] = cellfun(@mBootstrapCI,a,'UniformOutput',true);
    meanfv.(flds{i}) = [hi',lo',cellfun(@mean,a,'UniformOutput',true)'];
end

%plot learning trial no norm  
num = 3;
num2 = 2;
nbase = length(meanfv.(flds{1}));
nlearn = length(meanfv.(flds{2}));
nrecov = length(meanfv.(flds{3}));
for i = 1:nbase
    figure(num);hold on;subplot(2,1,num2);
    plot([i i],[meanfv.(flds{1})(i,1) meanfv.(flds{1})(i,2)],'k');hold on;
    plot(i,meanfv.(flds{1})(i,3),'ok');hold on;
end
for i = 1:nlearn
    figure(num);hold on;subplot(2,1,num2);
    plot([i+nbase i+nbase],[meanfv.(flds{2})(i,1) meanfv.(flds{2})(i,2)],'r');hold on;
    plot(i+nbase,meanfv.(flds{2})(i,3),'or');hold on;
end
for i = 1:nrecov
    figure(num);hold on;subplot(2,1,num2);
    plot([i+nbase+nlearn i+nbase+nlearn],[meanfv.(flds{3})(i,1) meanfv.(flds{3})(i,2)],'k');hold on;
    plot(i+nbase+nlearn,meanfv.(flds{3})(i,3),'ok');hold on;
end

%plot learning trial norm by baseline mean
basemean = sum(cellfun(@(x) sum(x.fv(:,2)),invect.baseline))/sum(cellfun(@(x) length(x.fv(:,2)),invect.baseline));

for i = 1:length(flds)
    a = cellfun(@(x) x.fv(:,2)/basemean,invect.(flds{i}),'UniformOutput',false);
    [hi lo] = cellfun(@mBootstrapCI,a,'UniformOutput',true);
    meanfv.(flds{i}) = [hi',lo',cellfun(@mean,a,'UniformOutput',true)'];
end

num = 4;
num2 = 2;
nbase = length(meanfv.(flds{1}));
nlearn = length(meanfv.(flds{2}));
nrecov = length(meanfv.(flds{3}));
for i = 1:nbase
    figure(num);hold on;subplot(2,1,num2);
    plot([i i],[meanfv.(flds{1})(i,1) meanfv.(flds{1})(i,2)],'k');hold on;
    plot(i,meanfv.(flds{1})(i,3),'ok');hold on;
end
for i = 1:nlearn
    figure(num);hold on;subplot(2,1,num2);
    plot([i+nbase i+nbase],[meanfv.(flds{2})(i,1) meanfv.(flds{2})(i,2)],'r');hold on;
    plot(i+nbase,meanfv.(flds{2})(i,3),'or');hold on;
end
for i = 1:nrecov
    figure(num);hold on;subplot(2,1,num2);
    plot([i+nbase+nlearn i+nbase+nlearn],[meanfv.(flds{3})(i,1) meanfv.(flds{3})(i,2)],'k');hold on;
    plot(i+nbase+nlearn,meanfv.(flds{3})(i,3),'ok');hold on;
end

%plot recovery days
num = 7
nrecov = length(meanfv.(flds{3}));
for i = 1:nrecov
    figure(num);hold on;
    plot([i i],[meanfv.(flds{3})(i,1) meanfv.(flds{3})(i,2)],'r');hold on;
    plot(i,meanfv.(flds{3})(i,3),'or');hold on;
end

    