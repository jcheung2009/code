function cntrng = jc_makecntrng(tempsize,mincount,maxcount,not,mode,th,and);
%makes cntrng structure for jc_autolabel to be used with template

cntrng = struct();

for i = 1:tempsize
    cntrng(i).MIN = mincount(i);
    cntrng(i).MAX = maxcount(i);
    cntrng(i).NOT = not(i);
    cntrng(i).MODE = mode(i);
    cntrng(i).TH = th(i);
    cntrng(i).AND = and(i);
    cntrng(i).BTMIN = 0;
end
