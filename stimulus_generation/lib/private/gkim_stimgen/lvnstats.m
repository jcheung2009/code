% Idea here is to go through a batch of song files, compute LVN
% stimuli and statistics for deciding on later artificial 
% stimulus generation.
% Blame Brian D. Wright for this code.

MAXSHORT = 32767
MINSHORT = -32768

do_plot_all = 1
do_adapt = 0

% Right now all song files will be raw byte-swapped files
% Fixed sampling rate
%Fs = 44100
Fs_dflt = 2e7/454 % more precise
%Fs = 44052.9

% Spectrum parameters
do_stim_spect = 1
do_spect_plots = 0
% nfft = 2048
%nfft = 8192 % bump this up to improve freq. resolution
nfft = 65536
novl = 8192
%novl = 256

% Parameters for amplitude distribution
% binsize along the stim axis
deltas = 24/500;
bins = -12:deltas:12;
nbins = length(bins);
% Gaussian for comparison
gausstest = (1/sqrt(2*pi))*exp(-bins.^2/2); 

% Get batch file information and load in files.
batch_info = [];
batch_info = batch_select(batch_info);
batch_info = batch_read(batch_info)

% Do we allow the different sound files have different sampling
% rates? Not right now.
Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

% Will replace this by a range of values
smwin_dur = input('Duration(s) of LV smoothing window in msec: ')
%smwin_dur = 2.0 % Smoothing window duration in msec
smwin_len = 1 + round(smwin_dur*Fs/1000)

% Filtering parameters
filt_info = filter_select;
filt_info = filter_setup(filt_info,Fs);

disp('Choose Local variance window shape:')
disp('(1) Square (causal)')
disp('(2) Hanning (symmetric)')
lvwin_code = input('Enter window type for computing the local variance: [1]')
if lvwin_code == 2
  lvwin_type = 'hanning'
else
  lvwin_type = 'boxcar'
end

% First go through all files and get some global info about the
% songs and their LVN counterparts

disp('Starting first pass through the data: global statistics.')

for ifile=1:batch_info.nfiles

  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});

  % Enscapsulate file reading!
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);

  % Here we filter the songs if requested, The LVN stimulus is not
  % filtered further
  filtsong = filter_data(song,filt_info);

  % Compute basic statistics for each song first
  songlen(ifile) = length(filtsong)
  songmax(ifile) = max(abs(filtsong))
  songmean(ifile) = mean(filtsong)
  songpow = filtsong.^2;
  % This is the
  songvar(ifile) = mean(songpow)
  
  disp(['Song mean for file ', int2str(ifile), ': ', ...
	num2str(songmean(ifile)), ' std: ', ...
	num2str(sqrt(songvar(ifile) - songmean(ifile)^2))])

  time_song =[0:songlen(ifile)-1]*1000/Fs;  % vector for time axis of plots

  % OK now do the same for the LVN stimulus
  nwin = length(smwin_len);
  disp(['Number of LVN estimations to perform: ', num2str(nwin)]) 
  iw = 0;
  for wlen = smwin_len
    iw = iw + 1
    % Compute the LV envelope and the LVN song.
    if strcmp(lvwin_type,'hanning')
      smooth_win = hanning(wlen);    % Square the window for
                                     % comparison with linear measure?
    else
      smooth_win = boxcar(wlen);
    end
    % note conv is causal
    lvenv = conv(smooth_win,songpow);
    lvenv = lvenv/wlen;
    % skip startup transient
    lvenv = lvenv(1+wlen:songlen(ifile));
    zidx = find(lvenv == 0);
    nzidx = find(lvenv ~= 0);
    if ~strcmp(lvwin_type,'boxcar')
      % get rid of convolution induced offset for a symmetric window
      offset=round(wlen/2);
      lvnsong = filtsong(1+offset:songlen(ifile)+offset-wlen)./sqrt(lvenv);
    else
      % This is correct for a causal boxcar window
      lvnsong = filtsong(1+wlen:songlen(ifile))./sqrt(lvenv);
    end
    % Set NAN's to zero
    lvnsong(zidx) = 0;
    lvnsonglen(ifile,iw) = length(lvenv)
    
    lvnsongmax(iw,ifile) = max(abs(lvnsong))
    lvnsongmean(ifile,iw) = mean(lvnsong)
    lvnsongvar(ifile,iw) = mean(lvnsong.^2)
 
    disp(['LVN song mean for file ', int2str(ifile), ' and T = ', ...
	  num2str(smwin_dur(iw)), ' ms is: ', ...
	  num2str(lvnsongmean(ifile,iw)), ' std: ', ...
	  num2str(sqrt(lvnsongvar(ifile,iw) - lvnsongmean(ifile,iw)^2)), ' max: ', num2str(lvnsongmax(iw,ifile))])

    % This is the log of the sqrt of the local variance
    % Deal with NAN here!
    loglv = 0.5*log(lvenv);

    loglvmax(iw,ifile) = max(abs(loglv))
    loglvmean(ifile,iw) = mean(loglv)
    loglvvar(ifile,iw) = mean(loglv.^2)
    disp(['log LV mean for file ', int2str(ifile), ' and T = ', ...
	  num2str(smwin_dur(iw)), ' ms is: ', ...
	  num2str(loglvmean(ifile,iw)), ' std: ', ...
	  num2str(sqrt(loglvvar(ifile,iw) - loglvmean(ifile,iw)^2)), ' max: ', num2str(loglvmax(iw,ifile))])
      
    if iw == 1
      % plot some shit
      % time_song =[0:songlen(ifile)-1]*1000/Fs;  % vector for time axis of plots
    end
  
  end
  
