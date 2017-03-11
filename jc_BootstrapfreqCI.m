function [meanshuff hi lo] = jc_BootstrapfreqCI(invect);
%invect is vector of 1 and 0

alpha = 0.95;

hithresh = alpha;
lothresh = 1-alpha;

numreps = 5000;
shuffvect = zeros(1,numreps);

for i = 1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = sum(thesamp)/length(thesamp);
end

meanshuff = mean(shuffvect);
hi = prctile(shuffvect,alpha*100);
lo = prctile(shuffvect,(1-alpha)*100);