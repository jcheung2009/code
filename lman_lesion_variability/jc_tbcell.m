function tbcell = jc_tbcell(cell)
%time base vlsor cell aligned to first hour of singing in
%morning, in seconds

%determine start hour
st_hr = cellfun(@(x) datevec(x(1,1)),cell,'UniformOutput',false);
st_hr = min(cellfun(@(x) x(:,4),st_hr));

%
for i = 1:length(cell)
    dt = datevec(cell{i}(1,1));
    tb = cell{i}(:,1) - datenum([dt(1) dt(2) dt(3) st_hr 0 0]);
    tb = datevec(tb);
    tbcell{i} = etime(tb,zeros(size(tb)));
end