end % Loop over files

% Compute global parameters

songmax_glob = max(songmax)
songlen_glob = sum(songlen)
songmean_glob = sum(songmean.*songlen)/songlen_glob
songstd_glob = sum(songvar.*songlen)/songlen_glob;
songstd_glob = sqrt(songstd_glob - songmean_glob^2)

% Do the same for the LVN stuff
lvnsonglen_glob = sum(lvnsonglen,1)
lvnsongmax_glob = max(lvnsongmax,[],2)
lvnsongmean_glob = sum(lvnsongmean.*lvnsonglen,1)./lvnsonglen_glob
lvnsongstd_glob = sum(lvnsongvar.*lvnsonglen,1)./lvnsonglen_glob;
lvnsongstd_glob = sqrt(lvnsongstd_glob - lvnsongmean_glob.^2)

loglvmax_glob = max(loglvmax,[],2)
loglvmean_glob = sum(loglvmean.*lvnsonglen,1)./lvnsonglen_glob
loglvstd_glob = sum(loglvvar.*lvnsonglen,1)./lvnsonglen_glob;
loglvstd_glob = sqrt(loglvstd_glob - loglvmean_glob.^2)

%
% Second pass through the data to get global amplitude distributions
%
disp('Starting second pass: amplitude distributiuons')

