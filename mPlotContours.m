function [out] = mPlotContours(contours,color,fignum)
%
%
% [out] = mPlotContours(contours,color,fignum)
%
% plots mean and stderr pitch contours, appends to figure fugnum if fignum
% exists and is > 0. 
%
%

if(~fignum)
    figure();
else
    figure(fignum);
end

hold on;

plot(mean(contours')+stderr(contours'),color);
plot(mean(contours')-stderr(contours'),color);
plot(mean(contours'),color);

out = mean(contours');

hold off;