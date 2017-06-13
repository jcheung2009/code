function merge_targetlbl(batch,target);
%merges target motif 

targetln = length(target);
ff = load_batchf(batch);
for i = 1:length(ff)
    if exist([ff(i).name,'.not.mat'])
        load([ff(i).name,'.not.mat']);
    end
    fn = ff(i).name;
    ind = strfind(labels,target);
    
    nextind = [];
    for n = 1:length(ind)
        if(ind(n)+targetln-1 <= length(labels))
            nextind = [nextind; ind(n)+targetln-1];
            offsets(ind(n)) = offsets(ind(n)+targetln-1);
        end
    end
    if ~isempty(nextind)
        onsets(nextind) = [];offsets(nextind) = [];
        labels(nextind) = [];
        cmd = ['save ',fn,'.not.mat offsets onsets labels -append;'];
        eval(cmd);
    end
end