for ifile=1:batch_info.nfiles
  disp(['Working on file ', num2str(ifile)])
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);

  % Here we filter the songs if requested, The LVN stimulus is not
  % filtered further
  filtsong = filter_data(song,filt_info);

  if do_stim_spect
    % Spectral analysis of the stimulus
    disp('Computing stimulus spectrum...')

    psd_len = nfft/2+1;
    psd_avg(:,ifile) = zeros(psd_len,1);    
    tstring = ['Spectrum: ', char(batch_info.filenames{ifile})];
    [psd_avg(:,ifile), freq] = calc_spect(filtsong - songmean_glob,nfft,Fs,hanning(nfft),novl,tstring,do_spect_plots);
    npsdsect(ifile,1) = fix((songlen(ifile) - novl)/(nfft - novl));

    psdenv_avg(:,ifile) = zeros(psd_len,1);
    songpow = (filtsong - songmean_glob).^2;
    songpow = songpow(find(songpow));
    logsongvar = log(songpow);
    tstring = ['Spectrum: Log variance of ', char(batch_info.filenames{ifile})];
    [psdenv_avg(:,ifile), freq] = calc_spect(logsongvar,nfft,Fs,hanning(nfft),novl,tstring,do_spect_plots);
    % End of spectral analysis
    
  end

  normsong = (filtsong - songmean_glob)/songstd_glob;
  % Get amplitude distribution for each file. 
  pamp(ifile,:) = hist(normsong,bins);

  if do_adapt
    disp('Computing amplitude distributions with adaptive binning.')
    % Use estimate of adaptive bin edges from first data file
    % to bin the rest.
    if ifile == 1
      % Nadaptbins = 25
      Nadaptbins = round(length(normsong)^(1/3))
      Nbtstrp = 10
      [pamp_adapt_tmp,pamp_adaptbinc_tmp,pamp_adaptbinedges,pamp_adapt_btstrp_tmp] = computeadaptdist(normsong,Nadaptbins,Nbtstrp);  
    else  
      % Reuse binedges for the remaining files
      [pamp_adapt_tmp,pamp_adaptbinc_tmp,pamp_adaptbinedges,pamp_adapt_btstrp_tmp] = computeadaptdist(normsong,pamp_adaptbinedges,Nbtstrp);
    end
    pamp_adapt(:,ifile) = pamp_adapt_tmp;
    pamp_adapt_btstrp(:,:,ifile) = pamp_adapt_btstrp_tmp;
    pamp_adaptbinc(:,ifile) = pamp_adaptbinc_tmp;
  end
  
  % Get amplitude distributions for the LVN stimulus
  songpow = filtsong.^2;
  iw = 0;
  disp('Computing LVN amplitude distributions...')
  for wlen = smwin_len
    iw = iw + 1
    % Compute the LV envelope and the LVN song.
    if strcmp(lvwin_type,'hanning')
      smooth_win = hanning(wlen);    % Square the window for
                                     % comparison with linear measure?
    else
      smooth_win = boxcar(wlen);
    end
    lvenv = conv(smooth_win,songpow);
    lvenv = lvenv/wlen;
    % skip startup transient
    lvenv = lvenv(1+wlen:songlen(ifile));
    zidx = find(lvenv == 0);
    nzidx = find(lvenv ~= 0);
    if ~strcmp(lvwin_type,'boxcar')
      % get rid of convolution induced offset for a symmetric window
      offset=round(wlen/2);
      lvnsong = filtsong(1+offset:songlen(ifile)+offset-wlen)./sqrt(lvenv);
    else
      % This is correct for a causal boxcar window
      lvnsong = filtsong(1+wlen:songlen(ifile))./sqrt(lvenv);
    end
    % Set NAN's to zero
    lvnsong(zidx) = 0;

    % Now we remove the global mean and set the global variance to 1.
    normlvnsong = (lvnsong - lvnsongmean_glob(iw))/lvnsongstd_glob(iw);
    % Get amplitude distribution for each file and LVN window duration. 
    plvnamp(ifile,:,iw) = zeros(1,nbins,1);
    plvnamp(ifile,:,iw) = hist(normlvnsong,bins);

    % This is the log of the sqrt of the local variance
    % Deal with NAN here!
    loglv = 0.5*log(lvenv);
    
    % Now we remove the global mean and set the global variance to 1.
    normloglv = (loglv - loglvmean_glob(iw))/loglvstd_glob(iw);
    % Get amplitude distribution for each file and LVN window duration. 
    ploglvamp(ifile,:,iw) = zeros(1,nbins,1);
    ploglvamp(ifile,:,iw) = hist(normloglv,bins);

    if do_stim_spect
      % Spectral analysis of the stimulus
      disp('Computing lvn stimulus spectrum...')
      
      psd_len = nfft/2+1;
      lvnpsd_avg(:,ifile,iw) = zeros(psd_len,1,1);    
      tstring = ['Spectrum: LVN ', char(batch_info.filenames{ifile})];
      [lvnpsd_avg(:,ifile,iw), freq] = calc_spect(lvnsong - lvnsongmean_glob(iw),nfft,Fs,hanning(nfft),novl,tstring,do_spect_plots);
      nlvnpsdsect(ifile,iw) = fix((lvnsonglen(ifile,iw) - novl)/(nfft - novl));

      % Get spectrum of the log local variance envelope
      disp('Computing log lv spectrum...')
      loglvpsd_avg(:,ifile,iw) = zeros(psd_len,1,1);
      tstring = ['Spectrum: Log LV ', char(batch_info.filenames{ifile})];
      [loglvpsd_avg(:,ifile,iw), freq] = calc_spect(loglv - loglvmean_glob(iw),nfft,Fs,hanning(nfft),novl,tstring,do_spect_plots);
      
      % End of spectral analysis
    end

    if do_adapt
      % Add the adaptive binning stuff here
      disp('Computing LVN amplitude distributions with adaptive binning.')
      % Use estimate of adaptive bin edges from first data file
      % to bin the rest.
      if ifile == 1
	Nlvnadaptbins = round(length(normlvnsong)^(1/3))
	Nbtstrp = 10
	[plvnamp_adapt_tmp,plvnamp_adaptbinc_tmp,plvnamp_adaptbinedges(:,iw),plvnamp_adapt_btstrp_tmp] = computeadaptdist(normlvnsong,Nlvnadaptbins,Nbtstrp);  
	plvnamp_adapt_btstrp(:,:,ifile,iw) = plvnamp_adapt_btstrp_tmp;
      else  
	% Reuse binedges for the remaining files
	[plvnamp_adapt_tmp,plvnamp_adaptbinc_tmp,plvnamp_adaptbinedges(:,iw)] = computeadaptdist(normlvnsong,plvnamp_adaptbinedges(:,iw),0);
      end
      plvnamp_adapt(:,ifile,iw) = plvnamp_adapt_tmp;
      plvnamp_adaptbinc(:,ifile,iw) = plvnamp_adaptbinc_tmp;
    end
  end % Loop over windows
  
