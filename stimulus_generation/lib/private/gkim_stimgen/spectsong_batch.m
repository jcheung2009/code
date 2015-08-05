%addpath /home/bdwright/work/zfinch/song_anal/uisonganal 

songbasedir = input('Enter base directory for song files: ','s')

% Set up printing options 
DO_PRINT = 0
prname = '830'
do_color = 1 % do we print in color?

% Filtering parameters
Fs = 44100 % Fixed for raw files
F_low=500; 
F_high=8000;  

% Spectrogram parameters
window_dur = 16 % This is the window duration in msec
ovl_frac = 0.40  % Fraction of window to overlap   

% Spectrogram display parameters
tchunk_disp = 4000 % number of msec to show per plot
tchunk_ovl = 1000  % number of msec to overlap between plots
% initial floor, ceiling and contrast for display of spectrogram
spect_floor = -60;  % floor cutoff in dB re max
spect_ceil = -10;   % ceil saturation in dB re max
%spect_range = 2.0; % percent of range of grayscale used to display
                   % data between floor and ceil		   
% the spectrogram floor is asumed to be -100 dB 
% floor_db set the minimum value displayed in db relative to the maximum value
% ceil_db sets the value at which display saturates in in db relative to the maximum value 
		   
%cmap = make_map(spect_floor, spect_ceil, spect_range);
%cmap = flipud(gray(256));
cmap = flipud(hot(256));
% These are for brightening the colormap
%beta = 0.5 
%brighten(beta)
%caxis('manual');
%caxis([spect_floor spect_ceil]);

% Figure display properties
figpos = [0.1469 0.0586 0.6383 0.8525];
margin = 0.25 % Paper margin in inches for printing
nplotspage = 6 % number of subplots per page

% End of user settings

ifig = 1;
iplot = 1;
h(ifig) = figure;
origunits = get(gcf,'Units');
set(gcf,'Units','normalized');
set(gcf,'Position', figpos);
set(gcf,'Units','inches','PaperUnits','inches');
psize = get(gcf,'PaperSize');
newpp(3) = min(psize) - 2*margin;
newpp(4) = newpp(3)*figpos(4)/figpos(3);
newpp(2) = (max(psize)-newpp(4))/2;
newpp(1) = margin;
set(gcf,'PaperPosition',newpp); 
set(gcf,'Units',origunits);
%set(gcf,'InvertHardcopy','on')

while 1
  batchfilename = input('Enter batch file name: ','s');
  if isempty(batchfilename)
    disp('You must enter a batch file. Try again.')
  else
    fid = fopen(batchfilename,'r');
    if fid == -1
      disp('Invalid batch file name. Try again.') 
    else
      break;
    end
  end
end

while 1
  songname = fgetl(fid);
  % Check for whitespace here!
  spaceflag = 0;
  if isspace(songname)
    spaceflag = 1
  end
  if (~ischar(songname)) | isempty(songname) | spaceflag
    if iplot == 1
      nfigs = ifig - 1
      close(h(ifig))
    else
      nfigs = ifig
    end
    disp('End of batch file reached.')
    break
  end
  songfile = fullfile(songbasedir,songname);
  % Raw file format
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);
  % This is for wav files
  % [song,Fs,nbits] = wavread(songfile);  
  filtsong=bandpass(song,Fs,F_low,F_high); 
  window_size = round(window_dur*Fs/1000); % Length of window in samples
  nfft = round(window_dur*Fs/1000);
  nfft = 2^(nextpow2(nfft));  % Size of fft 
  novl = round(ovl_frac*window_size);  
  
  % Get length of song file and divide into chunks for plotting
  [songspgram, freq, time] = specgram(filtsong,nfft,Fs,hanning(window_size),novl); 
  % convert to dB
  max_spect_val = max(max(songspgram));
  % Set small values to something very small but nonzero.
  songspgram = max(10^(-9)*max_spect_val,songspgram);
  songspgram = 20*log10(abs(songspgram));
  time = time*1000; % convert to ms
  t_min = time(1); 
  t_max = time(length(time));
  % adjust time axis for spectrogram offset (1/2 window duration in ms)
  t_min = t_min + 0.5*nfft*1000/Fs;  
  t_max = t_max + 0.5*nfft*1000/Fs;                 
  
  freq_idx = find(freq<F_high & freq>F_low);  
  dispfreq = freq(freq_idx);  

  t_beg = t_min;
  t_end = tchunk_disp; 
  nchunks = ceil((t_max - t_min - tchunk_ovl)/(tchunk_disp - tchunk_ovl))
  for ichunk = 1:nchunks
    if ichunk == nchunks
      t_end = t_max;
      t_beg = t_end - tchunk_disp;
    end
    time_idx = find(time >= t_beg & time <= t_end);
    disptime = time(time_idx);
    % Set max to 0dB
    dispspgram = songspgram(freq_idx,time_idx) - max(max(songspgram(freq_idx,:)));    
    
    subplot(nplotspage,1,iplot)
    image(disptime,dispfreq,dispspgram,'CDataMapping','scaled')
    caxis([spect_floor spect_ceil]);
    
%    imagesc(disptime,dispfreq,dispspgram) 
    xlim([t_beg t_end])
    title(songname)
    if iplot == nplotspage
      xlabel('t (msec)')
    end
    if iplot == 1
      ylabel('Frequency (Hz)')
      %    colorbar
    end
    axis xy
    colormap(cmap)

    if iplot == nplotspage
      iplot = 1
      ifig = ifig + 1
      h(ifig) = figure;
      origunits = get(gcf,'Units');
      set(gcf,'Units','normalized');
      set(gcf,'Position', figpos);
      set(gcf,'Units','inches','PaperUnits','inches');
      psize = get(gcf,'PaperSize');
      newpp(3) = min(psize) - 2*margin;
      newpp(4) = newpp(3)*figpos(4)/figpos(3);
      newpp(2) = (max(psize)-newpp(4))/2;
      newpp(1) = margin;
      set(gcf,'PaperPosition',newpp); 
      set(gcf,'Units',origunits);
    else
      iplot = iplot + 1
    end
    t_beg = t_end - tchunk_ovl;
    t_end = t_beg + tchunk_disp;    
  end
end

fclose(fid);

if DO_PRINT
  propt = char(['-P',prname]);
  disp(['Printing figures to printer ', prname, '.'])
  for ifig=1:nfigs
    if do_color
      print(h(ifig),'-dpsc2',propt)
    else
      print(h(ifig),'-dps2',propt)
    end
  end
end

disp('Done.')
  
%tsong = (1:length(song)) - 1;
%tsong = tsong/Fs;
%figure; plot(tsong, song);
%axis tight



