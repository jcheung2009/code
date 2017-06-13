function jc_resegment_target(batch,target,prent,postnt,newlbl,min_dur,min_int,thresh);
%regsegments specific target with manually set parameters and saves back
%into notmat

targetln = length(target);
prentln = length(prent);
ff = load_batchf(batch);
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
    else
        continue
    end
    fn = ff(i).name;
    oldlblsln = length(labels);
    p = strfind(labels,[prent target postnt]);
    p = p+prentln;
    [dat fs] = evsoundin('',fn,'obs0');
    sm=evsmooth(dat,fs,'','','',5);
    nbuffer = 0.016*fs; 
    for ind = 1:length(p)
        ton=onsets(p(ind));toff=offsets(p(ind)+targetln-1);
        onsamp = floor(ton*1e-3*fs)-nbuffer;
        offsamp = ceil(toff*1e-3*fs)+nbuffer;
        segment = log10(sm(onsamp:offsamp));
        segment = segment-min(segment);
        segment = segment./max(segment);
        [ons offs] = SegmentNotes(segment,fs,min_int,min_dur,thresh);
        if length(ons) ~= length(newlbl)
            continue
        else
            ons = ons*fs;
            offs = offs*fs;
            ons = ((onsamp+ons)/fs)*1e3;
            offs = ((onsamp+offs)/fs)*1e3;
            onsets = [onsets(1:p(ind)-1);ons;onsets(p(ind)+targetln:end)];
            offsets = [offsets(1:p(ind)-1);offs;offsets(p(ind)+targetln:end)];
            labels = [labels(1:p(ind)-1),newlbl,labels(p(ind)+targetln:end)];
            p = p+1;
        end
    end
    if length(labels) ~= oldlblsln
        cmd = ['save ',fn,'.not.mat offsets onsets labels -append;'];
        eval(cmd);
    end
end
        
        