function start_time = time2datenum(str);
%HH:MM from treatment time to time in seconds since 7 AM

start_time = datevec(str,'HH:MM');
day_st = datevec('07:00','HH:MM');
start_time = etime(start_time,day_st);
