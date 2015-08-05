crap=dir('*.rec');
fid=fopen('batchfile','w')

for i=1:length(crap)
    fprintf(fid, '%s\n',crap(i).name(1:end-4));
end;