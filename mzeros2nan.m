function [filtout] = mzeros2nan(inVect)
%
%
%   function [filtout] = mzeros2nan(inVect)
%   replaces zeros with nans in inVect
%
%   
%

filtout = inVect;
for i=1:length(inVect)
   if(inVect(i) == 0)
       filtout(i)=NaN;
   end
end

return;
       
    
    