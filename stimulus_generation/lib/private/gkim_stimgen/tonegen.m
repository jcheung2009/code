MAX_SAMPLES = 12500000
MAX_STIM_MEM = 25000000
MAX_DA = 32767
MIN_DA = -32768

%
% User settable parameters -------- 
%
% DAQ hardware parameters
% Sampling rate default
%Fs = 44052.9
Fs_dflt = 2e7/454 % more precise
SAMP_SIZE = 2
SAMP_TYPE = 'int16'

% Plotting parameters
do_plots = 0
% Spectrum parameters
do_stim_spect = 0
do_spect_plots = 0
nfft = 4096
novl = 2048

% End user settable parameters ------

Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  
FNy = Fs/2

stimbasedir = input('Enter base directory for stimulus files: ','s')

% Allow users to enter custom frequency/amplitude grids?
disp('Frequency grid options:')
disp('(1) Uniform grid in log(frequency).')
disp('(2) CF centered uniform grid in log(frequency).')
disp('(3) User defined frequency grid.')
fgrid_type = input('Pick frequency grid type: ')
if fgrid_type == 3
  fgrid = input('Enter frequency grid as a matlab array: ')
elseif fgrid_type == 1 | fgrid_type == 2
  %
  % Set up the frequency grid.
  %
  freq_max = input('Enter approximate maximum frequency: ')
  freq_min = input('Enter approximate minimum frequency: ')
  N_foctaves = log2(freq_max/freq_min)
  disp(['Number of frequency octaves in this range: ', num2str(N_foctaves)])
  foctstep = input('Enter frequency stepsize in octaves: ')
  
  if fgrid_type == 2
    CF = input('Enter center frequency for frequency grid [1000Hz]: ')
    if isempty(CF)
      CF = 1000.0
    end
    foctgrid_range = input(['Number of frequency octaves to cover around' ...
	  ' the CF [4]: ']);
    if isempty(foctgrid_range)
      foctgrid_range = 4
    end
    foctmax = foctgrid_range + log2(CF)
    foctmin = -foctgrid_range + log2(CF)
    if 2^foctmin < freq_min
      foctmin = log2(freq_min)
    end
    if 2^foctmax > freq_max
      foctmax = log2(freq_max)
    end
    foctgrid = log2(CF):-foctstep:foctmin;
    foctgrid = [ sort(foctgrid) log2(CF)+foctstep:foctstep:foctmax];
  else
    % Note this will truncate at the end
    foctgrid = log2(freq_min):foctstep:log2(freq_max);
  end
  fgrid = 2.0.^foctgrid
end
disp('Frequency grid:')
fgrid
fmin = min(fgrid)
fmax = max(fgrid)
if fmax > FNy
  disp('Cannot exceed the Nyquist frequency.')
  fgrid = fgrid(find(fgrid <= FNy));
  fmax = max(fgrid);
  disp(['Cutting off grid at f = ', num2str(fmax), ' Hz.'])
end
disp(['Actual fmin: ', num2str(fmin), ' fmax: ', num2str(fmax), '.'])

stim_length_sec = input('Enter the stimulus length in seconds: ')
stim_length = fix(Fs*stim_length_sec)
if stim_length > MAX_SAMPLES
  error('Desired stimulus is too long');
elseif fmin < 1/stim_length_sec
  disp('Lowest frequency in grid too low for stimulus duration.')
  disp('Recommend stimulus duration > 10 X 1/fmin.')
  fgrid =  fgrid(find(fgrid >= 1/stim_length_sec));
  fmin = min(fgrid);
  disp(['Cutting off grid at f = ', num2str(fmin), ' Hz.'])
  disp(['Actual fmin: ', num2str(fmin), ' fmax: ', num2str(fmax), '.'])
end

disp('Amplitude grid options:')
disp('(1) Uniform grid in dB.')
disp('(2) User defined amplitude grid.')
atten_grid_type = input('Pick amplitude grid type: ')

if atten_grid_type == 2
  atten_grid = input('Enter amplitude grid in dB attenuation as a matlab array: ')
