function []=krankwrite(songfile,song) 
%krankwrite(songfile,song) 
%songfile= destination path and file
%song = matlab sonogram matrix


% Maximum length of dcp song in sec 
  MAXSONGDUR = 100000000.0;

  nwbits = 16;
  wtype = 'int16';
  Fsw = 32000;

  name = [char(songfile), '.raw'];
  fidw = fopen(char(name),'w','b');

  songlen = length(song);
  songlen = songlen;
  maxsonglen = fix(MAXSONGDUR*Fsw);
  if songlen > maxsonglen
    songlen = maxsonglen;
    disp(['Data will be truncated for file: ', songfile])
  end

  numwrite = fwrite(fidw,song(1:songlen),wtype);
  if numwrite ~= songlen
    disp(['Not all of data was written for file: ', songfile])
  end
  fclose(fidw);

%create rec file
    recname  = [char(songfile),'.rec'];
    fid = fopen(char(recname),'a');
    freqinfo = ['ADFREQ = 32000']; 
    fprintf(fid,'%s\n',freqinfo);
    fclose(fid);   