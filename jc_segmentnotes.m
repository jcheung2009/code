function jc_segmentnotes(batch)
%segments cbin files and saves .not.mats 
%uses threshold based on median 

stdmin = 3;
min_dur = 30;
min_int = 5;
sm_win = 2.0;

ff = load_batchf(batch);
for i = 1:length(ff)
    [song fs] = evsoundin('',ff(i).name,'obs0');
    sm = evsmooth(song,fs);
    noise_std_detect = median(sm)/0.6745;
    thr = stdmin*noise_std_detect;
    [ons offs] = SegmentNotes(sm,fs,min_int,min_dur,thr);
    onsets = ons*1e3; offsets = offs*1e3;%change into milliseconds
    labels = char(ones([1,length(onsets)])*fix('-'));
    fname = ff(i).name;
    Fs = fs;
    threshold = thr;
    cmd = ['save ',ff(i).name,'.not.mat fname Fs labels min_dur min_int ',...
        'offsets onsets sm_win threshold'];
    eval(cmd);
end