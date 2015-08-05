function batch_info = gk_batch_read(batch_info)

ifile = 0;
while 1
  filename = fgetl(batch_info.fid);
  % Check for whitespace here!
  spaceflag = 0;
  if isspace(filename)
    spaceflag = 1;
  end
%  if (~ischar(filename)) | isempty(filename) | spaceflag
  if (~ischar(filename))
    disp('End of batch file reached.')
    break
  end
  if ~(isempty(filename) | spaceflag)
    if filename(1) ~= '#'  %GK: one can comment out files
      ifile = ifile+1;
      batch_info.filenames{ifile} = filename(isspace(filename)==0); % Remove extra spaces
%       batch_info.filenames{ifile} = filename;
    end
  end
end

batch_info.nfiles = ifile;

fclose(batch_info.fid);
