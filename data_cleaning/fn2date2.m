function [dtnm]=fn2date2(fn);
%extract datenum from filename (for old version of evtaf for lman lesion data) 


p = findstr(fn,'.cbin');
p2=findstr(fn,'.');
p3=find(p2==p(end));
if (length(p3)<1)|(p3(1)<2)|(length(p2)<2)
    disp(['weird fn = ',fn]);
    return;
end
p = p2(p3-1);
hr   = fn([(p(end)-4):(p(end)-3)]);
mnut = fn([(p(end)-2):(p(end)-1)]);
dy   = fn([p(end)-11:p(end)-10]);
mnth = fn([p(end)-9:p(end)-8]);
yr   = fn([p(end)-7:p(end)-6]);
scnd='0';


hour = str2num(hr) + str2num(mnut)/60.0 + str2num(scnd)/3600.0;
day   = str2num(dy);
month = str2num(mnth);
year  = 2000 + str2num(yr);
dtnm = datenum([year,month,day,str2num(hr),str2num(mnut),str2num(scnd)]);
return;
