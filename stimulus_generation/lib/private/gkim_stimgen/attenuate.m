MAX_DA = 32767
MIN_DA = -32768

% Global values in this case
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

% Sampling rate default
Fs_dflt = 2e7/454 % more precise

% Get batch file information and open it.
batch_info = [];
batch_info = batch_select(batch_info)
% Read in the file list
batch_info = batch_read(batch_info)

stimbasedir = input('Enter base directory for output stimulus files: ','s')
yesno = input('Is the output data to be byte swapped? (y/N): ','s')
if strncmpi(yesno,'y',1)
  SWAB = 1
else	
  SWAB = 0
end

% Do we allow the different sound files have different sampling
% rates? Not right now.
Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

stim_info.samp_rate = Fs
stim_info.samp_size = SAMP_SIZE
stim_info.samp_type = SAMP_TYPE
stim_info.swab = SWAB
norm_info.type = 'set_gain'

%
% Set up the attenuation grid
%
atten_max = input('Enter approximate maximum attenuation in dB: ')
while (atten_max > 80)
  % Want at least 3 bit resolution?
  warn(['Maximum attenuation should not exceed 80 dB to retain' ...
	' stimulus quality.'])
  atten_max = input('Reenter approximate maximum attenuation in dB: ')
end
atten_step = input('Enter attenuation stepsize in dB: ')
% Note this will truncate at the end
atten_grid = 0:atten_step:atten_max;
gains = 10.0.^(-atten_grid/20.0);
ngains = length(gains)

% Go through all files 
disp('Processing...')
for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});

  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);
  [o_path,o_name,o_ext,o_ver]  = fileparts(batch_info.filenames{ifile});
  outsongprefix = o_name;  

  for iamp=1:ngains
    % Set output file name
    outsongname = [outsongprefix, '_A', ...
	  num2str(round(atten_grid(iamp))), o_ext, o_ver];
    outsongfile = fullfile(stimbasedir,outsongname);
    
    norm_info.setgainval = gains(iamp);
    [outsong, norm_info] = norm_data(song',norm_info);

    write_data(outsong,stim_info,outsongfile);
  end
end % Loop over files

disp('Done.')
