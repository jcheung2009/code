% Crude script to load in song file and edit it.

songfile = input('Enter songfile name (full path): ','s')
[path_songfile,songbasename,sext,sver] = fileparts(songfile)
songname = [songbasename,sext,sver]

% get filetype, later versions of read program can be smarter about this

disp('What is type of sound file? [w]')
disp(' b = binary from mac')
disp(' w = wavefile (i.e. cbs)')
disp(' d = dcpfile')
disp(' filt = .filt file from uisonganal')
disp(' foo = foosong/gogo (sets Fs = 32000)')
disp(' o = observer file (last/song channel)')
disp(' o1r = observer file (second to last)')

filetype = 'null';
while strcmp(filetype,'null')
  temp=input(' ','s');
  if strncmpi(temp,'b',1);
    filetype = 'b';
  elseif strncmpi(temp,'w',1) | isempty(temp)
    filetype = 'w';
  elseif strncmpi(temp,'d',1)
    filetype = 'd';
  elseif strncmpi(temp,'filt',4)
    filetype = 'filt';
  elseif strncmpi(temp,'foo',3)
    filetype = 'foo';
  elseif strcmpi(temp,'o')
    filetype = 'obs0r';
  elseif strcmpi(temp,'o1r')
    filetype = 'obs1r';
  else
    disp('Unacceptable! Pick again')
    filetype = 'null';
  end
end

%get default sample rate
% sampling rate of WAV files gets loaded in from the file automatically
% Fs = 32000;
% if ~(strcmp(filetype,'w') | strcmp(filetype,'filt'))
%   Fs = input('What is sample rate (samples/sec)? [32000] ');
%   if isempty(Fs); Fs = 32000; end
% end

[song,Fs] = gk_soundin(path_songfile, songname, filetype);

Fs = 32000;

if ~(strcmp(filetype,'w') | strcmp(filetype,'filt'))
  Fs = input('What is sample rate (samples/sec)? [32000] ');
  if isempty(Fs); Fs = 32000; end
end
    
disp(['Sampling rate is ', num2str(Fs)])

h1 = figure;
t_song = ((1:length(song)) - 1)/Fs;
plot(t_song,song)
xlabel('t (sec)')
ylabel('Amplitude')
title(songfile,'Interpreter','none')

dataout_info.swab = 1;
dataout_info.samp_type = 'int16';

iseg = 0
while 1
  qans = input('Select a segment? (Y/n/q)','s');
  if strncmpi(qans,'n',1) | strncmpi(qans,'q',1)
    break;
  end
  figure(h1)

  disp(['Select the segment with mouse buttons. Press Return to select,' ...
	' q to quit.'])
  [xl, xr, button, flag] = get_xrange;

  if flag
    seg_idx = find(t_song > xl(end) & t_song < xr(end));
    song_seg = song(seg_idx);
  
    h2 = figure;
    plot(t_song(seg_idx),song_seg)
    xlabel('t (sec)')
    ylabel('Amplitude')
    title(['Segment selection [', num2str(iseg), ']: ', songname],'Interpreter','none')
    
    yesno = input('Do you want to save this segment? [y/N]', 's');
    if strncmpi(yesno,'y',1)
      iseg = iseg + 1
      segfile = fullfile(path_songfile,[songname,'_seg', num2str(iseg),'.raw'])
      gk_write_data(song_seg, dataout_info, segfile);
    end
    close(h2)
  end

end

disp('Done')