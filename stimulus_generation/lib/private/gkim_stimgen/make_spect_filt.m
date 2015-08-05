function [match_filter, freq_filter, itfc] = make_spect_filt(freq,match_spect,Fs,nfft,fcut_low,fcut_high,do_plots,batchfilename)

% Generate a match_spect spectrum matching filter.

psd_len = length(match_spect);
negfreq = -flipud(freq(2:psd_len-1)); 
wrapfreq = [freq; negfreq];
psdnorm = match_spect/sum(match_spect);
 
psdfilt = sqrt(psdnorm);
%spectfilt = [psdfilt'; flipud(psdfilt(2:psd_len-1)')];
spectfilt = [psdfilt; flipud(psdfilt(2:psd_len-1))];
timefilt = real(ifft(spectfilt));

if do_plots
  figure;
  plot(freq,10*log10(match_spect))
  xlabel('Freq. (Hz)');
  ylabel('Amplitude (dB)');
  title('Original spectrum','Interpreter','none');
  
  figure;
  plot(freq,psdfilt)
  xlabel('Freq. (Hz)');
  ylabel('Amplitude');
  title('Matched spectral filter','Interpreter','none');

  figure;
  %tf = (0:(nfft-1))*1000/Fs;
  tf = (-nfft/2:(nfft/2-1))*1000/Fs;
  plot(tf,fftshift(timefilt))
  xlabel('time (ms)')
  title('Matched spectral filter impulse response','Interpreter','none');
end

% Let's cutoff filter response below fcut_low.  
match_filter_dur = 1000/fcut_low
tf = (0:(nfft-1))*1000/Fs;
% Limit filter duration on one side to match_filter_dur/2.
itfc = max(find(tf<=match_filter_dur/2))
tf(itfc)
% For now ignore the high frequency cutoff.

% This is the matching filter
match_filter = [timefilt(1:itfc); timefilt((nfft-itfc+1):nfft)];
% NOTE: Could resample match_filter to use for generating differently
% sampled output, but we prefer to recompute the filter from the
% resampled raw data.

match_filter_len = length(match_filter)
nfft_filter = match_filter_len;
%nfft = 2^nextpow2(match_filter_len)
spect_match_filter = real(fft(match_filter));
freq_filter = Fs*getfreq(match_filter_len);

if do_plots
  figure;
  tf_trunc = (0:(2*itfc-1))*1000/Fs;
  %tf = (-nfft/2:(nfft/2-1))*1000/Fs;
  plot(tf_trunc,match_filter)
  xlabel('time (ms)')
  title(['Matched spectral filter impulse response: ', batchfilename],'Interpreter','none');
  
  figure;
  plot(freq_filter(1:nfft_filter/2+1),spect_match_filter(1:nfft_filter/2+1))
  xlabel('Freq. (Hz)');
  ylabel('Amplitude');
  title('Matched spectral filter','Interpreter','none');
  
  % Reestimate the psd 
  novl_filter = nfft_filter/2;
  [psdfilt_trunc, freq_trunc] = psd(match_filter,nfft_filter,Fs,hanning(nfft_filter),novl_filter);
  
  figure;
  plot(freq_trunc,psdfilt_trunc);
  xlabel('Freq. (Hz)');
  ylabel('PSD');
  title('Truncated filter spectral analysis','Interpreter','none');
  grid on;
end
