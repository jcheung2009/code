MAX_SAMPLES = 12500000
MAX_DA = 32767
MIN_DA = -32768

% Global values in this case
% Sampling rate default
Fs_dflt = 2e7/454 % more precise
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

MAX_GAUSS_WIDTH = 4

% Do we do lots of plots?
do_plots = 0
do_osc_plots = 0

% Do we save a white Gaussian noise signal?
do_WGN = 1
% Do we generate and save a Gaussian noise signal matched to the
% ensemble spectrum?
do_ensemble_GN = 1
% Do we generate and save a Gaussian noise signal matched to the
% ensemble carrier spectrum?
do_ensemble_carrier_GN = 1
% Do we save the matched Gaussian log envelope signal
do_ensemble_logenv_GN = 1
% Do we generate and save a lognormal envelope noise signal matched to
% both the ensemble carrier and envelope spectra?
do_ensemble_carrier_and_envelope_GN = 1
% Do we generate and save a lognormal envelope noise signal matched to
% the ensemble envelope spectrum with a carrier matched to the
% entire ensemble spectrum?
do_ensemble_enscarrier_and_envelope_GN = 1
% Do we generate and save a lognormal envelope noise signal matched to
% the ensemble envelope spectrum with a white Gaussian carrier?
do_ensemble_WGN_and_envelope_GN = 1
% Always save the gaussian compnents used to construct each signal.
if do_ensemble_carrier_and_envelope_GN == 1
  do_ensemble_carrier_GN = 1
  do_ensemble_logenv_GN = 1
end
if do_ensemble_enscarrier_and_envelope_GN == 1
  do_ensemble_GN = 1
  do_ensemble_logenv_GN = 1
end
if do_ensemble_WGN_and_envelope_GN == 1
  do_WGN = 1
  do_ensemble_logenv_GN = 1
end

% Save all the Gaussian components of non-Gaussian output signals?
save_gaussian_components = 1

stimbasedir = input('Enter base directory for output stimulus files: ','s')
filenameprefix = input('Enter file name prefix for output stimulus files: ','s')

% This mat file must have an "ensemble" structure containing fields
% for global ensemble info and statistics as well as those for some
% definition of the signal envelope and carrier components.
ensemblestatsfile = input(['Enter .mat file containing natural statistics and filter information: '], 's')

% This loads an ensemble structure
% Fields include:
%   ensemble.files
%   ensemble.file_lengths
%   ensemble.batchfile
%   ensemble.basedir
%   ensemble.max
%   ensemble.mean
%   ensemble.std
%   ensemble.psd
%   ensemble.psd_nfft
%   ensemble.psd_freq
%
%   ensemble.envelope.type (= 'log_sqrt_LV') 
%   ensemble.envelope.win_type
%   ensemble.envelope.win_dur
%   ensemble.envelope.psd
%   ensemble.envelope.mean
%   ensemble.envelope.std
%    
%   ensemble.carrier.type (= 'LVN') 
%   ensemble.carrier.win_type
%   ensemble.carrier.win_dur
%   ensemble.carrier.psd
%   ensemble.carrier.mean
%   ensemble.carrier.std
load(ensemblestatsfile);

% Request sampling rate if it wasn't recorded in the ensemble structure.
if ~isfield(ensemble,'Fs') | isempty(ensemble.Fs)
  Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
  if isempty(Fs)
    Fs = Fs_dflt
  end  
else
  Fs = ensemble.Fs
end

disp('(1) Match files in the original ensemble in number and length.')
disp('(2) Choose number of fixed length files.')
filematch_code = input('Select file generation option [2]: ')
if ~isempty(filematch_code) & filematch_code == 1
  nfiles = ensemble.nfiles;
  stim_lengths = ensemble.file_lengths;
else
  nfiles = input('Enter number of files to generate: ')
  stim_length_sec = input('Enter the stimulus length in seconds: ')
  stim_length = fix(Fs*stim_length_sec)
  if stim_length > MAX_SAMPLES
    error('Desired stimulus is too long');
  end
  stim_lengths = stim_length*ones(1,nfiles);
