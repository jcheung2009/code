function move_data(destination)

%notes...


menu_in=1;
%get name of batch file containing name sof files to be copied
if menu_in==1
  meta_fid = -1;
  metafile = 0;
  while meta_fid == -1 | metafile == 0
   disp('select batchfile');
   [metafile, pathname]=uigetfile('*','select batchfile')
   meta_fid=fopen([pathname, metafile]);
   if meta_fid == -1 | metafile == 0
      disp('cannot open file' )
      disp (metafile)
   end
  end
else
  meta_fid=fopen(optional_batch);
  if meta_fid == -1
      disp('cannot open file' )
      disp(optional_batch)
  end    
end

while 1

  %get soundfile name
   filename = fscanf(meta_fid,'%s',1)
   if isempty(filename)
      disp('End of filtfiles')
      break
   end
   
   
   copyfile(filename,destination);
   %eval(['cp ',filename,' ',destination]);
   
   
   
   
end   

