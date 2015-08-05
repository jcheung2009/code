function atten = gk_songstats

% ATTEN = GK_SONGSTATS
%
% Modified from gk_songensemblestats.m
% - Simple stats of sound files
% - Asks for a batch file
% - Can choose to compute either a global attenuation factor
% or attenuation factors for individual files
% 


% Go through batch of song files and gather relevant statistics:
% mean, rms, spectrum

MAXSHORT = 32767
MINSHORT = -32768
MAX_DA = 32767
MIN_DA = -32768

% Measured amplification factor
AMP_FACTOR = 25.2 % May 2007 calibration

% Right now all song files will be raw byte-swapped files
% Fixed sampling rate
%Fs = 44100
Fs_dflt = 2e7/454 % more precise
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

% Spectrum parameters
do_stim_spect = 0
do_spect_plots = 1
%nfft = 32768
nfft = 2048         % GK
%novl = fix(nfft/4)
novl = fix(nfft/2)  % GK

% Get batch file information and load in files.
batch_info = [];
batch_info = gk_batch_select(batch_info);   %GK
batch_info = gk_batch_read(batch_info)      %GK

% Do we allow the different sound files have different sampling
% rates? Not right now.
Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

% Filtering parameters
filt_info = filter_select;
filt_info = filter_setup(filt_info,Fs);

% Do you want to compute attenuation factor to set stim at 85dB?
disp(' ')
disp('Compute attenuation factor to set stim at 85dB? ')
disp('  [1] get an atten factor for each file')
disp('   2  get a global atten factor')
disp('   3  do not get atten factor')
do_atten_factor = input(':  ')
if isempty(do_atten_factor)
  do_atten_factor = 1
end

for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);
  
  filtsong = filter_data(song,filt_info);

  % Compute basic statistics for each song first
  
  songlen(ifile) = length(filtsong);
  songmax(ifile) = max(abs(filtsong));
  songmean(ifile) = mean(filtsong);
%  songvar(ifile) = cov(filtsong)
  songvar(ifile) = mean(filtsong.^2);
  
  disp(['Song mean for file ', int2str(ifile), ': ', ...
	num2str(songmean(ifile)), ' std: ', ...
	num2str(sqrt(songvar(ifile) - songmean(ifile)^2))])

  if do_atten_factor == 1
    atten(ifile) = 20*log10(sqrt(songvar(ifile)-songmean(ifile)^2)) + AMP_FACTOR - 85;
  end

  normsong = filtsong - songmean(ifile);

  if do_stim_spect
    % Spectral analysis of the stimulus
    disp('Computing stimulus spectrum...')

    psd_len = nfft/2+1;
    psd_avg(:,ifile) = zeros(psd_len,1);    

    tstring = ['Spectrum: ', char(batch_info.filenames{ifile})];
    [psd_avg(:,ifile), freq] = calc_spect(normsong,nfft,Fs,hanning(nfft),novl,tstring,do_spect_plots);
    npsdsect(ifile,1) = fix((songlen(ifile) - novl)/(nfft - novl));
  
    % End of spectral analysis
  end
  
end

% Compute global parameters

songmax_glob = max(songmax)
songlen_glob = sum(songlen)
songmean_glob = sum(songmean.*songlen)/songlen_glob
songstd_glob = sum(songvar.*songlen)/songlen_glob;
songstd_glob = sqrt(songstd_glob - songmean_glob^2)
%songstd_glob = sqrt(sum(songvar.*(songlen - 1))/(songlen_glob - 1))

if do_atten_factor == 2
    atten = 20*log10(songstd_glob) + AMP_FACTOR - 85
end

if do_stim_spect
  % Weight the psd estimates by the amount of data used for each.
  % This was not quite correct in previous versions.
  psd_glob = psd_avg*npsdsect/sum(npsdsect);
  %psd_glob = sum(psd_avg',1)/batch_info.nfiles;
  
  figure;
  plot(freq,10*log10(psd_glob));
  xlabel('Freq. (Hz)');
  ylabel('PSD (dB)');
  title(['Total Stimulus spectrum, batchfile: ', batch_info.batchfilename],'Interpreter','none');
  grid on;
end
  
disp('Done.')

% clear song filtsong normsong
% 
% savefile = input(['Enter filename for saving results (path will be', ...
%       ' data base dir): '],'s')
% savefile = fullfile(batch_info.basedir, savefile)
% save(savefile)





