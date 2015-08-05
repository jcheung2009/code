function rename_N_notmats(batchfile)

fid = fopen(char(batchfile));

while ~feof(fid)
    file = fscanf(fid,'%s',1);
       %if notefile exists, get it
     if exist([file])   
       load([file]);
     else
       disp(['cannot find ', file])
     end
    notefile = char(file(3:end));
    save(char(notefile),'Fs','labels','min_dur','min_int','offsets','onsets','sm_win','threshold');
end

