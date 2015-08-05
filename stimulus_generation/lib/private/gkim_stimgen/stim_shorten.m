% Get the first seg_dur seconds of the stimuli and save

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

% Do we allow the different sound files have different sampling
% rates? Not right now.
Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

stimbasedir = input('Enter base directory for output stimulus files: ','s')
yesno = input('Is the output data to be byte swapped? (y/N): ','s')
if strncmpi(yesno,'y',1)
  SWAB = 1
else	
  SWAB = 0
end

stim_info.samp_rate = Fs
stim_info.samp_size = SAMP_SIZE
stim_info.samp_type = SAMP_TYPE
stim_info.swab = SWAB

seg_dur = input('Enter duration of song chunk desired in sec: ')
seg_len = round(seg_dur*Fs);

% Go through all files 
disp('Processing...')
for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});

  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  if seg_len > songlenraw
    warn(['Chosen segment duration longer than song file. Skipping ', ...
	  batch_info.filenames{ifile}])
    continue;
  end
  
  fclose(fids);
  [o_path,o_name,o_ext,o_ver]  = fileparts(batch_info.filenames{ifile});
  outsongprefix = o_name;  
  outsongname = [outsongprefix, '_dur', num2str(seg_dur), o_ext, o_ver];
  outsongfile = fullfile(stimbasedir,outsongname);

  write_data(song(1:seg_len),stim_info,outsongfile);

end % Loop over files

disp('Done.')
