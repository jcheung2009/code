%rsmpl_trns_strct_batch
fidb = fopen('birds','r');

while 1
    crntdir = fscanf(fidb,'%s',1);
    if isempty(crntdir)
        break
    end
    cd(char(crntdir));
    crntdir = crntdir(1:end-8)
    fid = fopen([char(crntdir) '_seq_stats.prms'],'r');
    for i =1:3
        S{i} = fscanf(fid,'%s',1);
    end
    rsmpl_trns_stats(S{1},S{2},S{3});
    cd ../..
end