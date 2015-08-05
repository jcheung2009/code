% GK script to load in and plot multiple song files.

clear

% Get batch file information and open it.
batch_info = [];
batch_info = gk_batch_select(batch_info);  %GK
% Read in the file list
batch_info = gk_batch_read(batch_info)

Fs = 40000
nfft = 512; window = nfft; noverlap = nfft/2;
do_separate_plots = 0

yesno = input('Do you want PSD?(y/N)','s');
if strncmpi(yesno,'y',1)
  do_psd = 1
else
  do_psd = 0
end

yesno = input('Do you want spectrogram, too?(y/N)','s');
if strncmpi(yesno,'y',1)
  do_specgram = 1
else
  do_specgram = 0
end

% Go through all files 
for ifile=1:batch_info.nfiles
  [fpath,fname,fext,ver]=fileparts(batch_info.filenames{ifile});
  if isempty(fpath)  
    songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile})
  else
    songfile = fullfile(fpath,[fname,fext,ver])
  end
  
  fids = fopen(songfile,'r','b')
  song{ifile} = fread(fids,inf,'int16');
  fclose(fids);

  t_song{ifile} = ((1:length(song{ifile})) - 1)/Fs;
  
  if do_psd
    [Ps{ifile},freq{ifile}] = psd(song{ifile},nfft,Fs,window,noverlap);
  end
  
  if do_specgram
    [y{ifile},f{ifile},t{ifile}] = specgram(song{ifile},nfft,Fs,window,noverlap);
  end
  
  if do_separate_plots
    h1 = figure;
    plot(t_song{ifile},song{ifile})
    xlabel('t (sec)')
    ylabel('Amplitude')
    title(songfile,'Interpreter','none')
  end
  
end % Loop over files

if ~do_separate_plots
  mplot(t_song,song)
end

if do_psd
  figure 
  hold on
  for ifile=1:batch_info.nfiles
    plot(freq{ifile},10*log10(Ps{ifile}))
  end
  title('Power spectrum density')
  hold off
end

if do_specgram
  mplot_spec(t,f,y)
end

disp('Done')

%songfile = input('Enter songfile name (full path): ','s')
%[path_songfile,songbasename,sext,sver] = fileparts(songfile)
%songname = [songbasename,sext,sver]

% get filetype, later versions of read program can be smarter about this

%disp('What is type of sound file? [w]')
%disp(' b = binary from mac')
%disp(' w = wavefile (i.e. cbs)')
%disp(' d = dcpfile')
%disp(' filt = .filt file from uisonganal')
%disp(' foo = foosong/gogo (sets Fs = 32000)')
%disp(' o = observer file (last/song channel)')
%disp(' o1r = observer file (second to last)')

% filetype = 'null';
% while strcmp(filetype,'null')
%   temp=input(' ','s');
%   if strncmpi(temp,'b',1);
%     filetype = 'b';
%   elseif strncmpi(temp,'w',1) | isempty(temp)
%     filetype = 'w';
%   elseif strncmpi(temp,'d',1)
%     filetype = 'd';
%   elseif strncmpi(temp,'filt',4)
%     filetype = 'filt';
%   elseif strncmpi(temp,'foo',3)
%     filetype = 'foo';
%   elseif strcmpi(temp,'o')
%     filetype = 'obs0r';
%   elseif strcmpi(temp,'o1r')
%     filetype = 'obs1r';
%   else
%     disp('Unacceptable! Pick again')
%     filetype = 'null';
%   end
% end

%get default sample rate
% sampling rate of WAV files gets loaded in from the file automatically
% Fs = 32000;
% if ~(strcmp(filetype,'w') | strcmp(filetype,'filt'))
%   Fs = input('What is sample rate (samples/sec)? [32000] ');
%   if isempty(Fs); Fs = 32000; end
% end
% 
% [song,Fs]=gk_soundin(path_songfile, songname, filetype);
% disp(['Sampling rate is ', num2str(Fs)])



