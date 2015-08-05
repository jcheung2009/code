% Idea here is to go through a batch of song files, compute LVN
% stimuli and statistics for deciding on later artificial 
% stimulus generation.
% This particular code does not assume the same recording
% conditions from file to file, so global mean subtraction and variance
% normalization are done with respect to each file.

% Blame Brian D. Wright for this code.

MAXSHORT = 32767
MINSHORT = -32768

do_plot_all = 1
do_adapt = 0
do_global_norm = 0

% Right now all song files will be raw byte-swapped files
% Fixed sampling rate
Fs = 44100

% Normalization parameters
cutfrac = 0.1
Nstd = 4.0

% Spectrum parameters
DO_STIM_SPECT = 0
nfft = 2048
novl = 256

% Parameters for amplitude distribution
% binsize along the stim axis
deltas = 24/500;
bins = -12:deltas:12;
nbins = length(bins);
% Gaussian for comparison
gausstest = (1/sqrt(2*pi))*exp(-bins.^2/2); 

% Get batch file information

while 1
  batchfilename = input('Enter batch file name: ','s');
  if isempty(batchfilename)
    disp('You must enter a batch file. Try again.')
  else
    fidb = fopen(batchfilename,'r');
    if fidb == -1
      disp('Invalid batch file name. Try again.') 
    else
      break;
    end
  end
end
songbasedir = '/net/laswell/susasongs_filt'
%songbasedir = input('Enter base directory for song files: ','s')
yesno = input('Do you want to process notes only (y/N)? ','s');
do_notes = 0;
if strncmpi(yesno,'y',1)
  do_notes = 1;
end

if do_notes
  songresultsdir = '/net/laswell/A_Storehand_seg_class'
%  songresultsdir = input(['Enter directory where notes for the' ...
%	' songs are stored: '], 's')
end

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

% Will replace this by a range of values
smwin_dur = input('Duration(s) of LV smoothing window in msec: ')
%smwin_dur = 2.0 % Smoothing window duration in msec
smwin_len = 1 + round(smwin_dur*Fs/1000)

% Filtering parameters
disp('Bandpass Filter Types Menu:')
disp('(0) [None]')
disp('(1) Kaiser window FIR (500-8000 Hz)')
disp('(2) Hanning Window FIR (variable Fc)')
disp('(3) Butterworth IIR (variable Fc)')
disp('(4) High pass Hanning window FIR (variable Fc)')

disp(' ')
filtcode = input(['What type of filter do you want: (0-4)? '])
if filtcode == 1
  FILTTYPE = 'kaiserfir'
elseif filtcode == 2
  FILTTYPE = 'hanningfir'
  F_low = input('Enter low frequency cutoff: ')
  F_high = input('Enter high frequency cutoff: ')  
elseif filtcode == 3
  FILTTYPE = 'butter'
  F_low = input('Enter low frequency cutoff: ')
  F_high = input('Enter high frequency cutoff: ')  
elseif filtcode == 4
  FILTTYPE = 'hipass'
  F_low = input('Enter low frequency cutoff: ')
else
  FILTTYPE = 'none'
end
  
