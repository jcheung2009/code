%script to run jc_findmotif in batch
%this will still require user input for segmentation 
%load up fv_parameters
tic
%start in directory with all data folders
ff = load_batchf('batch2');

for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['motif_cab_',ff(i).name,'=','jc_findmotif(''batch.keep'',''cab'',{''c'',''a'',''b''},{fvalbnd_syllA fvalbnd_syllB fvalbnd_syllC},{[0.04 0.08], 0.035, [0.02 0.04]},''n'',''n'')'];
    eval(cmd);
    cmd2 = ['bout_',ff(i).name,'=','jc_findbout(''batch.keep'',motif_cab_',ff(i).name,',''cab'',0,0)'];
    eval(cmd2);
    cd ../analysis/data_structures
    varname = ['''motif_cab_',ff(i).name,''''];
    varname2 = ['''bout_',ff(i).name,''''];
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    eval(savecmd);
    eval(savecmd2);
    clearvars -except fvalbnd_syllA fvalbnd_syllB fvalbnd_syllC ff
    cd ../../
end
toc