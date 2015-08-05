function out = mSaveNotMat(fname,Fs,onsets,offsets,labels,threshold)
%
%
% out = mSaveNotMat(filename,fs,onsets,offsets,labels)
%
%

min_int = 15;
min_dur = 30;

cmd = ['save ',fname,'.not.mat fname Fs labels offsets onsets threshold min_int min_dur'];
eval(cmd);

end