if filtcode
  yesno = input('Do you want to use matlab ''filtfilt'' function (''filter'' is default) (y/N)? ','s')
  if strncmpi(yesno,'y',1)
    do_filtfilt = 1
  else
    do_filtfilt = 0
  end
  switch lower(FILTTYPE)
    case 'kaiserfir'
      % FIR filter design with a Kaiser window
      % This one looks like a nice filter to use (don't erase!)
      Rp = 3.266
      Rs = 30
      %fbands = [500 600 8000 8800]
      fbands = [293 453.1 8223 8328]
      amps = [0 1 0]
      devs = [10^(-Rs/20) (10^(Rp/20)-1)/(10^(Rp/20)+1) 10^(-Rs/20)]
      [nfir,Wnfir,beta,ftype] = kaiserord(fbands,amps,devs,Fs);
      nfir = nfir + rem(nfir,2)
      ndelay = fix(nfir/2)
      bfir = fir1(nfir,Wnfir,ftype,kaiser(nfir+1,beta));
%      figure;
%      freqz(bfir,1,nfft,Fs)
%      figure;
%      grpdelay(bfir,1,nfft,Fs)
    case 'hanningfir'
      nfir = 512
      ndelay = fix(nfir/2)  
      bfir = fir1(nfir,[F_low*2/Fs, F_high*2/Fs]);
%      figure;
%      freqz(bfir,1,nfft,Fs)
%      figure;
%      grpdelay(bfir,1,nfft,Fs)
    case 'hipass'
      nfir = 512
      ndelay = fix(nfir/2) 
      bfir = fir1(nfir, F_low*2/Fs, 'high');
      figure;
      freqz(bfir,1,nfft,Fs)
      figure;
      grpdelay(bfir,1,nfft,Fs)

   end
end

% First generate file list
ifile = 0;
disp('Starting first pass through the data: global statistics.')
while 1
  ifile = ifile+1;
  thissongname = fgetl(fidb);
  % Check for whitespace here!
  spaceflag = 0;
  if isspace(thissongname)
    spaceflag = 1
  end
  if (~ischar(thissongname)) | isempty(thissongname) | spaceflag
    disp('End of batch file reached.')
    break
  end
  songname{ifile}  = thissongname; 
end
fclose(fidb);
nfiles = ifile-1

% Get notes info if needed
if do_notes
  noteinfo = load_notes(songname,songresultsdir);
end

%pause

% Go through all files and get some global info about the
% songs and their LVN counterparts
disp('Starting first pass through the data: global statistics.')

for ifile=1:nfiles
  disp(['Working on file ', num2str(ifile)])
  songfile = fullfile(songbasedir,songname{ifile});

  if strcmp(filetype,'b')
    fids = fopen(songfile,'r','b');
    [song, songlenraw] = fread(fids,inf,'int16');
    fclose(fids);
  else
    [song,Fs,Fmt] = wavread16(songfile);
    songlenraw = length(song);
  end
    
  % Here we filter the songs if requested, The LVN stimulus is not
  % filtered further
  if filtcode
    switch lower(FILTTYPE)
      case 'butter'
	filtsong = bandpass(song,Fs,F_low,F_high);  
      case {'hanningfir', 'kaiserfir', 'hipass'}
	if do_filtfilt
	  filtsong = filtfilt(bfir,1,song);
	else
	  z = [];
	  [filtsongd, z] = filter(bfir,1,song,z);
	  % Note filtered song corrected for the delay is shorter in length!
	  filtsong = filtsongd(1+ndelay:length(filtsongd));
	end
    end
  else 
    filtsong = song;    
  end

  % Compute basic statistics for each song first
  songlen(ifile) = length(filtsong)
  songmax(ifile) = max(abs(filtsong))
  songmean(ifile) = mean(filtsong)
  songpow = filtsong.^2;
  songvar(ifile) = mean(songpow);
  songstd(ifile) = sqrt(mean((filtsong - mean(filtsong)).^2))
  songstd1(ifile) = sqrt(songvar(ifile) - songmean(ifile)^2);
  
  disp(['Song mean for file ', int2str(ifile), ': ', ...
	num2str(songmean(ifile)), ' std: ', ...
	num2str(sqrt(songvar(ifile) - songmean(ifile)^2))])

  time_song =[0:songlen(ifile)-1]*1000/Fs;  % vector for time axis of plots
    
  if DO_STIM_SPECT
    % Spectral analysis of the stimulus
    disp('Computing stimulus spectrum...')

    psd_len = nfft/2+1;
    psd_avg(:,ifile) = zeros(psd_len,1);    
    [psd_avg(:,ifile), freq] = psd(filtsong,nfft,Fs,hanning(nfft),novl);
    npsdsect(ifile,1) = fix((songlen(ifile) - novl)/(nfft - novl));
    % End of spectral analysis
  end

  % OK now do the same for the LVN stimulus
  nwin = length(smwin_len);
  disp(['Number of LVN estimations to perform: ', num2str(nwin)]) 
  iw = 0;
  for wlen = smwin_len
    iw = iw + 1
    % Compute the LV envelope and the LVN song.
    smooth_win = boxcar(wlen);
    % smooth_win = hamming(wlen);    % Square the window for
                                        % comparison with linear measure?
    lvenv = conv(smooth_win,songpow);
    lvenv = lvenv/wlen;
    % offset=round((length(lvenv)-songlen(ifile))/2); % get rid of convolution induced offset
    % lvenv = lvenv(1+offset:(songlen(ifile)+offset));
    % This is correct for a boxcar window
    % skip startup transient
    lvenv = lvenv(1+wlen:songlen(ifile));
    lvnsonglen(ifile,iw) = length(lvenv)
    lvnsong = filtsong(1+wlen:songlen(ifile));
    zidx = find(lvenv == 0);
    nzidx = find(lvenv ~= 0);
    lvnsong(nzidx) = lvnsong(nzidx)./sqrt(lvenv(nzidx));
    lvnsong(zidx) = 0;
    
    lvnsongmax(iw,ifile) = max(abs(lvnsong))
    lvnsongmean(ifile,iw) = mean(lvnsong)
    lvnsongvar(ifile,iw) = mean(lvnsong.^2);
    lvnsongstd(ifile,iw) = sqrt(mean((lvnsong - mean(lvnsong)).^2))
    
    disp(['LVN song mean for file ', int2str(ifile), ' and T = ', ...
	  num2str(smwin_dur(iw)), ' ms is: ', ...
	  num2str(lvnsongmean(ifile,iw)), ' std: ', ...
	  num2str(sqrt(lvnsongvar(ifile,iw) - lvnsongmean(ifile,iw)^2)), ' max: ', num2str(lvnsongmax(iw,ifile))])

    if DO_STIM_SPECT
      % Spectral analysis of the stimulus
      disp('Computing lvn stimulus spectrum...')
      
      psd_len = nfft/2+1;
      lvnpsd_avg(:,ifile,iw) = zeros(psd_len,1,1);    
      [lvnpsd_avg(:,ifile,iw), freq] = psd(lvnsong,nfft,Fs,hanning(nfft),novl);
      nlvnpsdsect(ifile,iw) = fix((lvnsonglen(ifile,iw) - novl)/(nfft - novl));
      % End of spectral analysis
    end
      
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

if DO_STIM_SPECT
  % Weight the psd estimates by the amount of data used for each.
  % This was not quite correct in previous versions.
  psd_glob = psd_avg*npsdsect/sum(npsdsect);
end

% Do the same for the LVN stuff
lvnsonglen_glob = sum(lvnsonglen,1)
lvnsongmax_glob = max(lvnsongmax,[],2)
lvnsongmean_glob = sum(lvnsongmean.*lvnsonglen,1)./lvnsonglen_glob
lvnsongstd_glob = sum(lvnsongvar.*lvnsonglen,1)./lvnsonglen_glob;
lvnsongstd_glob = sqrt(lvnsongstd_glob - lvnsongmean_glob.^2)

if DO_STIM_SPECT
  lvnpsd_tmp = zeros(psd_len,nfiles);
  for iw=1:nwin
    lvnpsd_tmp = lvnpsd_avg(:,:,iw);
    lvnpsd_glob(:,iw) = lvnpsd_tmp*nlvnpsdsect(:,iw)/sum(nlvnpsdsect(:,iw),1);
  end
end

%
% Second pass through the data to get global amplitude distributions
%
disp('Starting second pass: amplitude distributions')

for ifile=1:nfiles
  disp(['Working on file ', num2str(ifile)])
  songfile = fullfile(songbasedir,songname{ifile});

  if strcmp(filetype,'b')
    fids = fopen(songfile,'r','b');
    [song, songlenraw] = fread(fids,inf,'int16');
    fclose(fids);
  else
    [song,Fs,Fmt] = wavread16(songfile);
    songlenraw = length(song);
  end
    
  % Here we filter the songs if requested, The LVN stimulus is not
  % filtered further
  if filtcode
    switch lower(FILTTYPE)
      case 'butter'
	filtsong = bandpass(song,Fs,F_low,F_high);  
      case {'hanningfir', 'kaiserfir', 'hipass'}
	if do_filtfilt
	  filtsong = filtfilt(bfir,1,song);
	else
	  z = [];
	  [filtsongd, z] = filter(bfir,1,song,z);
	  % Note filtered song corrected for the delay is shorter in length!
	  filtsong = filtsongd(1+ndelay:length(filtsongd));
	end
    end
  else 
    filtsong = song;    
  end

  if do_global_norm
    normsong = (filtsong - songmean_glob)/songstd_glob;
  else
    normsong = (filtsong - songmean(ifile))/songstd(ifile);
  end

  if do_notes 
    whichdat{1} = 'Notes';
    notedata=extractdat(noteinfo{ifile},'identity',normsong,Fs,0,whichdat);
    notedata_allnotes = [];
    notedata_dur(ifile) = 0;
    for iseg = 1:notedata.Nseg
      notedata_allnotes = [notedata_allnotes; notedata.data{iseg}];
      notedata_dur(ifile) = notedata_dur(ifile) + notedata.stats{iseg}.duration;
    end
    notedata_Nsegs(ifile) = notedata.Nseg;
    notedata_allnotes_norm = (notedata_allnotes - mean(notedata_allnotes))/std(notedata_allnotes);
    pamp(ifile,:) = hist(notedata_allnotes_norm,bins);
  else
    % Get amplitude distribution for each file. 
    pamp(ifile,:) = hist(normsong,bins);
  end
  
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
    smooth_win = boxcar(wlen);
    % smooth_win = hamming(wlen);    % Square the window for
                                        % comparison with linear measure?
    lvenv = conv(smooth_win,songpow);
    lvenv = lvenv/wlen;
    
    % offset=round((length(lvenv)-songlen(ifile))/2); % get rid of convolution induced offset
    % lvenv = lvenv(1+offset:(songlen(ifile)+offset));
    % This is correct for a boxcar window
    lvenv = lvenv(1+wlen:songlen(ifile));
    lvnsong = filtsong(1+wlen:songlen(ifile));
    zidx = find(lvenv == 0);
    nzidx = find(lvenv ~= 0);
    lvnsong(nzidx) = lvnsong(nzidx)./sqrt(lvenv(nzidx));
    lvnsong(zidx) = 0;

    % Now we remove the global mean and set the global variance to 1.
    if do_global_norm
      normlvnsong = (lvnsong - lvnsongmean_glob(iw))/lvnsongstd_glob(iw);
    else
      normlvnsong = (lvnsong - lvnsongmean(ifile,iw))/lvnsongstd(ifile,iw);
    end
      
    % Get amplitude distribution for each file and LVN window duration. 
    plvnamp(ifile,:,iw) = zeros(1,nbins,1);

    if do_notes 
      whichdat{1} = 'Notes';
      ndelay_lvn = -wlen;
      lvnnotedata=extractdat(noteinfo{ifile},'identity',normlvnsong,Fs,ndelay_lvn,whichdat);
      lvnnotedata_allnotes = [];
      for iseg = 1:lvnnotedata.Nseg
	lvnnotedata_allnotes = [lvnnotedata_allnotes; lvnnotedata.data{iseg}];
      end
      lvnnotedata_allnotes_norm = (lvnnotedata_allnotes - mean(lvnnotedata_allnotes))/std(lvnnotedata_allnotes);
      plvnamp(ifile,:,iw) = hist(lvnnotedata_allnotes_norm,bins);
    else
      % Get amplitude distribution for each file. 
      plvnamp(ifile,:,iw) = hist(normlvnsong,bins);
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
end

% Fudge the distribution by symmetrizing it to remove +ve vs. -ve
% amplitude nonlinearity
plvnampsym = (plvnamp_glob + plvnamp_glob(:,nbins:-1:1))/2;

if DO_STIM_SPECT
  figure;
  plot(freq,10*log10(psd_glob));
  xlabel('Freq. (Hz)');
  ylabel('PSD (dB)');
  title(['Total Stimulus spectrum'],'Interpreter','none');
  grid on;
  
  if do_plot_all
    for iw=1:nwin
      figure;
      plot(freq,10*log10(lvnpsd_glob(:,iw)));
      xlabel('Freq. (Hz)');
      ylabel('PSD (dB)');
      title(['Total Stimulus spectrum, LVN T = ', ...
	    num2str(smwin_dur(iw)), ' ms'],'Interpreter','none');
      grid on;
    end
  else
    iw = 1
    figure;
    plot(freq,10*log10(lvnpsd_glob(:,iw)));
    xlabel('Freq. (Hz)');
    ylabel('PSD (dB)');
    title(['Total Stimulus spectrum, LVN T = ', ...
	  num2str(smwin_dur(iw)), ' ms'],'Interpreter','none');
    grid on;  
  end
end

figure;
semilogy(bins,[pamp_glob; gausstest]);
xlabel('sound pressure/std dev');
ylabel('prob density');
title('distribution of instantaneous signals');
axis([-12 12 0.00001 1]);
axis square;

figure;
semilogy(bins,[pampsym; gausstest]);
xlabel('sound pressure/std dev');
ylabel('prob density');
title('distribution of instantaneous signals (symmetrized)');
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
	  num2str(smwin_dur(iw)), ' ms']);
    axis([-12 12 0.00001 1]);
    axis square;

    figure;
    semilogy(bins,[plvnampsym(iw,:); gausstest]);
    xlabel('sound pressure/std dev');
    ylabel('prob density');
    title(['distribution of instantaneous signals (symmetrized), LVN T = ', num2str(smwin_dur(iw)), ' ms']);
    axis([-12 12 0.00001 1]);
    axis square;
  else
    if iw == 1
      figure;
      semilogy(bins,[plvnamp_glob(iw,:); gausstest]);
      xlabel('sound pressure/std dev');
      ylabel('prob density');
      title(['distribution of instantaneous signals, LVN T = ', ...
	    num2str(smwin_dur(iw)), ' ms']);
      axis([-12 12 0.00001 1]);
      axis square;
      
      figure;
      semilogy(bins,[plvnampsym(iw,:); gausstest]);
      xlabel('sound pressure/std dev');
      ylabel('prob density');
      title(['distribution of instantaneous signals (symmetrized), LVN T = ', num2str(smwin_dur(iw)), ' ms']);
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
  
