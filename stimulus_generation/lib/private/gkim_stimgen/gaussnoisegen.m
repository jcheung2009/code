MAX_SAMPLES = 12500000
MAX_DA = 32767
MIN_DA = -32768

% Global values in this case
%SAMP_RATE = 44100
SAMP_RATE = 44052.9
Fs = SAMP_RATE
samp_rate_kHz = Fs/1000.0
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

MAX_GAUSS_WIDTH = 4

% Do we do lots of plots?
do_plots = 0
do_osc_plots = 0

% Do we save a white Gaussian noise signal?
do_WGN = 1

stimbasedir = input('Enter base directory for output stimulus files: ','s')
filenameprefix = input('Enter file name prefix output stimulus files: ','s')

nfiles = input('Enter number of files to generate: ')
stim_length_sec = input('Enter the stimulus length in seconds: ')
stim_length = fix(Fs*stim_length_sec)
if stim_length > MAX_SAMPLES
  error('Desired stimulus is too long');
end
stim_lengths = stim_length*ones(1,nfiles);

% Max. fraction of points allowed to be clipped
clip_frac = 0.0003

% Set up the different output stimulus types
nstims = 0;
if do_WGN
  nstims = nstims+1;
  idx_wgn = nstims
  stim_info{nstims}.type = 'WGN'
  file_info{nstims}.key = 'WGN'
  % Info for scaling data before output
  norm_info{nstims}.type = 'rms'
end

yesno = input('Is the output data to be byte swapped? (y/N): ','s')
if strncmpi(yesno,'y',1)
   SWAB = 1
else	
   SWAB = 0
end

MAX_GAUSS_WIDTH = input('Enter the number of stddev to saturate the Gaussian WN: ')

filt_info_dflt.type = 'hanningfir'
filt_info_dflt.do_filtfilt = 0
filt_info_dflt.F_low = 100
filt_info_dflt.F_high = 20000  
stim_info_dflt.samp_rate = Fs
stim_info_dflt.samp_size = SAMP_SIZE
stim_info_dflt.samp_type = SAMP_TYPE
stim_info_dflt.swab = SWAB
norm_info_dflt.nstd = MAX_GAUSS_WIDTH    

filt_info_hip.type = 'hipass'
filt_info_hip.do_filtfilt = 0
filt_info_hip.F_low = 100

for istim=1:nstims
  stim_info{istim}.samp_rate = stim_info_dflt.samp_rate;
  norm_info{istim}.nstd = norm_info_dflt.nstd;    
  stim_info{istim}.samp_size = stim_info_dflt.samp_size;
  stim_info{istim}.samp_type = stim_info_dflt.samp_type
  stim_info{istim}.swab = stim_info_dflt.swab
  % Global filter settings; can change on a per stim basis.
  filt_info{istim} = filt_info_dflt
end

yesno = input(['Do you want to load in the initial state random number generator? (y/N)'], 's')
if strncmpi(yesno,'y',1)
  randstatefile = input('Enter name of .mat file containing initial randn state: ', 's')
  loadstate = load(randstatefile);
  rand_state_loaded = 1;
else
  rand_state_loaded = 0;
end
  
% Set up the stimulus ramp and silence padding
ramp_info = ramp_setup(Fs)

% Filtering/spectrum parameters
do_stim_spect=1
nfft = 65536
%novl = 8192
novl = round(nfft/4)

% This sets up the filters
%% Iteractive setup
%filt_info = filter_select;
for istim=1:nstims
  if ~strcmp(filt_info{istim}.type,'none')
    % Set up filters and pass output in a filter info struct.
    filt_info{istim} = filter_setup(filt_info{istim},Fs)
  end
end
filt_info_hip = filter_setup(filt_info_hip,Fs)

% Make spectrum matching filters
% Construct alternative filters using multitaper spectrum?

% We have our filters, now batch process files.
%disp('Hit return to make data files.')
%pause

