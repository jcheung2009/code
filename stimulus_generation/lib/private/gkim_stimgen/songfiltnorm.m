MAXSHORT = 32767
MINSHORT = -32768

% Add user input for original sampling rate, output rate and
% rate factors. Add input for normalization parameters.
% Filter before or after resampling?
% Support for multiple song types?

% Default output file settings. Fixed for now.
fileout_info.swab = 1
fileout_info.samp_type = 'int16'
fileout_info.samp_size = 2

% Sampling rate default
Fs_dflt = 2e7/454 % more precise

% Get batch file information and open it.
batch_info = [];
batch_info = batch_select(batch_info)
% Read in the file list
batch_info = batch_read(batch_info)

% Need to support more file formats!
disp('What is type of sound file? [w]')
disp(' b = binary 16bit big-endian')
disp(' w = wavefile (i.e. cbs)')
filetype = 'null';
while strcmp(filetype,'null')
  temp=input(' ','s');
  if strncmpi(temp,'b',1);
    filetype = 'b';
  elseif strncmpi(temp,'w',1) | isempty(temp)
    filetype = 'w';
  else
    disp('Unacceptable! Pick again')
    filetype = 'null';
  end
end

% Do we allow the different sound files have different sampling
% rates? Not right now.
Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

% Filtering parameters
filt_info = filter_select;
filt_info = filter_setup(filt_info,Fs);

% Resampling parameters and setup
resamp_info = resample_init(Fs)
fileout_info.samp_rate = resamp_info.Fs_new;

% Normalization setup
norm_info = norm_select

% Where to put the output files?
fileout_info.basedir = input(['Enter directory for writing output', ...
      ' files [', batch_info.basedir, ']: '],'s')
if isempty(fileout_info.basedir)
  fileout_info.basedir = batch_info.basedir
end

for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});

  if strcmp(filetype,'b')
    fids = fopen(songfile,'r','b');
    [song, songlen] = fread(fids,inf,'int16');
    fclose(fids);
  else
    [song,Fs_read,Fmt] = wavread16(songfile);
    songlen = length(song);
    if Fs ~= Fs_read
      warning(['Sampling rate in WAV file header (', ...
	    num2str(Fs_read), ') does not match user' ...
	    ' specification (', num2str(Fs), ').']);
      warning(['Skipping file ', batch_info.filenames{ifile}])
      continue;
    end
  end

  % Filter data if needed.
  tempsong = filter_data(song,filt_info);

  % Resample song if needed
  tempsong = resample_data(tempsong,resamp_info);
  
  % Normalize data if needed. This must be the last step.
  [tempsong, norm_info] = norm_data(tempsong,norm_info);
  % Save clipping info.
  nclip(ifile) = norm_info.nclip;
  
  % Generate output file name
  filekey = '';
  if ~strcmp(filt_info.type,'none')
    filekey = [filekey, '_', filt_info.type];
    if isfield(filt_info,'F_low') & ~isempty(filt_info.F_low)
      filekey = [filekey, '_', num2str(filt_info.F_low)];
    end
    if isfield(filt_info,'F_high') & ~isempty(filt_info.F_high)
      filekey = [filekey, '_', num2str(filt_info.F_high)];
    end
  end
  if ~strcmp(norm_info.type,'none')
    filekey = [filekey, '_G'];
    if isfield(norm_info,'gain') & ~isempty(norm_info.gain)
      filekey = [filekey, num2str(norm_info.gain,'%.1f')];
    end
  end
  filekey = [filekey, '_Fs', num2str(resamp_info.Fs_new/1000)];
    
  [spath,sname,sext,sver] = fileparts(batch_info.filenames{ifile});
  % Should we include relative path in the batchfile in the output
  % file name?
  fileout{ifile} = fullfile(fileout_info.basedir, spath, [sname, filekey, '.raw'])

  % Write to file. For now raw byte-swapped 16bit ints.
  % Support multiple output formats!
  write_data(tempsong,fileout_info,fileout{ifile});
  
end

clear song tempsong temp

savefile = input(['Enter filename for saving results (path will be', ...
      ' output base dir): '],'s')
savefile = fullfile(fileout_info.basedir, savefile)
save(savefile)

disp('Done.')
