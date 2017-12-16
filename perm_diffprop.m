function [p class] = perm_diffprop(invect1,invect2);
%permutation test to find p value for difference in proportions in invect1
%vs invect2
%invect1 and invect2 = vector of classes, can take integers or strings
%class = 1xk vector d
sampsize1 = length(invect1);
sampsize2 = length(invect2);
pooled = [invect1(:);invect2(:)];
class = unique(pooled);
n = 1000;%1000 trials
diffprop = NaN(n,length(class));
for i = 1:n
    shuffpool = pooled(randperm(length(pooled),length(pooled)));
    samp1 = shuffpool(1:sampsize1);
    samp2 = shuffpool(sampsize1+1:end);
    samp1prop = NaN(length(class),1);samp2prop = NaN(length(class),1);
    for k = 1:length(class)
        samp1prop(k) = histc(samp1,class(k))/sampsize1;
        samp2prop(k) = histc(samp2,class(k))/sampsize2;
    end
    diffprop(i,:) = samp1prop-samp2prop;
end


p = NaN(length(class),1);
for k = 1:length(class)
    invect1prop = histc(invect1,class(k))/sampsize1;
    invect2prop = histc(invect2,class(k))/sampsize2;
    p(k) = length(find(abs(diffprop(:,k))>=abs(invect1prop-invect2prop)))/n;
end

       