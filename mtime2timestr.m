function [outtime] = mtime2timestr(thetime,PM)
%
% function [time] = mtime2timestr(thetime,PM)
%
% converts time in format hr:minute:second:ms AM/PM to hhmmss
% for comparing trigger times in EvTutor to recorded sound files
%
% PM is boolean and adds 12 hrs to the hour

colonidx = strfind(thetime,':');

hr = thetime(1:colonidx(1)-1);
minute = thetime(colonidx(1)+1:colonidx(2)-1);
second = thetime(colonidx(2)+1:colonidx(2)+2);

if(length(hr)==1)
    hr = [0 hr];
end

if(PM)
    hr = 12+str2num(hr);
    hr = num2str(hr);
end

outtime = [hr minute second];

return;
