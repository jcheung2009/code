function data_filt = filter_data_conv(data,tfilter,idx_tc)

% Filter data using the convolution theorem given a time
% domain filter

% idx_tc is the filter data index of the time cutoff of the filter
% (filter endpoint).

data_len = length(data);
filter_len = length(tfilter);

% zero pad data by half of filter length (assumes symmetric
% response function) 
zpad = fix(filter_len/2);
zpad = 2^(nextpow2(data_len+zpad)) - data_len;
data(data_len+1:data_len+zpad) = 0.0;

% Insert enough zeros in middle of response function to give it
% length data_len+zpad
tfilter_pad = zeros(data_len+zpad,1);
tfilter_pad(1:idx_tc) = tfilter(1:idx_tc);
tfilter_pad((data_len+zpad-idx_tc+1):data_len+zpad) = ...
    tfilter(idx_tc+1:filter_len);

nfftdata = 2^nextpow2(data_len+zpad);

fftdata = fft(data',nfftdata);
fftfilter = fft(tfilter_pad,nfftdata);
data_filt = ifft(fftdata.*fftfilter);
