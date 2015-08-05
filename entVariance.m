function [entvar entvect] = entVariance(songfile);
%
%
%
%

[filepath,filename,fileext] = fileparts(songfile);

if(strcmpi(fileext,'.cbin'))
    [rawsong,fs] = ReadCbinFile(songfile);
elseif(strcmpi(fileext,'.wav'))
    [rawsong,fs] = wavread(songfile);
end

rawsong = rawsong(1*fs:length(rawsong));

[spec t f] = plotspect(rawsong,fs,0);
spec_sub = spec(20:length(f)/2,:);

entvect = rolling_ent(abs(spec_sub));
entvar = var(entvect);

zeroRows = findvals(entvect,0.995);
entvect = entvect';
zeroRows = zeroRows';

entvect_nozero = removerows(entvect,zeroRows); % omit silences / gaps
entvect = entvect_nozero';

