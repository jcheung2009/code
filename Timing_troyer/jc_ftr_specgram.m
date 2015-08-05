function [spec f t] = jc_ftr_specgram(data,varargin)
% [spec f t] = ftr_specgram(data,varargin)
%  calculate using the spectrogram function
%    by entering params.fs in samples/msec, t is returned in msec
%    and f in kHz
%  varargin can be a parameter structure or a list of parameter/value pairs
%    window - def = gaussian of 256 points
%    Nadvance - def =2 
%    NFFT - def = 256
%    fs - def=32000 (samples per sec)
% *****zero padding on the edges of data during spectrogram computation, be
% aware for computing timing measures back to the original song data

%  Created by Todd 9/6/08
if nargin==2
    params = varargin{1};
else
    params = jc_defaultspecparams();
end

if length(data)<params.NFFT
    data = [data(:); zeros(params.NFFT-length(data),1)];
end
% pad with half window length of zeros
if length(params.window)==1
    windowlen = params.window;
else
    windowlen = length(params.window);
end
pad = zeros(floor(windowlen/2),1);
pad = zeros(windowlen-params.Nadvance,1);
data = [pad; data; pad];% pads the edges of data with zeros!!!!!! 
try
    [spec f t] = spectrogram(data,params.window,params.NFFT-params.Nadvance,params.NFFT,params.fs/1000);
catch
    params.window
    max(size(data))
    params.NFFT
    params.NFFT-params.Nadvance
end
    