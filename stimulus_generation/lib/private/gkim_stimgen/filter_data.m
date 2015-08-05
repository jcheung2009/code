function filtdata = filter_data(data,filt_info)

if strcmp(filt_info.type,'none')
  filtdata = data;
  return;
end
  
if filt_info.do_filtfilt
  filtdata = filtfilt(filt_info.b,filt_info.a, data);
else
  z = [];
  [filtdatad, z] = filter(filt_info.b, filt_info.a, data, z);
  % Note filtered song corrected for the delay is shorter in length!
  filtdata = filtdatad(1+filt_info.ndelay:length(filtdatad));
end
