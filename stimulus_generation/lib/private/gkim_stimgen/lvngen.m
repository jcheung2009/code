% This scripts goes through all the files in an ensemble, computes
% the associated LVN stimuli and writes these out to files after
% filtering and normalization.

MAX_DA = 32767
MIN_DA = -32768

% Global values in this case
% Sampling rate default
%Fs = 44100
Fs_dflt = 2e7/454 % more precise
SAMP_SIZE = 2;
SAMP_TYPE = 'int16'

MAX_GAUSS_WIDTH = 4

% Do we do lots of plots?
do_plots = 0
do_osc_plots = 0

stimbasedir = input('Enter base directory for output stimulus files: ','s')

% Get batch file information and open it.
batch_info = [];
batch_info = batch_select(batch_info)
% Read in the file list
batch_info = batch_read(batch_info)

Fs = input(['Enter sampling rate (Hz) for sound files [', num2str(Fs_dflt), ']: ']);
if isempty(Fs)
  Fs = Fs_dflt
end  

disp('Choose Local variance window shape:')
disp('(1) Square (causal)')
disp('(2) Hanning (symmetric)')
lvwin_code = input('Enter window type for computing the local variance: [1]')
if lvwin_code == 2
  lvwin_type = 'hanning'
else
  lvwin_type = 'boxcar'
end

% Will replace this by a range of values
smwin_dur = input('Duration(s) of LV smoothing window in msec: ')
%smwin_dur = 2.0 % Smoothing window duration in msec
smwin_len = 1 + round(smwin_dur*Fs/1000)

stim_info.type = 'LVN'
% Info for scaling data before output
%norm_info.type = 'rms'
norm_info.type = 'set_gain'

yesno = input('Is the output data to be byte swapped? (y/N): ','s')
if strncmpi(yesno,'y',1)
  SWAB = 1
else	
  SWAB = 0
end
 
MAX_GAUSS_WIDTH = input('Enter the number of std dev to saturate the LVN stimulus: ')

filt_info.type = 'hanningfir'
filt_info.do_filtfilt = 0
filt_info.F_low = 200
filt_info.F_high = 15000  
stim_info.samp_rate = Fs
stim_info.samp_size = SAMP_SIZE
stim_info.samp_type = SAMP_TYPE
stim_info.swab = SWAB
norm_info.nstd = MAX_GAUSS_WIDTH    

% Fudge factor for setting the gain
%gain_fudge = 10^0.25 % 5 dB attenuation from nominal.
gain_fudge = 1

% Set up the stimulus ramp and silence padding
ramp_info = ramp_setup(Fs)

% Set up filters
filt_info = filter_setup(filt_info,Fs)

% Filtering/spectrum parameters
do_stim_spect=0
nfft = 65536
%novl = 8192
novl = round(nfft/4)

% Go through all files 
disp('Processing.')

for ifile=1:batch_info.nfiles
  ifig = 0;
  
  songfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});  
  fids = fopen(songfile,'r','b');
  [song, songlenraw] = fread(fids,inf,'int16');
  fclose(fids);

  % Here we assume songs are already filtered
  filtsong = song;

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

  % OK now do the same for the LVN stimulus
  nwin = length(smwin_len);
  disp(['Number of LVN estimations to perform: ', num2str(nwin)]) 
  iw = 0;
  for wlen = smwin_len
    iw = iw + 1
    
    % Set output LVN file name
    filekey = ['_lvn_T', num2str(smwin_dur(iw)), '_rms', num2str(norm_info.nstd)];
    [spath,sname,sext,sver] = fileparts(batch_info.filenames{ifile});
    % Should we include relative path in the batchfile in the output
    % file name?
    lvnsongname = [sname, filekey, '.raw']
    lvnsongfile = fullfile(stimbasedir,lvnsongname);
    file_info{iw}.key = 'LVN'
    file_info{iw}.files{ifile} = lvnsongfile;
    
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

    % Process and write out LVN data
    lvnsong = filter_data(lvnsong,filt_info);

    % Normalize the data.
    range = norm_info.nstd*std(lvnsong);
    gain = (MAX_DA-MIN_DA)/(gain_fudge*(2*range+1))
    norm_info.setgainval = gain;
    [lvnsong, norm_info] = norm_data(lvnsong,norm_info);    
    file_info{iw}.nclip(ifile) = norm_info.nclip;
    file_info{iw}.gain(ifile) = norm_info.gain;
    
    % Add ramp and zero pads if needed.
    lvnsong = make_ramp(lvnsong, ramp_info);

    % Write out data.
    write_data(lvnsong,stim_info,lvnsongfile);
    
    if do_osc_plots
      ifig = ifig+1;
      hh(ifig) = figure;
      td = (0:length(lvnsong)-1)*1000/Fs;    
      plot(td, lvnsong)
      xlabel('t (msec)')
      title(['Oscillogram: ', lvnsongfile], 'Interpreter', 'none')      
    end
    if do_stim_spect
      tstring = ['Stimulus spectrum: ', lvnsongfile]
      calc_spect_file(lvnsongfile,stim_info,nfft,hanning(nfft),novl,tstring);
      ifig = ifig+1;
      hh(ifig) = gcf;
    end
        
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
      
  end % Loop over LV windows

  if do_plots | do_osc_plots | do_stim_spect
    disp('Hit return to continue.')
    pause(2)
    handle_idx = find(ishandle(hh));
    close(hh(handle_idx))
    clear td
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

% Save data rc files.
yesno = input('Do you want to create a krank rc file for this stimulus set (y/N)?', 's');
if strncmpi(yesno,'y',1)  
  rcbasedir = input('Enter base directory for rc files: ', 's')
  rcfilenameprefix = input('Enter prefix name for rc files: ', 's')
  for iw=1:nwin
    rcfilename = fullfile(rcbasedir,[rcfilenameprefix, '_T', num2str(smwin_dur(iw)), '.rc'])   
    make_stim_rc_rptnonrpt(rcfilename,file_info{iw}.files,Fs)  
  end
end

disp('Hit return to continue. Next will clear temp data and save workspace.')
pause

clear song filtsong songpow lvenv lvnsong loglv

savefile = input(['Enter filename for saving results (path will be', ...
      ' output base dir): '],'s')
savefile = fullfile(stimbasedir, savefile)
save(savefile)

disp('Done.')
