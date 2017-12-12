function [meanCV hiconf loconf] = mBootstrapCI_CV(invect,varargin)
% returns mean and high and low confidence intervals of the CV 
% based on bootstrapping inVect
% alpha = 0.95 by default


if(isempty(varargin))
    alpha = 0.95;
else
    alpha = varargin{1};
end

hithresh = alpha;
lothresh = 1-alpha;

if ~isempty(find(isnan(invect)))
    removeind = find(isnan(invect));
    invect(removeind) = [];
end

numreps = 1000;
shuffvect = zeros(1,numreps);

for i=1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = cv(thesamp);    
end

shuffvect = sort(shuffvect);

meanCV = mean(shuffvect);
hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));
