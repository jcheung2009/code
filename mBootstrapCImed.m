function [hiconf loconf] = mBootstrapCImed(invect,alpha)
%
%
% function [hiConf loConf] = mBootstrapConfInt(invect,alpha)
% 
% returns high and low confidence intervals based on bootstrapping inVect 
% alpha = 0.95 by default
%
% uses samples of 20 for length(invect)>40, or samples of 5
% uses 5000 iterations with replacement.
%

if(isempty(alpha))
    alpha = 0.95;
end

hithresh = alpha;
lothresh = 1-alpha;

numreps = 5000;
shuffvect = zeros(1,numreps);

parfor i=1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = median(thesamp);    
end

shuffvect = sort(shuffvect);


hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));
