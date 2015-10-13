%script to run jc_findrepeat2 in batch

ff = load_batchf('batch2');

for i = 1:length(ff)
    cd(ff(i).name);
    cmd = ['fv_repA_',ff(i).name,'=','jc_findrepeat2(''batch.keep'',''a'','''',fvalbnd_syllA,[0.025 0.035],1,''obs0'',''n'',''y'')'];
    eval(cmd);
    cd ../analysis/data_structures
    varname = ['''fv_repA_',ff(i).name,''''];
    savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
    eval(savecmd);
    clearvars -except fvalbnd_syllB fvalbnd_syllA ff
    cd ../../
end