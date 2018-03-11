function [meanshuff hi lo] = jc_BootstrapfreqdiffCI(invect1);
%invect1 and invect2 is vector of 1 and 0

alpha = 0.95;

hithresh = alpha;
lothresh = 1-alpha;

numreps = 5000;
shuffvect = zeros(1,numreps);

for i = 1:numreps
    thesamp1 = invect1(randi(length(invect1),1,length(invect1)));
    shuffvect(i) = abs(sum(thesamp1==1)-sum(thesamp1==2))/length(thesamp1);
end

meanshuff = mean(shuffvect);
hi = prctile(shuffvect,alpha*100);
lo = prctile(shuffvect,(1-alpha)*100);