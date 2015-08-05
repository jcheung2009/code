function data_out = song_shift(data, time_shift, freq_shift)
window = 512;

% calculate values for resampling (p,q) based on freq_shift
[q, p] = rat(freq_shift);

% calculate values for time dilation (r) based on time_shift and freq_shift
r = 1 / (time_shift * freq_shift);

data_out = pvoc(data, r, window);
data_out = resample(data_out, p, q);
