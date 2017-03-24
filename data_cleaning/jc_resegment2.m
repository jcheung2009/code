function jc_resegment2(batch,min_int2,min_dur2,sylldurthresh,filetype)
%identifies labelled sounds that are greater than 200 ms duration, and
%resegments with otsu's threshold
ff = load_batchf(batch);
for i = 1:length(ff)
    fn = ff(i).name;
    if ~exist([fn,'.not.mat'])
        continue
    end
    load([fn,'.not.mat']);
    if strcmp(filetype,'obs0')
        [dat Fs] = evsoundin('',fn,'obs0');
    else strcmp(filetype, 'wav')
        [dat Fs] = evsoundin('',fn,'w');
    end
    sm = evsmooth(dat,Fs);
    sm = log10(sm);
    durs = offsets-onsets;%in ms
    p = find(durs > sylldurthresh);%find labels more than 200 ms long
    for ii = 1:length(p)
        onsamp = floor(onsets(p(ii))*1e-3*Fs-(0.012*Fs));
        offsamp = ceil(offsets(p(ii))*1e-3*Fs+(0.015*Fs));
        if offsamp > length(sm)
            offsamp = length(sm)
        end
        sm2 = sm(onsamp:offsamp);
        sm2 = (sm2-min(sm2))/(max(sm2)-min(sm2));
        [ons offs] = SegmentNotes(sm2,Fs,min_int2,min_dur2,0.35);
        if length(ons) == 1
            [ons offs] = SegmentNotes(sm2,Fs,min_int2,min_dur2,graythresh(sm2));
        end
        onsets = [onsets;(onsamp+ons*Fs)*1e3/Fs];
        offsets = [offsets;(onsamp+offs*Fs)*1e3/Fs];
        labels = [labels char(ones([1,length(ons)])*fix('-'))];
    end
    onsets(p) = [];
    offsets(p) = [];
    labels(p) = [];
    [onsets ind] = sort(onsets);
    offsets = sort(offsets);
    labels = labels(ind);
    
    cmd = ['save ',fn,'.not.mat offsets onsets labels -append;'];
    eval(cmd);
end
        
        