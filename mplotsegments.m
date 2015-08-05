function [onsets,offsets,segments] = mplotsegments(cbin,plotit)
%
%[onsets,offsets,segments] = mplotsegments(cbin,plotit)
%
%
%
[filepath,filename,fileext] = fileparts(cbin);

if(strcmpi(fileext,'.cbin'))
    [plainsong,fs] = ReadCbinFile(cbin);
elseif(strcmpi(fileext,'.wav'))
    [plainsong,fs] = wavread(cbin);
    %plainsong = plainsong *10e3; % boost amplitude to cbin levels
end

[smoothed spec t f] = evsmooth(plainsong,fs,0,256,0.2,5);
thresh = mean(smoothed(1:1000)) + (50*std(smoothed(1:1000))); % syllable threshold at 50 std deviations from mean of 1st 1000 pnts
[onsets, offsets] = segment(smoothed,fs,10,30,thresh);

segments = zeros(length(smoothed),1);

pad = 1; % pad in ms
onsets = onsets - pad; % pad onsets & offsets to ensure the whole syllable is extracted
offsets = offsets + pad;

ons_ms = onsets;
offs_ms = offsets;

onsets = (onsets / 1e3) * fs; % convert ms to pnts
offsets = (offsets / 1e3) *fs;

labels = [];
theLabel = 'a'; % hardcoded label 'a' for all autodetected syllables

for index=1:length(onsets);
    segments(onsets(index):offsets(index)) = thresh;
    labels = [labels theLabel];
end

timebase = maketimebase(length(smoothed),fs);

% write not.mat file:
mSaveNotMat([filename fileext],fs,ons_ms,offs_ms,labels,thresh);

if(plotit)
    figure();ax(1)=subplot(2,1,1);mplotcbin(cbin,[]);
    ax(2) = subplot(2,1,2);semilogy(timebase,smoothed);hold on;semilogy(timebase,segments,'r');hold off
    linkaxes(ax,'x');
end
return;