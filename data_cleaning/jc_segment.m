function jc_segment(batch,min_int2,min_dur2,threshold2,filetype)
%segments cbin files but skips files that already  have notmats
%threshold on log scale, get from evsonganaly
ff = load_batchf(batch);

for i = 1:length(ff)
    fn = ff(i).name;
    if exist([fn,'.not.mat'])
        continue
    end

    if strcmp(filetype,'obs0')
        [dat Fs] = evsoundin('',fn,'obs0');
    else strcmp(filetype, 'wav')
        [dat Fs] = evsoundin('',fn,'w');
    end
    sm = evsmooth(dat,Fs);
    [ons offs] = SegmentNotes(log10(sm),Fs,min_int2,min_dur2,threshold2);%in seconds
    labels2 = char(ones([1,length(ons)])*fix('-'));
    
    labels = labels2;
    onsets = ons*1e3;%in ms
    offsets = offs*1e3;
    fname = fn;
    threshold = 10^threshold2;
    min_int = min_int2;
    min_dur = min_dur2;
    sm_win = 2.0;
    cmd = ['save ',fn,'.not.mat fname Fs labels min_int min_dur ',...
        'offsets onsets sm_win threshold;'];
    eval(cmd);
end