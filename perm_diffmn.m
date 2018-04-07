function p = perm_diffmn(invect1,invect2);
%permutation test to find p value for difference in means in invect1
%vs invect2
sampsize1 = length(invect1);
sampsize2 = length(invect2);
pooled = [invect1(:);invect2(:)];
n = 10000;
diffmn = NaN(n,1);
for i = 1:n
    shuffpool = pooled(randperm(length(pooled),length(pooled)));
    samp1 = shuffpool(1:sampsize1);
    samp2 = shuffpool(sampsize1+1:end);
    diffmn(i,:) = mean(samp1)-mean(samp2);
end
p = length(find(abs(diffmn)>=abs(mean(invect1)-mean(invect2))))/n;



       