function [ time ] = db_timing4( fvals )
%db_timing4 Summary of this function goes here
%   Detailed explanation goes here

time = zeros(length(fvals),1);
for i = 1:length(fvals)
    underscore_locator = find(fvals(i).fn=='_');
    year = str2double(fvals(i).fn(underscore_locator(1)+5:underscore_locator(1)+6))+2000;
    
    month = str2double(fvals(i).fn(underscore_locator(1)+3:underscore_locator(1)+4));
    
    days = str2double(fvals(i).fn(underscore_locator(1)+1:underscore_locator(1)+2));
    
    hours = str2double(fvals(i).fn(underscore_locator(2)+1:underscore_locator(2)+2));
    
    minutes = str2double(fvals(i).fn(underscore_locator(2)+3:underscore_locator(2)+4));
    
    if strcmpi(fvals(i).fn(underscore_locator(2)+5:underscore_locator(2)+6),'.-')
        seconds = str2double([fvals(i).fn(underscore_locator(2)+7) fvals(i).fn(underscore_locator(2)+8)]);
    else
        seconds = str2double(fvals(i).fn(underscore_locator(2)+6:underscore_locator(2)+7));
    end
    
    time(i) = datenum(year, month, days, hours, minutes, seconds);
end

