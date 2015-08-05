function gk_write_data(data, data_info, file)

if data_info.swab
  fid = fopen(file,'wb','b');
else
  fid = fopen(file,'wb');
end

numwrite = fwrite(fid, data, data_info.samp_type);
if numwrite ~= length(data)
  disp(['Not all of data was written for file: ', file])
end
fclose(fid);                                                                  

