function [out] = playwav(wavfile,nrmlz)
%
%
%
%
%
%

[rawsong fs nbits] = wavread(wavfile);

if(nrmlz)
        rawsong = rawsong / max(abs(rawsong));
end

sound(rawsong,44100,nbits);

out = rawsong;