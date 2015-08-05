function [thetime] = mgetwavtime(wavfile)
%
% function [thetime] = mgetwavdate(wavfile)
%
% returns the time (hhmmss) from wav files generated with EvSAP
%

usidx = strfind(wavfile,'_');
extidx = strfind(wavfile,'.');

thetime = wavfile(usidx(2)+1:extidx(1)-1);

return;