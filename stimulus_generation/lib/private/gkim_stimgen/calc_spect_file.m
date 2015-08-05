function [spect, freq] = calc_spect_file(file,data_info,nfft,win,novl,varargin)
% Spectral analysis of the data

MAX_DATA_MEM = 25000000

if nargin > 5
  tstring = varargin{1};
end
if nargin > 6
  do_plot = varargin{2};
end

disp('Computing data spectrum...')

Fs = data_info.samp_rate;
if data_info.swab
  fid = fopen(file,'rb','b');
else
  fid = fopen(file,'rb');
end
fseek(fid,0,'eof');
data_len = ftell(fid)/data_info.samp_size

chunk_size = 100000;
max_chunk_size = MAX_DATA_MEM/8;
if chunk_size >= data_len
  chunk_size = data_len/5;
end
if chunk_size > max_chunk_size
  chunk_size = max_chunk_size;
end

nchunks = fix(data_len/chunk_size);
disp(['Spectral analysis: N chunks = ', num2str(nchunks)]);

cstart = 1;
cstop = cstart + chunk_size - 1;

psd_len = nfft/2+1;
spect = zeros(psd_len,1);

nchunksproc = 0;
    
for nc=1:nchunks
  fseek(fid,(cstart-1)*data_info.samp_size,'bof');
  [datachunk,num_read] = fread(fid,chunk_size,data_info.samp_type);
  if num_read ~= chunk_size
    error('Incorrect amount of data read.')
  end
  
  cstart = cstop; 
  cstop = cstart + chunk_size - 1;
  % Only process chunk if it is entirely within a valid epoch
  
  [psd_est, freq] = psd(datachunk,nfft,Fs,win,novl);
  spect = spect + psd_est;
  nchunksproc = nchunksproc+1;
end
spect = spect/nchunksproc;

if nargout == 0 | do_plot
  figure;
  plot(freq,10*log10(spect));
  xlabel('Freq. (Hz)');
  ylabel('PSD (dB)');
  if exist('tstring','var')
    title(tstring,'Interpreter','none');
  else
    title(['Data spectrum'],'Interpreter','none');
  end
  grid on;
end

