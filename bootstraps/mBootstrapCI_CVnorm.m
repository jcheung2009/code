function [meanCV hiconf loconf] = mBootstrapCI_CVnorm(invect,normcv,alpha)
%
%normcv = mean cv of invect2 that you are normalizing invect1 to

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

if(isempty(alpha))
    alpha = 0.95;
end

hithresh = alpha;
lothresh = 1-alpha;

if(length(invect)<40)
    numsamps = 30;
else
    numsamps = 5;
end

numreps = 10000;
shuffvect = zeros(1,numreps);

for i=1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = cv(thesamp)/normcv;    
end

shuffvect = sort(shuffvect);

meanCV = mean(shuffvect);
hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));