function merge_nextlbl(batch,syl,dur);
%merges target syl with next syl
%put dur if want to put a thresh for syl dur under which to use merge

ff = load_batchf(batch);;
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
    end
    fn = ff(i).name;
    ind = strfind(labels,syl);
    
    nextind = [];
    for n = 1:length(ind)
        if isempty(dur)
            if(ind(n)+1 <= length(labels))
                nextind = [nextind; ind(n)+1];
                offsets(ind(n)) = offsets(ind(n)+1);
            end
        else
            if (ind(n)+1<=length(labels)) & (offsets(ind(n))-onsets(ind(n)) < dur*1e3)
                nextind = [nextind; ind(n)+1];
                offsets(ind(n)) = offsets(ind(n)+1);
            end
        end
    end
    if ~isempty(nextind)
        onsets(nextind) = [];offsets(nextind) = [];
        labels(nextind) = [];
        cmd = ['save ',fn,'.not.mat offsets onsets labels -append;'];
        eval(cmd);
    end
end