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
       if  ~strcmp(suffix,'.cbin') & ~strcmp(suffix,'.bbin')
         disp(['warning! current file is not obsfile: ',soundfile]); 
         disp(['skipping ',soundfile,'...']);
         del_flag=0;
       else 
         del_flag=1;
       end
       if del_flag==1;
          cbinfile=[root,'.cbin'];
	  bbinfile=[root,'.bbin'];
	  recfile=[root,'.rec'];
      if ispc;
         if exist(cbinfile)
            eval(['!del ' cbinfile]);
	        disp(['deleting ',cbinfile]);
	     end
	     if exist(bbinfile)
            eval(['delete ' bbinfile]);
	        disp(['deleting ',bbinfile]);
	     end
         if exist(recfile)
           eval(['!del ' recfile]);
	       disp(['deleting ',recfile]);
	     end
     end
     if isunix;
         if exist(cbinfile)
            eval(['!rm -f ' cbinfile]);
	        disp(['deleting ',cbinfile]);
	     end
	     if exist(bbinfile)
            eval(['rm -f ' bbinfile]);
	        disp(['deleting ',bbinfile]);
	     end
         if exist(recfile)
           eval(['!rm -f ' recfile]);
	       disp(['deleting ',recfile]);
	     end
     end
       end
       
   end
end 

fclose(del_fid);