% Load in random generator states if requested.
if rand_state_loaded
  st = loadstate.st;
end

% Big file loop
ifile = 1
while ifile <= nfiles    
  ifig = 0;
  
  stim_length = stim_lengths(ifile)

  disp('Generating Gaussian data...');
  if rand_state_loaded
    randn('state',st{ifile})
  else    
    st{ifile} = randn('state');
  end
  gdata = randn(1,stim_length);
  
  for istim=1:nstims
    filename{istim} = [filenameprefix, '_', file_info{istim}.key, '_', num2str(ifile),'.raw']
    file_info{istim}.files{ifile} = fullfile(stimbasedir,filename{istim})
  end
    
  % Construct stimuli
  % Stims don't all have to have the same length
  stimdata = cell(nstims,1);
  
  % First make all the possible carrier stims
  for istim=1:nstims
    switch stim_info{istim}.type
      case 'WGN'
	stimdata{istim} = filter_data(gdata',filt_info{istim});
    end
  end
    
  % Process and write out each stim.
  bad_clipping = 0;
  for istim = 1:nstims
    tempstim = stimdata{istim};
    % Do filtering during stimulus construction now.
    %if ~strcmp(filt_info.type,'none')
    %  tempstim = filter_data(tempstim,filt_info);
    %end
    if do_plots
      ifig = ifig+1;
      hh(ifig) = figure;
      hist(tempstim,100);
      title(['Amplitude distribution: ', ...
	    file_info{istim}.files{ifile}], 'Interpreter', 'none')
    end
    [tempstim, norm_info{istim}] = norm_data(tempstim,norm_info{istim});

    if norm_info{istim}.nclip/stim_length > clip_frac
      bad_clipping = 1
      break
    end
    % Save clipping information
    file_info{istim}.nclip(ifile) = norm_info{istim}.nclip;
    file_info{istim}.gain(ifile) = norm_info{istim}.gain;
    tempstim = make_ramp(tempstim, ramp_info);
    write_data(tempstim,stim_info{istim},file_info{istim}.files{ifile});

    if do_osc_plots
      ifig = ifig+1;
      hh(ifig) = figure;
      td = (0:length(tempstim)-1)*1000/Fs;    
      plot(td, tempstim)
      xlabel('t (msec)')
      title(['Oscillogram: ', ...
	    file_info{istim}.files{ifile}], 'Interpreter', 'none')
      
    end
    tstring = ['Stimulus spectrum: ', file_info{istim}.files{ifile}]
    if do_stim_spect
      calc_spect_file(file_info{istim}.files{ifile},stim_info{istim},nfft,hanning(nfft),novl,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;
    end
  end

  % to play use "play -t raw -sw -c 1 -r 44100 gaussnoise.raw" from sox

  if do_plots | do_osc_plots | do_stim_spect
    disp('Hit return to continue.')
    pause(2)
    handle_idx = find(ishandle(hh));
    close(hh(handle_idx))
    clear td
  end

  if ~bad_clipping
    ifile = ifile + 1
  end

end % Loop over files

randstatefile = fullfile(stimbasedir,[filenameprefix, '_', 'randstate','.mat'])
save(randstatefile,'st')

% Save data rc files.
yesno = input('Do you want to create a krank rc file for this stimulus set (y/N)?', 's');
if strncmpi(yesno,'y',1)  
  rcbasedir = input('Enter base directory for rc files: ', 's')
  for istim=1:nstims
    rcfilename = fullfile(rcbasedir,[filenameprefix, '_', ...
	  file_info{istim}.key, '.rc'])   
    make_stim_rc_rptnonrpt(rcfilename,file_info{istim}.files,Fs)  
  end
end

disp('Hit return to continue. Next will clear temp data and save workspace.')
pause

clear tempstim stimdata gdata

savefile = fullfile(stimbasedir,[filenameprefix, '_save', '.mat'])
save(savefile)

disp('Done.')
