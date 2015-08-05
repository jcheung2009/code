function [match_filter2, freq_filter, itfc] = make_spect_filt_env(freq,match_spect,Fs,nfft,fcut_low,fcut_high,do_plots,batchfilename)

% Generate a match_spect spectrum matching filter.

do_cosine_hipass = 0
do_saturate_low = 1
do_limit_filter_dur = 0

psd_len = length(match_spect);
negfreq = -flipud(freq(2:psd_len-1)); 
wrapfreq = [freq; negfreq];

% OK now we match the psd of the log envelope with a power law
% within a certain low frequency range
if fcut_low > 0
  ffit_low = min(0.5,fcut_low)
else
  ffit_low = 0.5  
end
ffit_high = min(300.0,fcut_high)
idx_freq_fit = find(freq > ffit_low & freq < ffit_high);
[fit_coeff,fit_info] = polyfit(log10(freq(idx_freq_fit)),log10(match_spect(idx_freq_fit)),1)
logspect_fit = polyval(fit_coeff,log10(freq));
beta1 = -fit_coeff(1)

% Set a steeper power law cutoff above fcut_high
beta2 = max(4.0, beta1);
[fdiff_min, idx_fcut_high] = min(abs(freq - fcut_high));
logspect_fit_fc = logspect_fit(idx_fcut_high)
fc = freq(idx_fcut_high)
logspect_fit(idx_fcut_high+1:end) = logspect_fit_fc - ...
    beta2*(log10(freq(idx_fcut_high+1:end)) - log10(fc));

%psdnorm = match_spect/sum(match_spect);
spect_fit = 10.^logspect_fit;
% Remove the DC
spect_fit(1) = 0;
% Remove low freq. below cutoff using cosine filter
%fcut_idx = find(freq <= fcut_low);
%idx_fcut_low = fcut_idx(end)
%spect_fit_max = spect_fit(idx_fcut_low)
%spect_fit(fcut_idx) = 0.5*spect_fit_max*(1 + cos(pi*(fcut_idx - idx_fcut_low)/(idx_fcut_low-1))); 

%psdnorm = spect_fit/sum(spect_fit);
psdnorm = spect_fit;
 
psdfilt = sqrt(psdnorm);
%spectfilt = [psdfilt'; flipud(psdfilt(2:psd_len-1)')];
spectfilt = [psdfilt; flipud(psdfilt(2:psd_len-1))];
timefilt = real(ifft(spectfilt));

if do_plots
  figure;
%  plot(freq,[10*log10(match_spect); 10*logspect_fit])
  semilogx(freq,[10*log10(match_spect) 10*logspect_fit])
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
tf = (0:(nfft-1))*1000/Fs;
if fcut_low > 0 & do_limit_filter_dur
  match_filter_dur = 1000/fcut_low
else
  match_filter_dur = tf(end)
end
% Limit filter duration on one side to match_filter_dur/2.
itfc = max(find(tf<=match_filter_dur/2))
tf(itfc)

% This is the matching filter
match_filter = [timefilt(1:itfc); timefilt((nfft-itfc+1):nfft)];

match_filter_len = length(match_filter)
nfft_filter = match_filter_len;
%nfft = 2^nextpow2(match_filter_len)
if ~mod(nfft_filter,2)
  fhalf_len = nfft_filter/2 +1;
else
  fhalf_len = (nfft_filter+1)/2;
end
spectfilt2 = fft(match_filter);

% Set the zero freq. component to zero again
spectfilt2(1) = 0;
freq_filter = Fs*getfreq(match_filter_len);

if do_cosine_hipass & fcut_low > 0
  spectfilt2 = abs(spectfilt2);
  % Remove low freq. below cutoff using cosine filter
  fcut_idx = find(freq_filter(1:fhalf_len) <= fcut_low);
  idx_fcut_low = fcut_idx(end)
  filter_max = spectfilt2(idx_fcut_low)
  spectfilt2(fcut_idx) = 0.5*filter_max*(1 + cos(pi*(fcut_idx - idx_fcut_low)/(idx_fcut_low-1))); 
elseif do_saturate_low & fcut_low > 0
  spectfilt2 = abs(spectfilt2);
  % Saturate low freq. below cutoff
  fcut_idx = find(freq_filter(1:fhalf_len) <= fcut_low);
  idx_fcut_low = fcut_idx(end)
  filter_max = spectfilt2(idx_fcut_low)
  spectfilt2(fcut_idx) = filter_max; 
  spectfilt2(1) = 0;
end
spectfilt2 = [spectfilt2(1:fhalf_len); flipud(spectfilt2(2:fhalf_len-1))];

%figure; plot(freq_filter,real(spectfilt2))
%xlabel('Freq. (Hz)');
%ylabel('Amplitude');
%title('spectfilt2')

match_filter2 = real(ifft(spectfilt2));

spect_match_filter = real(fft(match_filter));
spect_match_filter2 = real(fft(match_filter2));

if do_plots
  figure;
  tf_trunc = (0:(2*itfc-1))*1000/Fs;
  %tf = (-nfft/2:(nfft/2-1))*1000/Fs;
  plot(tf_trunc,match_filter)
  xlabel('time (ms)')
  title(['Matched spectral filter impulse response: ', batchfilename],'Interpreter','none');
  
  figure;
  tf_trunc = (0:(2*itfc-1))*1000/Fs;
  %tf = (-nfft/2:(nfft/2-1))*1000/Fs;
  plot(tf_trunc,match_filter2)
  xlabel('time (ms)')
  title(['Matched spectral filter impulse response (better?): ', batchfilename],'Interpreter','none');

  figure;
  plot(freq_filter(1:nfft_filter/2+1),spect_match_filter(1:nfft_filter/2+1))
  xlabel('Freq. (Hz)');
  ylabel('Amplitude');
  title('Matched spectral filter','Interpreter','none');

  figure;
  plot(freq_filter(1:nfft_filter/2+1),spect_match_filter2(1:nfft_filter/2+1))
  xlabel('Freq. (Hz)');
  ylabel('Amplitude');
  title('Matched spectral filter (better?)','Interpreter','none');

  % Reestimate the psd 
%  novl_filter = nfft_filter/2;
  novl_filter = min(256,round(nfft_filter/2));

  [psdfilt_trunc, freq_trunc] = psd(match_filter,nfft_filter,Fs,hanning(nfft_filter),novl_filter);
  
  figure;
  semilogx(freq_trunc,10*log10(psdfilt_trunc));
  xlabel('Freq. (Hz)');
  ylabel('PSD');
  title('Truncated filter spectral analysis','Interpreter','none');
  grid on;

  [psdfilt_trunc, freq_trunc] = psd(match_filter2,nfft_filter,Fs,hanning(nfft_filter),novl_filter);
  
  figure;
  semilogx(freq_trunc,10*log10(psdfilt_trunc));
  xlabel('Freq. (Hz)');
  ylabel('PSD');
  title('Truncated filter spectral analysis (better?)','Interpreter','none');
  grid on;
end
