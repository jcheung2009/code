function cv = cv_median(invect)
%
% returns coefficient of variation of the median of invect
%

cv = sqrt(mVar_median(invect)) / median(invect);