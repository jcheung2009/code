function [f Y] = mFFT(inVect,fs)
%
%
%
%
%
%
%


NFFT = 2^nextpow2(length(inVect));
Y = fft(inVect,NFFT) / length(inVect);
f = fs/2 * linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2)),'r.-')
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')