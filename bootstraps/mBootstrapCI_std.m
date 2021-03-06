function [meanstd hiconf loconf] = mBootstrapCI_std(invect,varargin)
%
%
% function [meanCV hiConf loConf] = mBootstrapCI_CV(invect,alpha)
% 
% returns mean and high and low confidence intervals of the CV 
% based on bootstrapping inVect 
% 
% alpha = 0.95 by default
%
% uses samples of 20 for length(invect)>40, or samples of 5
% uses 10000 iterations with replacement.
%

if(isempty(varargin))
    alpha = 0.95;
else
    alpha = varargin{1};
end

hithresh = alpha;
lothresh = 1-alpha;


if(length(invect)<40)
    numsamps = 5;
else
     numsamps = length(invect);
end


numreps = 10000;
shuffvect = zeros(1,numreps);

for i=1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = nanstd(thesamp);    
end

shuffvect = sort(shuffvect);

meanstd = mean(shuffvect);
hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));