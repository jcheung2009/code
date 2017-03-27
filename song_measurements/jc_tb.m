function tb = jc_tb(invect,st_hr, st_min);
%time base vlsor aligned to first hour of singing in
%morning, in seconds


    
    

 dt = datevec(invect(1,1));

 if isempty(st_hr) && isempty(st_min)
     st_hr = 0;
     st_min = 0;
     %st_hr = dt(:,4);
     %st_min = dt(:,5);
 end

 if size(invect,2) > 1
    tb = invect(:,1) - datenum([dt(1) dt(2) dt(3) st_hr st_min 0]);
 elseif size(invect,2) == 1
     tb = invect - datenum([dt(1) dt(2) dt(3) st_hr st_min 0]);
 end
tb = datevec(tb);
tb = etime(tb,zeros(size(tb)));

