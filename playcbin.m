function [out] = playcbin(cbin)
%
%
% plays a cbin file on computer's sound system
%
%

[filepath,filename,fileext] = fileparts(cbin);

if(strcmpi(fileext,'.cbin'))
    [rawsong fs] = ReadCbinFile(cbin);
    rawsong = rawsong(:,1);
    norm_fact = max(abs(rawsong));
    rawsong = rawsong / norm_fact;
elseif(strcmpi(fileext,'.wav'))
    [rawsong,fs] = wavread(cbin);
    rawsong = rawsong * (max(abs(rawsong)) / 1e-3);
end

sound(rawsong,fs,16); % hardcoded sample rate and bit-depth; should be fine on most systems
out = 1;
