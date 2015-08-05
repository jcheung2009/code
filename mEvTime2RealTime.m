function realtime = mEvTime2RealTime(evtime)
%
% converts EvSuite Filetimes (i.e. 061719 = 6am, 17 minutes, 19 seconds) to
% hours from 0 to facilitate linear plots vs time
%
%

thelength = length(evtime);

hours = str2num(evtime(1:thelength-4));
minutes = str2num(evtime(thelength-3:thelength-2));
seconds = str2num(evtime(thelength-1:thelength));

realseconds = (seconds + (60*minutes) + (3600*hours));
realtime = hours + (minutes/60) + (seconds/3600);
