%script to run jc_findmotifs in batch
tic
config
ff = load_batchf('batch');
for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['motif_abcdeeerww_',ff(i).name,'=','jc_findmotif(''batch.keep'',''aabb'',{''a'',''b''},{fvalbnd_syllA1 fvalbnd_syllA2 fvalbnd_syllB1},{[0.03 0.05],[0.025 0.035]},''n'',''n'',''obs0'')'];
    eval(cmd);
    cmd2 = ['bout_',ff(i).name,'=','jc_findbout(''batch.keep'',motif_aabb_',ff(i).name,',''aabb'',0,0,''obs0'')'];
    eval(cmd2);
    cd ../analysis/data_structures
    varname = ['''motif_aabb_',ff(i).name,''''];
    varname2 = ['''bout_',ff(i).name,''''];
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    eval(savecmd);
    eval(savecmd2);
    clearvars -except fvalbnd_syllA1 fvalbnd_syllA2 fvalbnd_syllB1 ff
    cd ../../
end
toc