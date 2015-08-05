function filtdata = filter_data(data,filt_info)

if strcmp(filt_info.type,'none')
  filtdata = data;
  return;
end
filtdata = filtfilt(filt_info.b,filt_info.a, data);

end
