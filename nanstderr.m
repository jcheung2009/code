function stderr = nanstderr(invect,dim)
%
% returns std error of invect's mean treating NaNs as missing
%
%

nans = ~isnan(invect);



if nargin==1, 
  % Determine which dimension STD will use
  dim = min(find(size(invect)~=1));
  if isempty(dim), dim = 1; end
    
  nans = ~isnan(invect);
  stderr = nanstd(invect)/sqrt(length(nans));
  else
  stderr = nanstd(invect,1,dim)/sqrt(size(nans,dim));
end



