function gk_batch_sort

% To sort stim files in a batch file by file numbers

% Get batch file information and load in files.
batch_info = [];
batch_info = gk_batch_select(batch_info);
batch_info = gk_batch_read(batch_info)

file_order = zeros(batch_info.nfiles,2);
file_order(:,1) = [1:batch_info.nfiles]';
for ifile = 1:batch_info.nfiles
  [fdir,fname,fext] = fileparts(batch_info.filenames{ifile});
  strtmp = strread(fname,'%s',6,'delimiter','_');  % Adjust how many to read
%  file_order(ifile,:) = [ifile str2double(strtmp{end})];
  file_order(ifile,2) = str2double(strtmp{end});
end
file_order
file_order = sortrows(file_order,2)

[batchdir,batchname,ext,ver] = fileparts(batch_info.batchfilename);

fid = fopen(fullfile(batchdir,[batchname,'_sorted',ext]),'w')
for k = 1:batch_info.nfiles
  ifile = file_order(k,1);
  stimfile = batch_info.filenames{ifile};
  fprintf(fid,'%s\n', stimfile);
end
fclose(fid);
