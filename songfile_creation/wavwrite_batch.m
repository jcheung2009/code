function wavwrite_batch(batchfile,f_type)
% 
% function wavwrite_batch(batchfile,f_type)
% <batchfile>:a batchfile containing names of soundfiles to convert
% <f_type>:type of sound file referenced

%open batch_file
meta_fid=fopen([batchfile]);
if meta_fid == -1 | batchfile == 0
      disp('cannot open file' )
      disp (batchfile)
      return
end

while 1
   %get songfile name
     songfile = fscanf(meta_fid,'%s',1);
   %end when there are no more songfiles 
     if isempty(songfile);
        break
     end
   
   %if songfile exists, get it
     if exist([songfile]);   
       [song,fs] = soundin('',char(songfile),char(f_type));
     else
       disp(['cannot find ', songfile])
     end
    
     %resample and normalize
     song = song./max(abs(song));
     song = song*.9;
     song = resample(song,44100,fs);
     
     %create file name by parsing original file name
     breaks = strfind(songfile,'.');
     if isempty(breaks)
         songname = [songfile,'.wav'];
     else 
        songname = [songfile(1:breaks(end)),'wav'];
     end

    wavwrite(song,44100,16,char(songname));

 end    
 fclose(meta_fid);