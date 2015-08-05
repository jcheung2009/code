function [entVect] = mContourEnt(contours)
%
%
% [entVect] = mContourEnt(contours)
%
% computes entropy of pitch contours and returns vector of entropy values
%
%

numcontours = size(contours);

entVect = zeros(numcontours(2),1);

for i=1:numcontours(2);
    theHist = hist(contours(:,i),256);
    theHist = theHist / sum(theHist);
    
    theEnt = (theHist .* log2(theHist)) / log2(numcontours(1));
    theEnt(isnan(theEnt)) = 0;
    theEnt = -1*sum(theEnt);
    %theEnt = -1*sum(contours(:,i).*log2(contours(:,i)))/log2(length(contours(:,i)));
    entVect(i) = theEnt;
end

