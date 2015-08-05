function [] = delobs(delfile);

%delete observer .cbin .bbin and .rec files 
% from those listed in a text file created by quickscreen)

if exist(delfile)
   del_fid=fopen(delfile,'r')
else 
   pwd
   disp(['warning! cannot find ',delfile]);
   break
end   

del_flag=1;


while 1
  %get filename; check filetype
  soundfile = fscanf(del_fid,'%s',1);
  if isempty(soundfile)
       disp('End of files')
       break
  elseif length(soundfile)<6
       disp(['warning! current file is not obsfile: ',soundfile]); 
       disp(['skipping ',soundfile,'...']);
       del_flag=0;
  else 
       suffix=soundfile(length(soundfile)-4:length(soundfile));
       root=soundfile(1:length(soundfile)-5);
       del_flag=1;
       if del_flag==1;
          filtfile=[soundfile,'.filt'];
	      notefile=[soundfile,'.not.mat'];
	      spectfile=[soundfile,'.spect'];
      if ispc;
         if exist(soundfile)
            eval(['!del ' soundfile]);
	        disp(['deleting ',soundfile]);
	     end
	     if exist(filtfile)
            eval(['!del ' filtfile]);
	        disp(['deleting ',filtfile]);
	     end
         if exist(notefile)
           eval(['!del ' notefile]);
	       disp(['deleting ',notefile]);
	     end
          if exist(spectfile)
           eval(['!del ' spectfile]);
	       disp(['deleting ',spectfile]);
	     end
         
     end
     if isunix;
         if exist(soundfile)
            eval(['!rm -f ' soundfile]);
	        disp(['deleting ',soundfile]);
	     end
	     if exist(filtfile)
            eval(['!rm -f ' filtfile]);
	        disp(['deleting ',filtfile]);
	     end
         if exist(notefile)
           eval(['!rm -f ' notefile]);
	       disp(['deleting ',notefile]);
	     end
          if exist(spectfile)
           eval(['!rm -f ' spectfile]);
	       disp(['deleting ',spectfile]);
	     end
         
     end
     
     
       end
       
   end
end 

fclose(del_fid);
