function     [out]=cooper()



%set filt_flag =1 in order to have files filtered
filt_flag=0;
F_low=500;
F_high=8000;


%get name of metafile containing songfile names

meta_fid = -1;
metafile = 0;
while meta_fid == -1 | metafile == 0 | metafile == ''
   disp('select batchfile');
   [metafile, pathname]=uigetfile('*','select batchfile')
   meta_fid=fopen([pathname, metafile]);
   if meta_fid == -1 | metafile == 0
      disp('cannot open file' )
      disp (metafile)
   end
end

%set paths for storage and retrieval, for now default to pathname
path_songfile = pathname;
path_notefile = pathname;
path_filtfile = pathname;
path_spectfile = pathname;

%get filetype, later versions of read program can be smarter about this

disp('What is type of sound file? [b]')
disp(' b = binary from mac')
disp(' w = wavefile (i.e. cbs)')
disp(' d = dcpfile')
disp(' f = foosong/gogo (sets Fs = 32000)')

filetype = 'null';
while strcmp(filetype,'null')
  temp=input('','s');
  if isempty(temp) | (strcmp(temp,'b') | strcmp(temp,'B') | strcmp(temp,'bin') | strcmp (temp, 'binary'));
     filetype = 'b';
  elseif strcmp(temp,'w')  | strcmp(temp,'wav') | strcmp(temp,'W')
     filetype = 'w';
  elseif strcmp(temp,'d')  | strcmp(temp,'dcp') | strcmp(temp,'D')
     filetype = 'd';  
  elseif strcmp(temp,'f')  | strcmp(temp,'F')
     filetype = 'f';  
     else
     disp('Unacceptable! Pick again')
  end
end

%get default sample rate

default_Fs=input('What is sample rate (samples/sec)? [32000] ');
if default_Fs == []; default_Fs = 32000; end

%main program: cycle through sound files until end or quit command

while 1
   
     
   %get soundfile name
   soundfile = fscanf(meta_fid,'%s',1)
   if (soundfile==[])
      disp('End of songfiles')
      break
   end
   
  
  %read soundfile
  [rawsong,Fs]=soundin(path_songfile, soundfile, filetype);
     
     %unless Fs has been read from the file use the default value which was
     %set by the user or previously read in from a note file
     if Fs == -1; Fs = default_Fs; end
   if filt_flag==1;
     %filter soundfile
     disp('filtering song...');
     filtsong=bandpass(rawsong,Fs,F_low,F_high);
     d_song=filtsong;  
   else 
     d_song=rawsong;
   end
    
  
  %set time axis for display
     
   time_d_song=[0:length(d_song)-1]*1000/Fs;  %vector for time axis
  
  %mark song starts and ends etc
   plot(time_d_song,d_song);
   xmin=time_d_song(1);
   xmax=time_d_song(length(time_d_song));
   set(gca,'xlim',[xmin xmax]);
   title(soundfile);
   pause;
   
end

fclose(meta_fid);
