function targetrep_dur(batch,target,hithresh,lothresh);
%replace syllable if it is under or over a duration threshold

ff = load_batchf(batch);
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat'])
    end
    ind = strfind(labels,target);
    fn = ff(i).name;
    for n = 1:length(ind)
        dur = 1e-3*(offsets(ind(n)+length(target)-1)-onsets(ind(n)));
        if ~isempty(hithresh)
            if dur > hithresh
                labels(ind(n)) = '-';
            end
        elseif ~isempty(lothresh)
            if dur < lothresh
                labels(ind(n)) = '-';
            end
        end
    end
    cmd = ['save ',fn,'.not.mat labels -append;'];
    eval(cmd);
   
end