MAX_DA = 32767
MIN_DA = -32768

% Global values in this case
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

% Sampling rate default
Fs_dflt = 2e7/454 % more precise

% Get batch file information and open it.
batch_info = [];
batch_info = gk_batch_select(batch_info);  %GK
% Read in the file list
batch_info = gk_batch_read(batch_info)

% Do we allow the different sound files have different sampling
% rates? Not right now.
Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

%stimbasedir = input('Enter base directory for output stimulus files: ','s') 
stimbasedir = input(['Enter directory for writing output', ...   %GK
      ' stimulus files [', batch_info.basedir, ']: '],'s');
if isempty(stimbasedir)
  stimbasedir = batch_info.basedir
end

yesno = input('Is the output data to be byte swapped? (y/N): ','s')
if strncmpi(yesno,'y',1)
  SWAB = 1
else	
  SWAB = 0
end

stim_info.samp_rate = Fs;
stim_info.samp_size = SAMP_SIZE;
stim_info.samp_type = SAMP_TYPE;
stim_info.swab = SWAB

% Set up the stimulus ramp and silence padding
ramp_info = gk_ramp_setup(Fs)

sprezpdur = num2str(round(1000*ramp_info.zpad_pre_length_sec))
spostzpdur = num2str(round(1000*ramp_info.zpad_post_length_sec))

% Go through all files 
disp('Processing...')
for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});
  
  % Set output file name
  [o_path,o_name,o_ext,o_ver]  = fileparts(batch_info.filenames{ifile});
  rampsongname = [o_name, '_r', ...
	num2str(fix(1000*ramp_info.length_sec)), '_bz', sprezpdur, ...
	'_ez', spostzpdur, o_ext, o_ver]
  rampsongfile = fullfile(stimbasedir,rampsongname);

  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);
  
  rampsong = gk_make_ramp(song', ramp_info);    %GK
  gk_write_data(rampsong,stim_info,rampsongfile);
    
end % Loop over files

disp('Done.')
