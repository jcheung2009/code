%script to run jc_findmotif in batch
%this will still require user input for segmentation 
%load up fv_parameters
tic
%start in directory with all data folders
ff = load_batchf('batch');

for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['motif_bcd_',ff(i).name,'=','jc_findmotif(''batch.keep'',''bcd'',{''b'',''d''},{fvalbnd_syllB fvalbnd_syllD},{[0.02 0.03],[0.02 0.04]},''n'',''n'',''w'')'];
    eval(cmd);
    cmd2 = ['bout_',ff(i).name,'=','jc_findbout(''batch.keep'',motif_bcd_',ff(i).name,',''bcd'',0,0,''w'')'];
    eval(cmd2);
    cd ../analysis/data_structures
    varname = ['''motif_bcd_',ff(i).name,''''];
    varname2 = ['''bout_',ff(i).name,''''];
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    eval(savecmd);
    eval(savecmd2);
    clearvars -except fvalbnd_syllA fvalbnd_syllB fvalbnd_syllD ff
    cd ../../
end
toc