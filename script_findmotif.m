%script to run jc_findmotif in batch
%this will still require user input for segmentation 
%load up fv_parameters

%start in directory with all data folders
ff = load_batchf('batch');

for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['motif_aabbb_',ff(i).name,'=','jc_findmotif(''batch.keep'',''aabbb'',{''a'',''b''},{fvalbnd_syllA1,fvalbnd_syllB},{0.05,0.035})'];
    eval(cmd);
    varname = ['''motif_aabbb_',ff(i).name,''''];
    cmd2 = ['bout_',ff(i).name,'=','jc_findbout(''batch.keep''',varname,',''aabbb'')'];
    varname2 = ['''bout_',ff(i).name,''''];
    eval(cmd2);
    cd ../analysis/data_structures
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    eval(savecmd);
    eval(savecmd2);
    clearvars -except fvalbnd_syllA1 fvalbnd_syllB ff
    cd ../../
end
