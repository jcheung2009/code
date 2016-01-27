%script to run jc_findmotif in batch
%this will still require user input for segmentation 
%load up fv_parameters
tic
%start in directory with all data folders
ff = load_batchf('batch');

for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['motif_aabb_',ff(i).name,'=','jc_findmotif(''batch.keep.rand'',''aabb'',{''a'',''b''},{fvalbnd_syllA,fvalbnd_syllB},{[0.03 0.05],[0.025 0.035]},''n'',''n'',''obs0'')'];
    eval(cmd);
    cmd2 = ['bout_',ff(i).name,'=','jc_findbout(''batch.keep.rand'',motif_aabb_',ff(i).name,',''aabb'',0,0,''obs0'')'];
    eval(cmd2);
    cd ../analysis/data_structures
    varname = ['''motif_aabb_',ff(i).name,''''];
    varname2 = ['''bout_',ff(i).name,''''];
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    eval(savecmd);
    eval(savecmd2);
    clearvars -except fvalbnd_syllA fvalbnd_syllB ff
    cd ../../
end
toc