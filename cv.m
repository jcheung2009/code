function cv = cv(invect)
%
% returns coefficient of variation of invect
%

cv = sqrt(var(invect,'omitnan')) / nanmean(invect);