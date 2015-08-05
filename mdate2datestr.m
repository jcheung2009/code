function [datestr] = mdate2datestr(thedate)
%
% function [datestr] = mdate2datestr(thedate)
% 
% converts dates in format mm/dd/yyyy or m/d/yyyy to ddmmyy for 
% use with wav or cbin files created with EvSAP/EvTAF
%
%

slashidx = strfind(thedate,'/');

month = thedate(1:slashidx(1)-1);
day = thedate(slashidx(1)+1:slashidx(2)-1);
year = thedate(slashidx(2)+1:length(thedate));

year = year(length(year)-1:length(year));
if(length(day)==1)
    day = ['0' day];
end
if(length(month)==1)
    month = ['0' month];
end

datestr = [day month year];

return;