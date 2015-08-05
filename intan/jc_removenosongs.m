function jc_removenosongs(batchrhd)

ff = load_batchf(batchrhd);
fsong = fopen('batchrhd.keep','w');
fdcrd = fopen('batchrhd.dcrd','w');
for i = 1:length(ff)
    [song fs] = IntanRHDReadSong('',ff(i).name);
    if ~isempty(song)
        fprintf(fsong,'%s\n',ff(i).name);
    else
        fprintf(fdcrd,'%s\n',ff(i).name);
    end
end
