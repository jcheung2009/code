function merge_prevlbl(batch,syl,dur);
%merges target syl with the previous syl 
%put dur if want to put a thresh for syl dur under which to use merge

ff = load_batchf(batch);
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
    end
    fn = ff(i).name;
    ind = strfind(labels,syl);
    
    prevind = [];
    for n = 1:length(ind)
        if isempty(dur)
            if (ind(n)-1 >= 1)
                prevind = [prevind; ind(n)-1];
                onsets(ind(n)) = onsets(ind(n)-1);
            end
        else
            if (ind(n)-1 >=1) & (offsets(ind(n))-onsets(ind(n)) < dur*1e3)
                prevind = [prevind; ind(n)-1];
                onsets(ind(n)) = onsets(ind(n)-1);
            end
        end
    end
    if ~isempty(prevind)
        onsets(prevind) = [];offsets(prevind) = [];
        labels(prevind) = [];
        cmd = ['save ',fn,'.not.mat offsets onsets labels -append;'];
        eval(cmd);
    end
end