end % Loop over files

% This makes it a probability distribution
pamp_glob = sum(pamp,1)/(sum(sum(pamp))*deltas);

% Fudge the distribution by symmetrizing it to remove +ve vs. -ve
% amplitude nonlinearity
pampsym = (pamp_glob + pamp_glob(nbins:-1:1))/2;

% Do the same for the LVN stuff
for iw=1:nwin
  plvnamp_glob(iw,:) = sum(plvnamp(:,:,iw),1)/(sum(sum(plvnamp(:,:,iw),2),1)*deltas);
  ploglvamp_glob(iw,:) = sum(ploglvamp(:,:,iw),1)/(sum(sum(ploglvamp(:,:,iw),2),1)*deltas);
end

% Fudge the distribution by symmetrizing it to remove +ve vs. -ve
% amplitude nonlinearity
plvnampsym = (plvnamp_glob + plvnamp_glob(:,nbins:-1:1))/2;

if do_stim_spect
  % Weight the psd estimates by the amount of data used for each.
  % This was not quite correct in previous versions.
  psd_glob = psd_avg*npsdsect/sum(npsdsect);
  psdenv_glob = psdenv_avg*npsdsect/sum(npsdsect);

  figure;
  plot(freq,10*log10(psd_glob));
  xlabel('Freq. (Hz)');
  ylabel('PSD (dB)');
  title(['Total Stimulus spectrum, batchfile: ', batch_info.batchfilename],'Interpreter','none');
  grid on;

  figure;
  semilogx(freq,10*log10(psdenv_glob));
  xlabel('Freq. (Hz)');
  ylabel('PSD (dB)');
  title(['Total log(stimulus variance) spectrum, batchfile: ', batch_info.batchfilename],'Interpreter','none');
  grid on;

  % Get global PSD estimates for later stimulus matching
  lvnpsd_tmp = zeros(psd_len,batch_info.nfiles);
  loglvpsd_tmp = zeros(psd_len,batch_info.nfiles);
  for iw=1:nwin
    lvnpsd_tmp = lvnpsd_avg(:,:,iw);
    lvnpsd_glob(:,iw) = lvnpsd_tmp*nlvnpsdsect(:,iw)/sum(nlvnpsdsect(:,iw),1);
    loglvpsd_tmp = loglvpsd_avg(:,:,iw);
    loglvpsd_glob(:,iw) = loglvpsd_tmp*nlvnpsdsect(:,iw)/sum(nlvnpsdsect(:,iw),1);
  end

  if do_plot_all
    for iw=1:nwin
      figure;
      plot(freq,10*log10(lvnpsd_glob(:,iw)));
      xlabel('Freq. (Hz)');
      ylabel('PSD (dB)');
      title(['Total Stimulus spectrum, LVN T = ', ...
	    num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename],'Interpreter','none');
      grid on;

      figure;
      semilogx(freq,10*log10(lvnpsd_glob(:,iw)));
      xlabel('Freq. (Hz)');
      ylabel('PSD (dB)');
      title(['Total Stimulus spectrum, LVN T = ', ...
	    num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename],'Interpreter','none');
      grid on;

      figure;
      plot(freq,10*log10(loglvpsd_glob(:,iw)));
      xlabel('Freq. (Hz)');
      ylabel('PSD (dB)');
      title(['Total Stimulus spectrum, 0.5 log(LV) T = ', ...
	    num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename],'Interpreter','none');
      grid on;
    
      figure;
      semilogx(freq,10*log10(loglvpsd_glob(:,iw)));
      xlabel('Freq. (Hz)');
      ylabel('PSD (dB)');
      title(['Total Stimulus spectrum, 0.5 log(LV) T = ', ...
	    num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename],'Interpreter','none');
      grid on;
      
    end
  else
    iw = 1
    figure;
    plot(freq,10*log10(lvnpsd_glob(:,iw)));
    xlabel('Freq. (Hz)');
    ylabel('PSD (dB)');
    title(['Total Stimulus spectrum, LVN T = ', ...
	  num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename],'Interpreter','none');
    grid on;  
    
    figure;
    plot(freq,10*log10(loglvpsd_glob(:,iw)));
    xlabel('Freq. (Hz)');
    ylabel('PSD (dB)');
    title(['Total Stimulus spectrum, 0.5 log(LV) T = ', ...
	  num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename],'Interpreter','none');
    grid on;
  end
