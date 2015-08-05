function thresh = mautothresh(songfile,SD)
%
%
% thresh = mautothresh(rawsong,SD)
% 
% uses gaussians to model noise distribution in songfile, then calculates segmentation threshold   
% that is SD standard deviations above the noise. Intended for
% autosegmentation. Works on .cbin and .wav files.
%
%

[filepath,filename,fileext] = fileparts(songfile);

if(strcmpi(fileext,'.cbin'))
    [plainsong,Fs] = ReadCbinFile(songfile);
elseif(strcmpi(fileext,'.wav'))
    [plainsong,Fs] = wavread(songfile);
end

plainsong = decimate(plainsong,3);
Fs = Fs / 3;

smoothed = mquicksmooth(plainsong,Fs,1,2,500,4000);

fits = gmdistribution.fit(log10(smoothed),2);

sigmas = zeros(1,2);

[R sd1] = corrcov(fits.Sigma(1));
[R sd2] = corrcov(fits.Sigma(2));

sigmas(1) = sd1;
sigmas(2) = sd2;

[themax maxloc] = max([fits.PComponents(1) fits.PComponents(2)]);


thresh = 10^(fits.mu(maxloc)+SD*sigmas(maxloc));

return;