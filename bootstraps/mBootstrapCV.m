function [shuffvect] = mBootstrapCV(invect)
%
%
% function [shuffvect] = mBootstrap(invect)
% 
% returns bootstrapped distribution of CV values for invect
%
% uses samples of length(invect)
% uses 5000 iterations with replacement.
%

numsamps = length(invect);
numreps = 5000;
shuffvect = zeros(1,numreps);

for i=1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = cv_median(thesamp);    
end

shuffvect = sort(shuffvect);