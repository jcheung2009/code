function jc_findBOSfiles(batchrhd)
%finds BOS files in batch list of rhd files that has already been screened
%to contain vocalization

ff = load_batchf(batchrhd);
fsong = fopen('batchrhdsongs','w');
fBOS = fopen('batchrhdBOS','w');
for i = 1:length(ff)
    if strfind(ff(i).name,'BOS')
        fprintf(fBOS,'%s\n',ff(i).name);
    else
        fprintf(fsong,'%s\n',ff(i).name);
    end
end
fclose(fsong); fclose(fBOS);
    
    