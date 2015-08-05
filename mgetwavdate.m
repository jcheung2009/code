function [thedate] = mgetwavdate(wavfile)
%
% function [thedate] = mgetwavdate(wavfile)
%
% returns the date from wav files generated with EvSAP
%

usidx = strfind(wavfile,'_');
extidx = strfind(wavfile,'.');

thedate = wavfile(usidx(1)+1:usidx(2)-1);

return;