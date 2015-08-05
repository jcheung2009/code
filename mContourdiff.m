function [diffVect] = mContourdiff(contours)
%
%
% [totaldiff] = mContourdiff(contours)
%
% computes absolute difference between each pitch contour in 'contours'
% and the avg pitch contour, and normalizes by number of contours
%
%

meanContour = mean(contours');
diffMtx = zeros(size(contours));

numcontours = size(contours);

diffVect = zeros(numcontours(2),1);
totdiff = 0;
for i=1:numcontours(2);
    thediff = abs(contours(:,i)-meanContour');
    totdiff = totdiff + thediff;
    diffMtx(:,i) = totdiff;
    diffVect(i) = mean(thediff);
end

avgdiff = totdiff / numcontours(2);