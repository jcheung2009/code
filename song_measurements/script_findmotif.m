%script to run jc_findmotifs for batch of folders
tic
batch = uigetfile;
ff = load_batchf(batch);
for i = 1:length(ff)
    cd(ff(i).name);
    for ii = 1:length(params.findmotif)
        cmd = ['motif_',params.findmotif(ii).motif,'_',ff(i).name,'=','jc_findmotifs(''batch.keep'',params.findmotif(',num2str(ii),'),params.filetype)'];
        eval(cmd);
        cd ../analysis/data_structures
        varname = ['''motif_',params.findmotif(ii).motif,'_',ff(i).name,''''];
        savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
        eval(savecmd);
        clearvars -except ff params
        cd ../../
    end
end
toc