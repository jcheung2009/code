function cv = cv(invect,varargin)
% returns coefficient of variation of invect

if isempty(varargin)
    dim = 1;
else 
    dim = varargin{1};
end

  cv = sqrt(var(invect,'',dim,'omitnan'))./nanmean(invect,dim);
