function cv = cv(invect,dim)
%
% returns coefficient of variation of invect
%

  cv = sqrt(var(invect,'omitnan')) / nanmean(invect);
