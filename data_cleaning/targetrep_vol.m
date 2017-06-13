function targetrep_vol(batch,target,hithresh,lothresh);
%replace syllable if it is under or over a volume threshold

ff = load_batchf(batch);
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
        [dat fs] = evsoundin('',ff(i).name,'obs0');
    end
    ind = strfind(labels,target);
    fn = ff(i).name;
    for n = 1:length(ind)
        smtemp = dat(floor(onsets(ind(n))*1e-3*fs):ceil(offsets(ind(n))*1e-3*fs));
        sm = evsmooth(smtemp,fs,'','','',5);
        vol = mean(log10(sm));
        if ~isempty(hithresh)
            if vol > hithresh
                labels(ind(n)) = '-';
            end
        elseif ~isempty(lothresh)
            if vol < lothresh
                labels(ind(n)) = '-';
            end
        end
    end
    cmd = ['save ',fn,'.not.mat labels -append;'];
    eval(cmd);
   
end