else
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
end
amp_max = MAX_DA-10; % Back off a little from saturation?
amp_grid = amp_max*10.0.^(-atten_grid/20.0)

N_freq = length(fgrid);
N_atten = length(atten_grid);
nfiles = N_freq*N_atten;

disp(['Will create total of ', num2str(nfiles), ' files.'])
%nfiles = input('Enter number of files to generate: ')

% Set up the stimulus ramp and silence padding
ramp_info = ramp_setup(Fs)

yesno = input('Is the output data to be byte swapped? (Y/n): ','s')
if strncmpi(yesno,'n',1)
   SWAB = 0
else	
   SWAB = 1
end

data_info.samp_rate = Fs;
data_info.samp_size = SAMP_SIZE;
data_info.samp_type = SAMP_TYPE;
data_info.swab = SWAB

tdata = (0:stim_length-1)/Fs;
phasefact = 2.0*pi*tdata;

sdur = num2str(round(1000*stim_length_sec))
srampdur = num2str(round(1000*ramp_info.length_sec))
sprezpdur = num2str(round(1000*ramp_info.zpad_pre_length_sec))
spostzpdur = num2str(round(1000*ramp_info.zpad_post_length_sec))

ifile = 0;
for ifreq = 1:N_freq
  for iamp=1:N_atten  
    
    disp('Generating tone data...');
    ifile = ifile+1
    % Files will be generated in the format
    % "f$freq_A$amp_d$dur_r$ramp.raw"
    % where $freq is the frequency in Hz, $amp is the amplitude
    % attenuation in dB, $dur is the duration of the stim in msec, and
    % $ramp is the duration of the cosine ramp in msec.
    filename{ifile} = ['f', num2str(round(fgrid(ifreq))), '_A', ...
	  num2str(round(atten_grid(iamp))), '_d', ...
	  sdur, '_r', srampdur, '_bz', sprezpdur, ...
	  '_ez', spostzpdur, '_Fs', num2str(Fs/1000), '.raw']
    stimfile = fullfile(stimbasedir,filename{ifile})
    
    tonedata = amp_grid(iamp)*sin(fgrid(ifreq)*phasefact);
    
    if do_plots
      ifig = 1;
      hh(ifig) = figure;
      hist(tonedata,100);
      title('Amplitude distribution:  pure tone')
    end
    % wavwrite(tonedata/max(abs(tonedata)),Fs,16,'tone.wav')

    % Add zero padding and ramps
    stimdata = make_ramp(tonedata, ramp_info);
    stim_length_true = length(stimdata);
    
    if do_plots
      ifig = ifig+1;
      hh(ifig) = figure;
      taxis = (0:length(stimdata)-1)/Fs;
      plot(taxis,stimdata)
    end
    
    % Oops forgot this step earlier; I guess we truncated on writing?
    stimdata = round(stimdata);

    % Write out the data.
    write_data(stimdata, data_info, stimfile)
  
    % to play use "play -t raw -swx -c 1 -r 44100 gaussnoise.raw" from sox
    
    if do_stim_spect
      tstring = ['Stimulus spectrum: ', filename{ifile}]
      calc_spect_file(stimfile,data_info,nfft,hanning(nfft),novl,tstring,do_spect_plots);
      ifig = ifig+1;
      hh(ifig) = gcf;
      % End of spectral analysis
    end
    
    if do_plots
      disp('Hit return to continue.')
      pause 
      close(hh)
    end
  end % Loop over amps
end % Loop over freqs

clear stimdata tonedata tdata phasefact

savefile = input(['Enter filename for saving results (path will be', ...
      ' output file dir): '],'s')
savefile = fullfile(stimbasedir, savefile)
save(savefile)

yesno = input('Do you want to create a krank rc file for this stimulus set (y/N)?', 's');
if strncmpi(yesno,'y',1)  
  rcfilename = input('Enter file name (full path) for stimulus rc file: ','s')
  make_stim_rc(rcfilename,stimbasedir,filename,Fs)
end
