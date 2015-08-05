function params = jc_defaultspecparams()
% params = defaultspecparams()
%  returns the default spectrogram parameters in a structure
%    window (= 256)
%    Nadvance (=64) 
%    NFFT (= 256)
%    fs (=24414.0625) (samples per sec)
%    ampcut (= .01)

%  Created by Todd 9/6/08


params.Nadvance=4; 
params.NFFT=256; 
params.fs = 32000;
params.ampcut = .01;
params.specfloor = .05;
params.dt = 1000*params.Nadvance/params.fs; % width of each time bin in msec
df = params.fs/(params.NFFT*1000);
params.f = df*(0:floor(params.NFFT/2)); % centers of frequency bands in kHz
t = -params.NFFT/2 +1:params.NFFT/2;
sigma = (1/1000)*params.fs;
params.window=exp(-(t/sigma).^2);%gaussian windowing for spectrogram computation

params.tds = 1; %yes, compute the time derivative spec
if params.tds == 1
    params.sigma = 25.6; %gaussian filter after spectrogram computed
    params.gaussize = 64;
    x = linspace(-params.gaussize/2,params.gaussize/2,params.gaussize);
    params.gaussfilter = exp(-x.^2/(2*params.sigma ^2));
    params.gaussfilter = params.gaussfilter/sum(params.gaussfilter);%used to smooth the spectrogram before computing TDS in jc_calcspecs
end
