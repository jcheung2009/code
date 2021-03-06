function [dtnm]=fn2date(fn);
%extract datenum from filename

ISWAV=0;
p = findstr(fn,'.cbin');
if (length(p)<1)
    p=findstr(fn,'.ebin');
end
if (length(p)<1)
    p=findstr(fn,'.rec');
end
if (length(p)<1)
    p=findstr(fn,'.bbin');
end
if (length(p)<1)
    p=findstr(fn,'.wav');
    ISWAV=1;
end

if (length(p)<1)
    disp(['not rec cbin, ebin or bbin file?']);
    return;
end

if (ISWAV==0)
    p2=findstr(fn,'.');
    p3=find(p2==p(end));
    if (length(p3)<1)|(p3(1)<2)|(length(p2)<2)
        disp(['weird fn = ',fn]);
        return;
    end
    p = p2(p3-1);
    hr   = fn([(p(end)-6):(p(end)-5)]);
    mnut = fn([(p(end)-4):(p(end)-3)]);
    dy   = fn([p(end)-13:p(end)-12]);
    mnth = fn([p(end)-11:p(end)-10]);
    yr   = fn([p(end)-9:p(end)-8]);
    scnd='0';
else
    pp=findstr(fn,'_');
    yr = fn(pp(1)+3:pp(1)+4);
    mnth=fn(pp(1)+5:pp(1)+6);
    dy =fn(pp(1)+7:pp(1)+8);
    hr=fn(pp(1)+9:pp(1)+10);
    mnut=fn(pp(1)+11:pp(1)+12);
    ppp=findstr(fn,'.wav');
    scnd=fn(pp(1)+13:pp(1)+14);
end

hour = str2num(hr) + str2num(mnut)/60.0 + str2num(scnd)/3600.0;
day   = str2num(dy);
month = str2num(mnth);
year  = 2000 + str2num(yr);
dtnm = datenum([year,month,day,str2num(hr),str2num(mnut),str2num(scnd)]);
return;
