function [randout] = mRandFromDist(inMtx,numcenters)
%
% function [randout] = mRandFromDist(inMtx,numcenters)
%
% returns numcenters random numbers from the ranges of inMtx. If inMtx is
% 1000 x 8 matrix, randout will be numcenters x 8, and each value will be
% random number within corresponding column of inMtx.
%

datasize = size(inMtx);
numdims = datasize(2);

randvect = zeros(1,datasize(1));
invect = zeros(1,datasize(1));

randout = zeros(numcenters,numdims);

for thecenter=1:numcenters    
    for i=1:numdims
        invect = inMtx(:,i);
        randvect = rand(1,length(invect)).*(min(invect)+(max(invect)-min(invect)));
        randout(thecenter,i) = randvect(randi(length(randvect)));
    end    
end