end

figure;
semilogy(bins,[pamp_glob; gausstest]);
xlabel('sound pressure/std dev');
ylabel('prob density');
title(['distribution of instantaneous signals, batchfile: ', batch_info.batchfilename]);
axis([-12 12 0.00001 1]);
axis square;

figure;
semilogy(bins,[pampsym; gausstest]);
xlabel('sound pressure/std dev');
ylabel('prob density');
title(['distribution of instantaneous signals (symmetrized), batchfile: ', batch_info.batchfilename]);
axis([-12 12 0.00001 1]);
axis square;

nzidx = find(gausstest ~= 0 & pamp_glob ~= 0); 
DKL_gausssong = deltas*sum(gausstest(nzidx).*log2(gausstest(nzidx)./pamp_glob(nzidx)))

DKL_songgauss = deltas*sum(pamp_glob(nzidx).*log2(pamp_glob(nzidx)./gausstest(nzidx)))

nzidx = find(gausstest ~= 0 & pampsym ~= 0); 
DKL_gausssongsym = deltas*sum(gausstest(nzidx).*log2(gausstest(nzidx)./pampsym(nzidx)))

DKL_songsymgauss = deltas*sum(pampsym(nzidx).*log2(pampsym(nzidx)./gausstest(nzidx)))

for iw=1:nwin
  if do_plot_all
    figure;
    semilogy(bins,[plvnamp_glob(iw,:); gausstest]);
    xlabel('sound pressure/std dev');
    ylabel('prob density');
    title(['distribution of instantaneous signals, LVN T = ', ...
	  num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename]);
    axis([-12 12 0.00001 1]);
    axis square;

    figure;
    semilogy(bins,[plvnampsym(iw,:); gausstest]);
    xlabel('sound pressure/std dev');
    ylabel('prob density');
    title(['distribution of instantaneous signals (symmetrized), LVN T = ', ...
	  num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename]);
    axis([-12 12 0.00001 1]);
    axis square;
  
    figure;
    semilogy(bins,[ploglvamp_glob(iw,:); gausstest]);
    xlabel('sound pressure/std dev');
    ylabel('prob density');
    title(['distribution of instantaneous signals, 0.5 log(LV) T = ', ...
	  num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename]);
    axis([-12 12 0.00001 1]);
    axis square;

  else
    if iw == 1
      figure;
      semilogy(bins,[plvnamp_glob(iw,:); gausstest]);
      xlabel('sound pressure/std dev');
      ylabel('prob density');
      title(['distribution of instantaneous signals, LVN T = ', ...
	    num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename]);
      axis([-12 12 0.00001 1]);
      axis square;
      
      figure;
      semilogy(bins,[plvnampsym(iw,:); gausstest]);
      xlabel('sound pressure/std dev');
      ylabel('prob density');
      title(['distribution of instantaneous signals (symmetrized), LVN T = ', num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename]);
      axis([-12 12 0.00001 1]);
      axis square;      

      figure;
      semilogy(bins,[ploglvamp_glob(iw,:); gausstest]);
      xlabel('sound pressure/std dev');
      ylabel('prob density');
      title(['distribution of instantaneous signals, 0.5 log(LV) T = ', ...
	    num2str(smwin_dur(iw)), ' ms, batchfile: ', batch_info.batchfilename]);
      axis([-12 12 0.00001 1]);
      axis square;
    end
  end
  nzidx = find(plvnamp_glob(iw,:) ~= 0 & gausstest ~= 0); 
  DKL_gausslvn(iw) = deltas*sum(gausstest(nzidx).*log2(gausstest(nzidx)./plvnamp_glob(iw,nzidx)))

  DKL_lvngauss(iw) = deltas*sum(plvnamp_glob(iw,nzidx).*log2(plvnamp_glob(iw,nzidx)./gausstest(nzidx)))

  nzidx = find(plvnampsym(iw,:) ~= 0 & gausstest ~= 0);
  DKL_gausslvnsym(iw) = deltas*sum(gausstest(nzidx).*log2(gausstest(nzidx)./plvnampsym(iw,nzidx)))

  DKL_lvnsymgauss(iw) = deltas*sum(plvnampsym(iw,nzidx).*log2(plvnampsym(iw,nzidx)./gausstest(nzidx)))

  nzidx = find(ploglvamp_glob(iw,:) ~= 0 & gausstest ~= 0); 
  DKL_gaussloglv(iw) = deltas*sum(gausstest(nzidx).*log2(gausstest(nzidx)./ploglvamp_glob(iw,nzidx)))

  DKL_loglvgauss(iw) = deltas*sum(ploglvamp_glob(iw,nzidx).*log2(ploglvamp_glob(iw,nzidx)./gausstest(nzidx)))