end

% Output results for the D_KL as a function of window duration

if 0
  iw = 13
  figure;
  semilogy(bins,[plvnamp_glob(iw,:); gausstest]);
  xlabel('sound pressure/std dev');
  ylabel('prob density');
  title(['distribution of instantaneous signals, LVN T = ', ...
	num2str(smwin_dur(iw)), ' ms']);
  axis([-12 12 0.00001 1]);
  axis square;
end

figure
plot(smwin_dur,DKL_gausslvnsym)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
title('Symmetrized')

figure
plot(smwin_dur,DKL_lvnsymgauss)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
title('Symmetrized')

figure
plot(smwin_dur,DKL_gausslvn)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')

figure
plot(smwin_dur,DKL_lvngauss)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')

figure
plot(smwin_dur,DKL_gausslvn2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
title('D_{KL} using better Gaussian estimate')

figure
plot(smwin_dur,DKL_lvngauss2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
title('D_{KL} using better Gaussian estimate')

[DKL_min, iw_min] = min(DKL_lvnsymgauss)
lvwin_min = smwin_dur(iw_min)

[DKL2_min, iw2_min] = min(DKL_gausslvnsym)
lvwin2_min = smwin_dur(iw2_min)

% Determine total number of notes and total duration of notes
if do_notes
  notedata_dur_tot = sum(notedata_dur);
  notedata_Nsegs_tot =  sum(notedata_Nsegs);
  disp(['Total duration of notes processed: ', ...
	num2str(notedata_dur_tot/1000), ' sec for ', ...
	num2str(notedata_Nsegs_tot), ' total segments.'])
end


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
for ifile=1:nfiles
  nzidx = find(pgauss(1,:)' ~= 0 & pampnorm(ifile,:)' ~= 0); 
  DKL_gausssongf(ifile) = deltas*sum(pgauss(1,nzidx).*log2(pgauss(1,nzidx)./pampnorm(ifile,nzidx)),2)
  
  DKL_songgaussf(ifile) = deltas*sum(pampnorm(ifile,nzidx).*log2(pampnorm(ifile,nzidx)./pgauss(1,nzidx)),2)

end  

%nzidx = find(pampnorm(ifile-1,:)' ~= 0 & pampnorm(ifile,:)' ~= 0); 
%DKL_songsong = deltas*sum(pampnorm(ifile-1,nzidx).*log2(pampnorm(ifile-1,nzidx)./pampnorm(ifile,nzidx)),2)

% Look at the D_KL error estimate using the bootstrap estimates
if do_adapt
  for ifile=1:nfiles
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

savefile = input('Enter filename for saving results: ','s')
save(savefile)
