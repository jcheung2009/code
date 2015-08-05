function gk_batch_edit

% 
% gk_batch_edit
%
% When creating a batch file for stim files, you typically copy from rc
% files.  But rc files have "stim add stimuli/noise/xxx.raw' This code
% reads in a batch file and removes "stim add stimuli/noise/' leaving only
% file names.
%

% Get batch file information and load in files.
batch_info = [];
batch_info = gk_batch_select(batch_info);
batch_info = gk_batch_read(batch_info)

[batchdir,batchname,ext,ver] = fileparts(batch_info.batchfilename);
fid = fopen([batchdir,'/',batchname,'_new',ext],'w');
for ifile = 1:batch_info.nfiles
  
  batchline = batch_info.filenames{ifile};
  filetmp = strread(batchline,'%s','delimiter',' ');
  [fdir,fname,fext] = fileparts(filetmp{end});
  filename = [fname fext];
  fprintf(fid,'%s\n',filename);
  
end
fclose(fid);
