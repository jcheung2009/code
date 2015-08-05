% Go through batch of song files and gather relevant statistics:
% mean, rms, center cut rms, center cut peak rms, spectrum

MAXSHORT = 32767
MINSHORT = -32768
MAX_DA = 32767
MIN_DA = -32768

% Right now all song files will be raw byte-swapped files
% Fixed sampling rate
%Fs = 44100
Fs_dflt = 2e7/454 % more precise
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

% Normalization parameters
cutfrac = 0.1
Nstd_dflt = 4.0

% Spectrum parameters
do_stim_spect = 1
do_spect_plots = 0
nfft = 32768
%nfft = 2048
novl = fix(nfft/4)

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

Nstd = input(['Enter number of center cut peak standard deviations' ...
      ' for clipping the output [', num2str(Nstd_dflt), ']: ']);
if isempty(Nstd)
  Nstd = Nstd_dflt;
end

for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);
  
  filtsong = filter_data(song,filt_info);

  % Compute basic statistics for each song first
  
  songlen(ifile) = length(filtsong)
  songmax(ifile) = max(abs(filtsong))
  songmean(ifile) = mean(filtsong)
%  songvar(ifile) = cov(filtsong)
  songvar(ifile) = mean(filtsong.^2)
  
  disp(['Song mean for file ', int2str(ifile), ': ', ...
	num2str(songmean(ifile)), ' std: ', ...
	num2str(sqrt(songvar(ifile) - songmean(ifile)^2))])
  
end

% Compute global parameters

songmax_glob = max(songmax)
songlen_glob = sum(songlen)
songmean_glob = sum(songmean.*songlen)/songlen_glob
songstd_glob = sum(songvar.*songlen)/songlen_glob;
songstd_glob = sqrt(songstd_glob - songmean_glob^2)
%songstd_glob = sqrt(sum(songvar.*(songlen - 1))/(songlen_glob - 1))

%disp('Hit return to continue')
%pause
% Now go back through files and get center cut rms values
% based on global parameters

ccut = songmax_glob*cutfrac

for ifile=1:batch_info.nfiles
  songfile = fullfile(batch_info.basedir,char(batch_info.filenames{ifile}));
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);
  
  filtsong = filter_data(song,filt_info);
  normsong = filtsong - songmean_glob;

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
  
  [ccpvar(ifile),ccpmean(ifile),nccp(ifile)] = calc_ccpstats(normsong,ccut);
  ccprms(ifile) = sqrt(ccpvar(ifile) - ccpmean(ifile)^2);
  disp(['Center clipped peak rms, file ', int2str(ifile), ': ', ...
	num2str(ccprms(ifile))])
  
  [ccvar(ifile),ccmean(ifile),ncc(ifile)] = calc_ccstats(normsong,ccut);
  ccrms(ifile) = sqrt(ccvar(ifile) - ccmean(ifile)^2);
  disp(['Center clipped rms, file ', int2str(ifile), ': ', ...
	num2str(ccrms(ifile))])
  
end  
  
ccpmean_glob = sum(ccpmean.*nccp)/sum(nccp)
ccmean_glob = sum(ccmean.*ncc)/sum(ncc)

ccpstd_glob = sum(ccpvar.*nccp)/(sum(nccp) - 1);
ccpstd_glob = sqrt(ccpstd_glob)
%ccpstd_glob = sqrt(ccpstd_glob - ccpmean_glob^2)
ccstd_glob = sum(ccvar.*ncc)/(sum(ncc) - 1);
ccstd_glob = sqrt(ccstd_glob)
%ccstd_glob = sqrt(ccstd_glob - ccmean_glob^2)

range_glob = Nstd*ccpstd_glob
gain_glob = (MAXSHORT-MINSHORT)/(2*range_glob+1)

disp(['Global range setting: ', num2str(range_glob)])
disp(['Global gain setting: ', num2str(gain_glob)])

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

clear song filtsong normsong

savefile = input(['Enter filename for saving results (path will be', ...
      ' data base dir): '],'s')
savefile = fullfile(batch_info.basedir, savefile)
save(savefile)