end

% Fudge factor for gain to prevent clipping
%gain_fudge = 10^0.25 % This makes a 5 dB attenuation relative to
                     % the ensemble
gain_fudge = 10^0.1 % This makes a 2 dB attenuation relative to
                     % the ensemble
%gain_fudge = 1
		     
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
if do_ensemble_GN
  nstims = nstims+1;
  idx_ens = nstims
  stim_info{nstims}.type = 'ensemble_GN'
  file_info{nstims}.key = 'ensGN'
  norm_info{nstims}.type = 'rms'
end
if do_ensemble_carrier_GN
  nstims = nstims + 1
  idx_car = nstims
  stim_info{nstims}.type = 'ensemble_carrier_GN'
  file_info{nstims}.key = 'ensCarGN'
  norm_info{nstims}.type = 'rms'
end
%if do_ensemble_logenv_GN
%  nstims = nstims + 1
%  stim_info{nstims}.type = 'ensemble_logenv_GN'
%  file_info{nstims}.key = 'ensLogEnvGN'
%  norm_info{nstims}.type = 'rms'
%end
if do_ensemble_carrier_and_envelope_GN
  nstims = nstims + 1
  stim_info{nstims}.type = 'ensemble_carrier_and_envelope_GN'
  file_info{nstims}.key = 'ensCarEnvGN'
  % norm_info{nstims}.type = 'centercut_peakrms'
  % We match the rms to the ensemble rms
  norm_info{nstims}.type = 'set_gain'
  norm_info{nstims}.setgainval = ensemble.std/(gain_fudge*exp(ensemble.envelope.std^2))
  norm_info{nstims}.cutfrac = 0.1
end
if do_ensemble_enscarrier_and_envelope_GN
  nstims = nstims + 1
  stim_info{nstims}.type = 'ensemble_enscarrier_and_envelope_GN'
  file_info{nstims}.key = 'ensEnsCarEnvGN'
  % norm_info{nstims}.type = 'centercut_peakrms'
  norm_info{nstims}.type = 'set_gain'
  norm_info{nstims}.setgainval = ensemble.std/(gain_fudge*exp(ensemble.envelope.std^2))
  norm_info{nstims}.cutfrac = 0.1
end
if do_ensemble_WGN_and_envelope_GN
  nstims = nstims + 1
  stim_info{nstims}.type = 'ensemble_WGN_and_envelope_GN'
  file_info{nstims}.key = 'ensWGNEnvGN'
  % norm_info{nstims}.type = 'centercut_peakrms'
  norm_info{nstims}.type = 'set_gain'
  norm_info{nstims}.setgainval = ensemble.std/(gain_fudge*exp(ensemble.envelope.std^2))
  norm_info{nstims}.cutfrac = 0.1
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
filt_info_dflt.F_low = 200
filt_info_dflt.F_high = 15000  
stim_info_dflt.samp_rate = Fs
stim_info_dflt.samp_size = SAMP_SIZE
stim_info_dflt.samp_type = SAMP_TYPE
stim_info_dflt.swab = SWAB
norm_info_dflt.nstd = MAX_GAUSS_WIDTH    

filt_info_hip.type = 'hipass'
filt_info_hip.do_filtfilt = 0
filt_info_hip.F_low = 200

for istim=1:nstims
  stim_info{istim}.samp_rate = stim_info_dflt.samp_rate;
  norm_info{istim}.nstd = norm_info_dflt.nstd;    
  stim_info{istim}.samp_size = stim_info_dflt.samp_size;
  stim_info{istim}.samp_type = stim_info_dflt.samp_type
  stim_info{istim}.swab = stim_info_dflt.swab
  % Global filter settings; can change on a per stim basis.
  filt_info{istim} = filt_info_dflt
end