end

% Let's do a better gaussian test with the uniform binning.
binedges = bins - (deltas/2);
binedges = [binedges, bins(end) + (deltas/2)];
Pgauss = (normcdf(binedges(2:nbins+1)) - normcdf(binedges(1:nbins)))/deltas;

for iw=1:nwin
  Plvnamp_glob = plvnamp_glob(iw,:)*deltas;
  nzidx = find(Pgauss ~= 0 & plvnamp_glob(iw,:) ~= 0); 
  DKL_gausslvn2(iw) = deltas*sum(Pgauss(nzidx).*log2(Pgauss(nzidx)./plvnamp_glob(iw,nzidx)))

  DKL_lvngauss2(iw) = deltas*sum(plvnamp_glob(iw,nzidx).*log2(plvnamp_glob(iw,nzidx)./Pgauss(nzidx)))

  Ploglvamp_glob = ploglvamp_glob(iw,:)*deltas;
  nzidx = find(Pgauss ~= 0 & ploglvamp_glob(iw,:) ~= 0); 
  DKL_gaussloglv2(iw) = deltas*sum(Pgauss(nzidx).*log2(Pgauss(nzidx)./ploglvamp_glob(iw,nzidx)))

  DKL_loglvgauss2(iw) = deltas*sum(ploglvamp_glob(iw,nzidx).*log2(ploglvamp_glob(iw,nzidx)./Pgauss(nzidx)))

end

% Output results for the D_KL as a function of window duration

figure
plot(smwin_dur,DKL_gausslvnsym)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
tline{1} = ('D_{KL}(Normal distribution || normalized LVN (symmetrized))')
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_lvnsymgauss)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
tline{1} = 'D_{KL}(normalized LVN (symmetrized) || Normal distribution)';
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_gausslvn)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
tline{1} = ('D_{KL}(Normal distribution || normalized LVN)')
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_lvngauss)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
tline{1} = 'D_{KL}(normalized LVN || Normal distribution)';
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_gausslvn2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
tline{1} = ('D_{KL}(Normal distribution || normalized LVN) using better Gaussian estimate')
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_lvngauss2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
tline{1} = 'D_{KL}(normalized LVN || Normal distribution) using better Gaussian estimate';
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_gaussloglv)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
tline{1} = ('D_{KL}(Normal distribution || normalized 0.5 log(LV))')
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_loglvgauss)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
tline{1} = 'D_{KL}(normalized 0.5 log(LV) || Normal distribution)';
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_gaussloglv2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
tline{1} = ('D_{KL}(Normal distribution || normalized 0.5 log(LV)) using better Gaussian estimate')
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

