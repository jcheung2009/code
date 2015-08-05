function wf = read_raw_file(fname, ftype)


fid = fopen(fname);
wf = fread(fid,inf, ftype);
fclose(fid);