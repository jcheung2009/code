function [vol ent rat]=getsyllablevels(cbin,syll,plotit)
%
% mnm, 28 april 2009. in progress.
%

nfft = 256; % note hardcoded bin-size for spect files
[rawsong fs] = ReadCbinFile(cbin);
rawsong = abs(rawsong(:,1));

%strip the 'cbin, add 'spect' to the filename, & load spect file:
spectFN = cbin(1,1:length(cbin)-4);
spectFN = [spectFN 'spect'];
spect = load(spectFN);

% ditto for .not.mat:
notMatFN = cbin(1,1:length(cbin));
notMatFN = [notMatFN '.not.mat'];
notMat = load(notMatFN);

onsets = notMat.onsets/1e3; %now in seconds
offsets = notMat.offsets/1e3;


spect_ent = spect(1:3:end);
spect_vol = spect(2:3:end);
spect_rat = spect(3:3:end);

length(spect_ent)
length(rawsong)

padlen = length(rawsong) - (length(spect_ent)*nfft);
length(padlen)
pad = zeros(1,padlen);
pad_ent = [pad spect_ent];
pad_vol = [pad spect_vol];
pad_rat = [pad spect_rat];

% spect_ent = resample(spect(1:3:end),256,1);
% spect_vol = resample(spect(2:3:end),256,1);
% spect_rat = resample(spect(3:3:end),256,1);
