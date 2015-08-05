function [data_corr, lags] = calc_autocorr(data,maxlag_sec,Fs,varargin)

if nargin > 3
  tstring = varargin{1};
end
if nargin > 4
  do_plot = varargin{2};
end

maxlag = round(maxlag_sec*Fs)

data_corr = zeros(2*maxlag+1,1);
data_corr = xcorr(data,maxlag);

lags = [-maxlag:maxlag]/Fs;

if nargout == 0 | do_plot
  figure;
  plot(1000*lags,data_corr);
  xlabel('\tau (msec)');
  ylabel('\langle S(t)S(t +\tau)\rangle');
  if exist('tstring','var')
    title(tstring,'Interpreter','none');
  else
    title(['Data Autocorrelation'],'Interpreter','none');
  end
end
