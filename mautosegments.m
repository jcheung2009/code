function [] = mautosegments(songfile, threshold, thelabel)
%
%
%   autosegments songfile using mautothresh() and generates
%   not.mat file with all segments labeled thelabel
%
%   


min_int = 15;
min_dur = 20;
sm_win = 2;

[filepath,filename,fileext] = fileparts(songfile);

if(strcmpi(fileext,'.cbin'))
    [plainsong,Fs] = ReadCbinFile(songfile);
elseif(strcmpi(fileext,'.wav'))
    [plainsong,Fs] = wavread(songfile);
end

%threshold = mautothresh(songfile,SD);


[onsets offsets] = msegment(mquicksmooth(plainsong, Fs),Fs,min_int,min_dur,threshold);
labels = char(ones(1,[length(onsets)])*fix(thelabel))
fname = filename;


cmd = ['save ',songfile,'.not.mat fname Fs labels min_dur min_int offsets onsets sm_win threshold'];
eval(cmd);
return;