% data struct for saving gaussian components as doubles
dbldata_info.samp_rate = Fs
dbldata_info.samp_size = 8
dbldata_info.samp_type = 'double'
dbldata_info.swab = 0

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
do_stim_spect=0
nfft = ensemble.psd_nfft
%nfft = 65536
%novl = 8192
novl = round(nfft/4)

% This sets up the filters
%% Iteractive setup
%filt_info = filter_select;
for istim=1:nstims
  if ~strcmp(filt_info{istim}.type,'none')
    % Set up filters and pass output in a filter info struct.
    % Uncomment to set stimulus specific filter cutoffs.
%    switch stim_info{istim}.type
%      case 'WGN'
%      case 'ensemble_GN'
%      case 'ensemble_carrier_GN'
%      case 'ensemble_logenv_GN'
%      case 'ensemble_carrier_and_envelope_GN'
%      case 'ensemble_enscarrier_and_envelope_GN'
%      case 'ensemble_WGN_and_envelope_GN'
%    end
    filt_info{istim} = filter_setup(filt_info{istim},Fs)
  end
end
filt_info_hip = filter_setup(filt_info_hip,Fs)

% Make spectrum matching filters
% Construct alternative filters using multitaper spectrum?

if do_ensemble_GN
  % First match the overall spectrum
  fcut_low_ens = 100 % 100Hz cutoff or 10ms duration
  fcut_high_ens = 10000
  [ens_filter, freq_ens, itfc_ens] = ...
      make_spect_filt(ensemble.psd_freq,ensemble.psd,Fs,ensemble.psd_nfft,fcut_low_ens,fcut_high_ens,do_plots,ensemble.batchfile);
  filt_len_ens = length(ens_filter)
end

if do_ensemble_carrier_GN | do_ensemble_carrier_and_envelope_GN
  % Next match the carrier (LVN) signal
  fcut_low_enscar = 100 % 100Hz cutoff or 10ms duration
  fcut_high_enscar = 10000
  [enscar_filter, freq_enscar, itfc_enscar] = ...
      make_spect_filt(ensemble.psd_freq, ensemble.carrier.psd,Fs,ensemble.psd_nfft,fcut_low_enscar,fcut_high_enscar,do_plots,ensemble.batchfile);
  filt_len_enscar = length(enscar_filter(:,1))
end

if do_ensemble_logenv_GN
  % Next match the envelope (log(sqrt(LV))) signal
  fcut_low_ensenv = 4 % 5 Hz cutoff or 200 ms duration
  fcut_high_ensenv = 250
  [ensenv_filter, freq_ensenv, itfc_ensenv] = ...
      make_spect_filt_env(ensemble.psd_freq,ensemble.envelope.psd,Fs,ensemble.psd_nfft,fcut_low_ensenv,fcut_high_ensenv,do_plots,ensemble.batchfile);
  filt_len_ensenv = length(ensenv_filter(:,1))
end  

% We have our filters, now batch process files.
%disp('Hit return to make data files.')
%pause

