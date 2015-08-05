function stderr = stderr(invect,dim)
%
% returns std error of invect's mean
%
%
if nargin==1, 
  % Determine which dimension STD will use
  dim = min(find(size(invect)~=1));
  if isempty(dim), dim = 1; end

  stderr = std(invect)/sqrt(length(invect));
else
  stderr = std(invect,1,dim)/sqrt(size(invect,dim));
end