figure
plot(smwin_dur,DKL_loglvgauss2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
tline{1} = 'D_{KL}(normalized 0.5 log(LV) || Normal distribution) using better Gaussian estimate';
tline{2} = ['Batchfile: ', batch_info.batchfilename];
title(char(tline))

[DKL_min, iw_min] = min(DKL_lvnsymgauss)
lvwin_min = smwin_dur(iw_min)

[DKL2_min, iw2_min] = min(DKL_gausslvnsym)
lvwin2_min = smwin_dur(iw2_min)

% Try to do adaptive binning for the D_KL
if 0
  % This is trying to do adaptive binning by rebinning the existing
  % histogram (uniform bins). Maybe not so good...
  histamp_glob = sum(pamp,1);
  histampsym = (histamp_glob + histamp_glob(nbins:-1:1))/2;
  
  [nmax,inmax] = max(histampsym) 
  valmax = bins(inmax)
  maxbinc = max(bins)
  istart = 251
  iend = istart
  n_occ = histampsym(istart)
  iabin = 1
  adaptposbinc(iabin) = bins(istart)
  
  while istart < length(bins)
    n_occ = histampsym(istart)
    while n_occ < nmax & iend < length(bins)
      iend = iend+1;
      n_occ = n_occ + histampsym(iend)
    end 
    adaptposbinc(iabin) = ...
	sum(bins(istart:iend).*histampsym(istart:iend))/sum(histampsym(istart:iend))
    adaptposbinedges(iabin) = bins(iend) + (deltas/2)
    adaptposbinocc(iabin) = n_occ
    
    istart = iend + 1
    iend = istart
    iabin = iabin + 1
    
  end
end

%
% OK here's some more sophisticated adaptively binned analysis
%
if do_adapt
  % Combine results across files to get the bin centers
  pamp_adaptbinc_glob = sum(pamp_adaptbinc.*pamp_adapt,2)./sum(pamp_adapt,2);
  
  adaptbinwidths = pamp_adaptbinedges(2:Nadaptbins+1) - pamp_adaptbinedges(1:Nadaptbins);
  
  pamp_adapt_glob = sum(pamp_adapt,2)/sum(sum(pamp_adapt)); 
  
  % Let's compare this result with the corresponding Gaussian
  pgauss_adapt = normcdf(pamp_adaptbinedges(2:Nadaptbins+1)) - ...
      normcdf(pamp_adaptbinedges(1:Nadaptbins));    
  
  nzidx = find(pgauss_adapt ~= 0 & pamp_adapt_glob ~= 0); 
  DKL_gausssongadapt = sum(pgauss_adapt(nzidx).*log2(pgauss_adapt(nzidx)./pamp_adapt_glob(nzidx)))
  
  DKL_songgaussadapt = sum(pamp_adapt_glob(nzidx).*log2(pamp_adapt_glob(nzidx)./pgauss_adapt(nzidx)))
  
  % The wrong way...
  gausstest2 = (1/sqrt(2*pi))*exp(-pamp_adaptbinc_glob.^2/2); 
  gausstest2 = gausstest2.*adaptbinwidths;
  
  nzidx = find(gausstest2 ~= 0 & pamp_adapt_glob ~= 0); 
  DKL_gausssongadapt2 = sum(gausstest2(nzidx).*log2(gausstest2(nzidx)./pamp_adapt_glob(nzidx)))
  
  DKL_songgaussadapt2 = sum(pamp_adapt_glob(nzidx).*log2(pamp_adapt_glob(nzidx)./gausstest2(nzidx)))

end

% Let's do a better gaussian test with the uniform binning.
binedges = bins - (deltas/2);
binedges = [binedges, bins(end) + (deltas/2)];
pgauss = (normcdf(binedges(2:nbins+1)) - normcdf(binedges(1:nbins)))/deltas;

nzidx = find(pgauss ~= 0 & pamp_glob ~= 0); 
DKL_gausssong2 = deltas*sum(pgauss(nzidx).*log2(pgauss(nzidx)./pamp_glob(nzidx)))

DKL_songgauss2 = deltas*sum(pamp_glob(nzidx).*log2(pamp_glob(nzidx)./pgauss(nzidx)))

% Look at D_KL for each file
pampnorm = pamp./(sum(pamp,2)*ones(1,nbins)*deltas);
for ifile=1:batch_info.nfiles
  nzidx = find(pgauss(1,:)' ~= 0 & pampnorm(ifile,:)' ~= 0); 
  DKL_gausssongf(ifile) = deltas*sum(pgauss(1,nzidx).*log2(pgauss(1,nzidx)./pampnorm(ifile,nzidx)),2)
  
  DKL_songgaussf(ifile) = deltas*sum(pampnorm(ifile,nzidx).*log2(pampnorm(ifile,nzidx)./pgauss(1,nzidx)),2)

end  

%nzidx = find(pampnorm(ifile-1,:)' ~= 0 & pampnorm(ifile,:)' ~= 0); 
%DKL_songsong = deltas*sum(pampnorm(ifile-1,nzidx).*log2(pampnorm(ifile-1,nzidx)./pampnorm(ifile,nzidx)),2)

% Look at the D_KL error estimate using the bootstrap estimates
if do_adapt
  for ifile=1:batch_info.nfiles
    for K=1:Nbtstrp
      pampnorm_adapt_btstrp = pamp_adapt_btstrp(:,K,ifile)/sum(pamp_adapt_btstrp(:,K,ifile),1);
      
      nzidx = find(pgauss_adapt ~= 0 & pampnorm_adapt_btstrp ~= 0); 
      DKL_gausssongadapt_btstrp(K,ifile) = sum(pgauss_adapt(nzidx).*log2(pgauss_adapt(nzidx)./pampnorm_adapt_btstrp(nzidx)))
      DKL_songgaussadapt_btstrp(K,ifile) = sum(pampnorm_adapt_btstrp(nzidx).*log2(pampnorm_adapt_btstrp(nzidx)./pgauss_adapt(nzidx)))
      
    end
  end
  DKL_gausssongadapt_mean = mean(DKL_gausssongadapt_btstrp,1)
  DKL_songgaussadapt_mean = mean(DKL_songgaussadapt_btstrp,1)
  DKL_gausssongadapt_std = std(DKL_gausssongadapt_btstrp,1)
  DKL_songgaussadapt_std = std(DKL_songgaussadapt_btstrp,1)
  
  % Do analysis of lvn adaptive binning here
end
  
disp('Hit return to continue')
pause

disp('Done.')

% Clear temporary data variables
clear song filtsong normsong songpow time_song logsongvar
clear lvnsong normlvnsong
clear lvenv loglv normloglv

savefile = input(['Enter filename for saving results (path will be', ...
      ' data base dir): '],'s')
savefile = fullfile(batch_info.basedir, savefile)
save(savefile)

% save results for later stimulus generation

yesno = input(['Do you want to save results for each LV time window in files for later processing? (y/N) '],'s')
if strncmpi(yesno,'y',1)  
  savefilestatsdir = input(['Enter directory location for saving natural statistics information [', ...
	batch_info.basedir, ']: '], 's')
  if isempty(savefilestatsdir)
    savefilestatsdir = batch_info.basedir
  end
  
  savefilestatsprefix = input(['Enter file name prefix for saving natural statistics information: '], 's')
  ensemble.files = batch_info.filenames;
  ensemble.batchfile = batch_info.batchfilename;
  ensemble.file_lengths = songlen;
  ensemble.basedir = batch_info.basedir;
  ensemble.max = songmax_glob;
  ensemble.mean = songmean_glob;
  ensemble.std = songstd_glob;
  ensemble.psd = psd_glob;
  ensemble.psd_nfft = nfft;
  ensemble.psd_freq = freq;
  ensemble.Fs = Fs;
  
  for iw = 1:nwin
    savefilestats = ...
	fullfile(savefilestatsdir,[savefilestatsprefix, '_T', ...
	  num2str(smwin_dur(iw)), '.mat'])

    ensemble.envelope.type = 'log_sqrt_LV' 
    ensemble.envelope.win_type = lvwin_type 
    ensemble.envelope.win_dur = smwin_dur(iw)
    ensemble.envelope.psd = loglvpsd_glob(:,iw)
    ensemble.envelope.mean = loglvmean_glob(iw)
    ensemble.envelope.std = loglvstd_glob(iw)
    
    ensemble.carrier.type = 'LVN' 
    ensemble.carrier.win_type = lvwin_type 
    ensemble.carrier.win_dur = smwin_dur(iw)
    ensemble.carrier.psd = lvnpsd_glob(:,iw)
    ensemble.carrier.mean = lvnsongmean_glob(iw)
    ensemble.carrier.std = lvnsongstd_glob(iw)
    
    save(savefilestats,'ensemble')
  end
end  