% Load in random generator states if requested.
if rand_state_loaded
  st = loadstate.st;
  if isfield(loadstate,'st_env')
    st_env = loadstate.st_env;
  end
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
  
  if do_ensemble_logenv_GN
    if rand_state_loaded
      randn('state',st_env{ifile})
    else    
      st_env{ifile} = randn('state');
    end
    gdata_env = randn(1,stim_length);
  end

  for istim=1:nstims
    filename{istim} = [filenameprefix, '_', file_info{istim}.key, '_', num2str(ifile),'.raw']
    file_info{istim}.files{ifile} = fullfile(stimbasedir,filename{istim})
  end
    
  % Filter the Gaussian data with filters from the ensemble
  if do_ensemble_GN
    ensfiltgdata = filter_data_conv(gdata,ens_filter,itfc_ens);
    % Rescale data to unit variance    
    rfiltdata = real(ensfiltgdata(1:stim_length));
    ensfiltgdata = rfiltdata/std(rfiltdata);
  end
  if do_ensemble_carrier_GN
    enscarfiltgdata = filter_data_conv(gdata,enscar_filter,itfc_enscar);
    rfiltdata = real(enscarfiltgdata(1:stim_length));
    enscarfiltgdata = rfiltdata/std(rfiltdata);
  end
  if do_ensemble_logenv_GN
    ensenvfiltgdata = filter_data_conv(gdata_env,ensenv_filter,itfc_ensenv);
    rfiltdata = real(ensenvfiltgdata(1:stim_length));
    ensenvfiltgdata = (rfiltdata - mean(rfiltdata))/std(rfiltdata);
    %ensenvfiltgdata = rfiltdata/std(rfiltdata);
  end
  clear rfiltgdata

  if do_plots
    td = (0:stim_length-1)*1000/Fs;    
    npts = 10000;
    
    % Look at the spectra
    % mynfft = 2048
    mynfft = nfft
    mynovl = mynfft/2;
    
    % Look at autocorrelation functions
    maxlag_sec = 0.5 % We go out to +-500 msec in lag. 
    maxlag_sec = 10
    
    if do_ensemble_GN
      ifig = ifig+1;
      hh(ifig) = figure;
      plot(td(1:npts),[ensfiltgdata(1:npts) gdata(1:npts)'])
      title(['Gaussian signal (ensemble), file# ', num2str(ifile)])
      xlabel('t (msec)')
      
      tstring = ['Naturalistic filtered data spectral analysis, file# ', num2str(ifile)]
      calc_spect(ensfiltgdata,mynfft,Fs,hanning(mynfft),mynovl,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;
      
      tstring = ['Filtered Stimulus Autocorrelation, file# ', num2str(ifile)]
      calc_autocorr(ensfiltgdata,maxlag_sec,Fs,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;      
    end
    if do_ensemble_carrier_GN
      ifig = ifig+1;
      hh(ifig) = figure;
      plot(td(1:npts),[enscarfiltgdata(1:npts) gdata(1:npts)'])
      title(['Gaussian signal (carrier), file# ', num2str(ifile)])
      xlabel('t (msec)')
      
      tstring = ['Naturalistic filtered data spectral analysis', ...
	    ' (carrier), file# ', num2str(ifile)]
      calc_spect(enscarfiltgdata,mynfft,Fs,hanning(mynfft),mynovl,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;
      
      tstring = ['Filtered Stimulus Autocorrelation (carrier), file# ', num2str(ifile)]
      calc_autocorr(enscarfiltgdata,maxlag_sec,Fs,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;      
    end
    if do_ensemble_logenv_GN
      ifig = ifig+1;
      hh(ifig) = figure;
      plot(td(1:npts),[ensenvfiltgdata(1:npts) gdata_env(1:npts)'])
      title(['Gaussian signal (envelope), file# ', num2str(ifile)])
      xlabel('t (msec)')
      
      tstring = ['Naturalistic filtered data spectral analysis', ...
	    ' (log(envelope)), file# ', num2str(ifile)]
      calc_spect(ensenvfiltgdata,mynfft,Fs,hanning(mynfft),mynovl,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;
      
      tstring = ['Filtered Stimulus Autocorrelation', ...
	    ' (log(envelope)), file# ', num2str(ifile)]
      calc_autocorr(ensenvfiltgdata,maxlag_sec,Fs,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;      
    end
  end
  % wavwrite(ensfiltgdata(1:stim_length),Fs,16,'ensfiltgdata.wav')
  % wavwrite(gdata(1:stim_length),Fs,16,'gdata.wav')

  % Construct stimuli
  % Stims don't all have to have the same length
  stimdata = cell(nstims,1);
  
  % First make all the possible carrier stims
  for istim=1:nstims
    switch stim_info{istim}.type
      case 'WGN'
	stimdata{istim} = filter_data(gdata',filt_info{istim});
      case 'ensemble_GN'
	stimdata{istim} = filter_data(ensfiltgdata,filt_info{istim});
      case 'ensemble_carrier_GN'	
	stimdata{istim} = filter_data(enscarfiltgdata,filt_info{istim});
      %case 'ensemble_logenv_GN'
	%stimdata{istim} = ensenvfiltgdata;
    end
  end

  % Next make all the possible envelope modulated stims
  if do_ensemble_logenv_GN
    % Match the variance of the ensemble envelope
    logenv_gain = ensemble.envelope.std	
    logenv = logenv_gain*ensenvfiltgdata;
    if save_gaussian_components
      gcfile = [filenameprefix, '_', 'ensLogEnvGN', '_', num2str(ifile),'.dbl']
      gcfile = fullfile(stimbasedir,gcfile)
      write_data(logenv,dbldata_info,gcfile);
    end
  end
  for istim=1:nstims
    switch stim_info{istim}.type
      case 'ensemble_carrier_and_envelope_GN'
	% high pass filter carrier?   
	car_len = length(stimdata{idx_car})
	stimdata{istim} = exp(logenv(1:car_len)).*stimdata{idx_car};
	% Hipass filter data
	stimdata{istim} = filter_data(stimdata{istim},filt_info{istim});
	if save_gaussian_components
	  gcfile = [filenameprefix, '_', file_info{idx_car}.key, '_', num2str(ifile),'.dbl']
	  gcfile = fullfile(stimbasedir,gcfile)
	  write_data(stimdata{idx_car},dbldata_info,gcfile);
	end
      case 'ensemble_enscarrier_and_envelope_GN'
	car_len = length(stimdata{idx_ens})
	stimdata{istim} = exp(logenv(1:car_len)).*stimdata{idx_ens};
	% Hipass filter data
	stimdata{istim} = filter_data(stimdata{istim},filt_info{istim});
	if save_gaussian_components
	  gcfile = [filenameprefix, '_', file_info{idx_ens}.key, '_', num2str(ifile),'.dbl']
	  gcfile = fullfile(stimbasedir,gcfile)
	  write_data(stimdata{idx_ens},dbldata_info,gcfile);
	end
      case 'ensemble_WGN_and_envelope_GN'
	car_len = length(stimdata{idx_wgn})
	stimdata{istim} = exp(logenv(1:car_len)).*stimdata{idx_wgn};
	% Hipass filter data
	stimdata{istim} = filter_data(stimdata{istim},filt_info{istim});
	if save_gaussian_components
	  gcfile = [filenameprefix, '_', file_info{idx_wgn}.key, '_', num2str(ifile),'.dbl']
	  gcfile = fullfile(stimbasedir,gcfile)
	  write_data(stimdata{idx_wgn},dbldata_info,gcfile);
	end
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
    
    % Normalize data if needed.
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

    if do_osc_plots & strcmp(stim_info{istim}.type,'ensemble_enscarrier_and_envelope_GN')
      ifig = ifig+1;
      hh(ifig) = figure;
      td = (0:length(tempstim)-1)*1000/Fs;    
      plot(td, tempstim)
      xlabel('t (msec)')
      title(['Oscillogram: ', ...
	    file_info{istim}.files{ifile}], 'Interpreter', 'none')
      
    end
    if do_stim_spect
      tstring = ['Stimulus spectrum: ', file_info{istim}.files{ifile}]
      calc_spect_file(file_info{istim}.files{ifile},stim_info{istim},nfft,hanning(nfft),novl,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;
    end
  end

  % to play use "play -t raw -swx -c 1 -r 44100 gaussnoise.raw" from sox

  if do_plots | do_osc_plots | do_stim_spect
    disp('Hit return to continue.')
%    pause
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
save(randstatefile,'st','st_env')

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

clear tempstim stimdata logenv gdata gdata_env ensfiltgdata ...
    enscarfiltgdata ensenvfiltgdata rfiltdata

savefile = fullfile(stimbasedir,[filenameprefix, '_save', '.mat'])
save(savefile)

disp('Done.')
