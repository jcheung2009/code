function make_raw(batchfile,Fs,f_type)

% function make_raw(batchfile,Fs,ftype)
% <batchfile>: batch containing files to convert to .b
% <Fs>: sampling rate of files in batchfile (dflt  = 44100)
% <ftype>: type of files in batchfile (dflt = 'w')

if ((nargin ~= 3) & (nargin ~= 2) & (nargin ~= 1)), help make_raw; return; end;
if (nargin == 1), Fs = 44100; f_type = 'w'; end;
if (nargin ==2), f_type = 'w'; end


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
   
   %if songfile exists, get it and resample
     if exist([songfile]);   
       song = soundin('',char(songfile),char(f_type));
       song  = resample(song,32e3,Fs);
     else
       disp(['cannot find ', songfile])
     end
%      
%      %create file name by parsing original file name
%      breaks = strfind(songfile,'.');
%      if isempty(breaks)
          songname = [songfile];
%      else 
%         songname = [songfile(1:breaks(end))];
%      end
%      nmbrpnts = length(song);
%      
     %create obs file
     krankwrite(char(songname),song);
     %create rec file
%      recname  = [songfile(1:breaks(end)),'rec'];
%      fid = fopen(char(recname),'a');
%      dateinfo = ['File created: ',date]; 
%      beginfo = ['begin rec =      0 ms'];triginfo = ['trig time =      0 ms']; endinfo = ['rec end = ', num2str(round(length(song)/32)),' ms']; 
%      freqinfo = ['ADFREQ =  32000']; sampinfo = ['Samples =  ', num2str(nmbrpnts)]; chaninfo = ['Chans =  0'];
%      fprintf(fid,'%s\n',dateinfo,beginfo,triginfo,endinfo,freqinfo,sampinfo,chaninfo);
%      fclose(fid);   
 end    
 fclose(meta_fid);
    
    
    