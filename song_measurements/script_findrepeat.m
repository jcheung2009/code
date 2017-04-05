%script to run jc_findrepeat2 in batch

ff = load_batchf('batchnaspm');

for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['fv_repA_',ff(i).name,'=','jc_findrepeat2(''batch.keep.rand'',''a'','''',fvalbnd_syllA,[0.025 0.035],1,''obs0'',''n'',''y'')'];
    cmd2 = ['fv_repB_',ff(i).name,'=','jc_findrepeat2(''batch.keep.rand'',''b'','''',fvalbnd_syllB,[0.03 0.04],1,''obs0'',''n'',''y'')'];
    eval(cmd);
    eval(cmd2);
   %eval(cmd3);
    cd ../analysis/data_structures
    varname = ['''fv_repA_',ff(i).name,''''];
    varname2 = ['''fv_repB_',ff(i).name,''''];
   %varname3 = ['''fv_repD_',ff(i).name,''''];
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
 %  savecmd3 = ['save(',varname3,',',varname3,',','''-v7.3'')'];
    eval(savecmd);
    eval(savecmd2);
  % eval(savecmd3);
    clearvars -except fvalbnd_syllA fvalbnd_syllB ff
    cd ../../
end