function [spect, freq] = calc_spect(data,nfft,Fs,win,novl,varargin)

if nargin > 5
  tstring = varargin{1};
end
if nargin > 6
  do_plot = varargin{2};
end

[spect, freq] = psd(data,nfft,Fs,win,novl);

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
