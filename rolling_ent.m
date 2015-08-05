function [entout] = rolling_ent(inMtx)
%
% 
%
%
% 
%
%


entout = zeros(1,size(inMtx,2));
for i=1:length(entout)
    specDensity = abs(inMtx(:,i));
    specDensity = specDensity / sum(specDensity);
    theEnt = -1*sum(specDensity.*log2(specDensity))/log2(length(specDensity));
    %theEnt = -(specDensity'*log2(specDensity));
    entout(i) = theEnt;
end
