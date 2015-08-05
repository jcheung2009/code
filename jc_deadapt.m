%deadaptation plots using "trial" structures

block = trial1;
fignum = 3;

%baseline
numbaselinepts = sum(cellfun(@length,block.baseline.vals));
numlearningpts = sum(cellfun(@length,block.learning.vals));
numrecoverypts = sum(cellfun(@length,block.recovery.vals));

baseind = 1:numbaselinepts;
learnind = numbaselinepts+[1:numlearningpts];
recovind = (numbaselinepts+numlearningpts)+[1:numrecoverypts];

base_runBS= [];
for i = 1:length(block.baseline.vals)
    runBS = mRunningBootstrap(block.baseline.vals{i}(:,2),50);
    base_runBS = [base_runBS;runBS];
end
figure(fignum);hold on;
plot(baseind,base_runBS(:,1),'k','LineWidth',2);
plot(baseind,base_runBS(:,2:3),'k','LineWidth',0.5);

ind = [];
for i = 1:length(block.baseline.vals)
    if i == 1
        ind(i,:) = [1 length(block.baseline.vals{i})];
    else
        ind(i,:) = [ind(i-1,2) + [1 length(block.baseline.vals{i})]];
    end
end
  
for i = 1:length(ind)
    figure(fignum);hold on;
    plot([ind(i,1) ind(i,1)],[3460 3600],'k','LineWidth',2);
end

learn_runBS = [];
for i = 1:length(block.learning.vals);
    runBS = mRunningBootstrap(block.learning.vals{i}(:,2),50);
    learn_runBS = [learn_runBS; runBS];
end
figure(fignum);hold on;
plot(learnind,learn_runBS(:,1),'r','LineWidth',2);
plot(learnind,learn_runBS(:,2:3),'r','LineWidth',0.5);

ind = [];
for i = 1:length(block.learning.vals)
    if i == 1
        ind(i,:) = [numbaselinepts + [1 length(block.learning.vals{i})]];
    else
        ind(i,:) = [ind(i-1,2) + [1 length(block.learning.vals{i})]];
    end
end
  
for i = 1:length(ind)
    figure(fignum);hold on;
    plot([ind(i,1) ind(i,1)],[3460 3600],'r','LineWidth',2);
end

recov_runBS = [];
for i = 1:length(block.recovery.vals);
    runBS = mRunningBootstrap(block.recovery.vals{i}(:,2),50);
    recov_runBS = [recov_runBS; runBS];
end
figure(fignum);hold on;
plot(recovind,recov_runBS(:,1),'b','LineWidth',2);
plot(recovind,recov_runBS(:,2:3),'b','LineWidth',0.5);

ind = [];
for i = 1:length(block.recovery.vals)
    if i == 1
        ind(i,:) = [(numbaselinepts+numlearningpts) + [1 length(block.recovery.vals{i})]];
    else
        ind(i,:) = [ind(i-1,2) + [1 length(block.recovery.vals{i})]];
    end
end
  
for i = 1:length(ind)
    figure(fignum);hold on;
    plot([ind(i,1) ind(i,1)],[3460 3600],'b','LineWidth',2);
end