% Declare global variables.

N_CHANNELS=1;
SAMP_SIZE = 2;

raw_file = input('Enter name of raw data file: ', 's')
filt_file = input('Enter name of filtered data file: ', 's')
no_last_filt = input('Is the last channel reserved for data not to be filtered (1/[0])?: ')

if isempty(no_last_filt)
  no_last_filt = 0;
end

Fs = input('Enter sampling rate in Hz: ')
if isempty(Fs)
  Fs = 2;
end

N_CHANNELS = input('Enter total number of channels: ')
if isempty(N_CHANNELS)
  N_CHANNELS = 1;
end

SWAB = input('Is the file byte swapped ([0]/1): ')
if isempty(SWAB)
  SWAB = 0;
end

if SWAB
  fid = fopen(raw_file,'r','b');
else
  fid = fopen(raw_file,'r');
end
if fid == -1
   error('Cannot read input file')
end
if SWAB
  fidw = fopen(filt_file,'w','b');
else
  fidw = fopen(filt_file,'w');
end  
if fidw == -1
   error('Cannot output file')
end

disp(['Processing file: ', raw_file]);
fseek(fid,0,'eof');
file_len = ftell(fid)
fseek(fid,0,'bof');
disp(['File is ', num2str(file_len), ' bytes long.'])
nchunk = input('Enter total number of discrete data chunks to process the file in (10): ')
if isempty(nchunk)
  nchunk = 10;
end

% General filter design parameters
do_kaiser = 0
do_firls = 0
do_custom_firls = 1
% The default
do_hanningfir = 0

if do_kaiser
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
  bfir = fir1(nfir,Wnfir,ftype,kaiser(nfir+1,beta))
elseif do_firls
  % Least-Squares FIR filter
  nfir = 112;
  Rp = 2.5660
  Rs = 17.1515
  ftype = 'hilbert';
  amps = [0 0 1 1 0 0]
  fbands = [0 0.0156 0.0312 0.5625 0.6125 1]
  wt = [1.71 1.0 1.71]
  bfir = firls(nfir,fbands,amps,wt,'hilbert')
elseif do_hanningfir
  F_low = 250.0
  F_high = 8000.0
  nfir = 512
  ndelay = fix(nfir/2)
  bfir = fir1(nfir,[F_low*2/Fs, F_high*2/Fs])
elseif do_custom_firls  
  % FIR LS design
  nfir = 256
  flow1 = 45
  flow2 = 450
  fhi1 = 8050
  fhi2 = 12000
  % Want 30dB falloff by 250Hz
  logA30 = -30/20;
  flow30 = 250
  fhi30 = 10000
  fp1 = 500;
  fp2 = 8000;
  fs1 = 30;
  fs2 = 12050;
  mlow = logA30/(flow30 - fp1)
  nbins = 10;
  dflow = fix((flow2 - flow1)/nbins);
  flow = flow1:dflow:flow2
  flowb(1) = flow(1);
  flowb(2) = flow(2);
  for k=2:length(flow)-1
    flowb(2*k-1) = flowb(2*k-2);
    flowb(2*k) = flow(k+1);
  end  
  Alow = 10.^(logA30 + mlow*(flowb - flow30))
  mhi = logA30/(fhi30 - fp2)
  dfhi = fix((fhi2 - fhi1)/nbins);
  fhi = fhi1:dfhi:fhi2
  fhib(1) = fhi(1);
  fhib(2) = fhi(2);
  for k=2:length(fhi)-1
    fhib(2*k-1) = fhib(2*k-2);
    fhib(2*k) = fhi(k+1);
  end  
  Ahi = 10.^(logA30 + mhi*(fhib - fhi30))
  fbands = [0 fs1 flowb fp1 fp2 fhib fs2 (Fs/2)]/(Fs/2)
  amps = [0 0 Alow 1.0 1.0 Ahi 0 0]
  wts = [1 ones(1,length(flow)-1) 1 2*ones(1,length(fhi)-1) 2]  
  bfir = firls(nfir,fbands,amps)  
end

afir = 1;
nd = fix(nfir/2)
%% Must account for group delay by nd samples

nfft = 2048;
figure;
freqz(bfir,afir,nfft,Fs)
figure;
grpdelay(bfir,afir,nfft,Fs)

max_ch_samples = fix(file_len/SAMP_SIZE/N_CHANNELS);
num_ch_samples = fix(max_ch_samples/nchunk)
z = [];
[traces nread] = fread(fid,[N_CHANNELS,num_ch_samples],'int16');
num_ch_samples = fix(nread/N_CHANNELS)
stim_trace_append = zeros(1,nd);
chunk = 1

while nread > 0
  % file_offset = (chunk-1)*SAMP_SIZE*N_CHANNELS;
  % fseek(fid,file_offset,'bof');
  disp(['Chunk number: ' num2str(chunk)])
  disp(['No. of samples this chunk: ' num2str(num_ch_samples)])
  if no_last_filt
    stim_trace = [stim_trace_append traces(N_CHANNELS,:)];
    [filt_traces, z] = filter(bfir,afir,traces(1:N_CHANNELS-1,:)',z);
    filt_traces_stim = [filt_traces stim_trace(1:num_ch_samples)']';
    if chunk==1
      fwrite(fidw,filt_traces_stim(:,(1+nfir+nd):num_ch_samples),'int16');
    else
      fwrite(fidw,filt_traces_stim,'int16');
    end
    stim_trace_append = traces(N_CHANNELS,num_ch_samples-nd+1:num_ch_samples);
    [traces nread] = fread(fid,[N_CHANNELS,num_ch_samples],'int16');
  else
    [filt_traces, z] = filter(bfir,afir,traces',z);
    filt_traces = filt_traces';
    if chunk==1
      fwrite(fidw,filt_traces(:,(1+nd):num_ch_samples),'int16');
    else
      fwrite(fidw,filt_traces,'int16');
    end
    [traces nread] = fread(fid,[N_CHANNELS,num_ch_samples],'int16');
  end
  num_ch_samples = fix(nread/N_CHANNELS);
  chunk = chunk + 1;
end

fclose(fid);
fseek(fidw,0,'eof');
fileout_len = ftell(fidw)
disp(['File is ', num2str(fileout_len), ' bytes long.'])
disp(['File in vs. out difference is ', num2str(file_len-fileout_len), ' bytes.'])
disp(['Expected difference: ', num2str(nd*SAMP_SIZE*N_CHANNELS),'.'])
fclose(fidw);

disp('Done!')


