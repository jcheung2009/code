function write_krank_file(data, file)

fid = fopen(file,'wb','b');
numwrite = fwrite(fid, data, 'int16');

if numwrite ~= length(data)
  disp(['Not all of data was written for file: ', file])
end
fclose(fid);                                                                  

