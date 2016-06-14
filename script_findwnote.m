%script to run jc_findwnote5 in batch 
%load up fv_parameters

%start in the directory with all data folders
ff = load_batchf('batch');
tic
for i = 28
    cd(ff(i).name);
    cmd1 = ['fv_syllA1_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''a'','''',''b'',[0.04 0.06],fvalbnd_syllA,512,1,''obs0'',0,0)'];
    cmd2 = ['fv_syllA2_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''a'',''e'','''',[0.04 0.06],fvalbnd_syllA,512,1,''obs0'',0,0)'];
    cmd3 = ['fv_syllB_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''b'','''','''',[0.03 0.05],fvalbnd_syllB,512,1,''obs0'',0,0)'];
    cmd4 = ['fv_syllC1_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''c'',''b'','''',[0.04 0.06],fvalbnd_syllC,512,1,''obs0'',0,0)'];
    cmd5 = ['fv_syllC2_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''c'',''c'','''',[0.04 0.06],fvalbnd_syllC,512,1,''obs0'',0,0)'];
    cmd6 = ['fv_syllD1_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''d'',''c'','''',[0.035 0.05],fvalbnd_syllD,512,1,''obs0'',0,0)'];
    cmd7 = ['fv_syllD2_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''d'',''d'','''',[0.035 0.05],fvalbnd_syllD,512,1,''obs0'',0,0)'];
    cmd8 = ['fv_syllE_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''e'','''','''',[0.04 0.06],fvalbnd_syllE,512,1,''obs0'',0,0)'];
    eval(cmd1);
    eval(cmd2);
    eval(cmd3);
    eval(cmd4);
    eval(cmd5);
    eval(cmd6);
    eval(cmd7);
    eval(cmd8);
    cd ../analysis/data_structures
    varname1 = ['''fv_syllA1_',ff(i).name,''''];
    varname2 = ['''fv_syllA2_',ff(i).name,''''];
    varname3 = ['''fv_syllB_',ff(i).name,''''];
    varname4 = ['''fv_syllC1_',ff(i).name,''''];
    varname5 = ['''fv_syllC2_',ff(i).name,''''];
    varname6 = ['''fv_syllD1_',ff(i).name,''''];
    varname7 = ['''fv_syllD2_',ff(i).name,''''];
    varname8 = ['''fv_syllE_',ff(i).name,''''];
    savecmd1 = ['save(',varname1,',',varname1,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    savecmd3 = ['save(',varname3,',',varname3,',','''-v7.3'')'];
    savecmd4 = ['save(',varname4,',',varname4,',','''-v7.3'')'];
    savecmd5 = ['save(',varname5,',',varname5,',','''-v7.3'')'];
    savecmd6 = ['save(',varname6,',',varname6,',','''-v7.3'')'];
    savecmd7 = ['save(',varname7,',',varname7,',','''-v7.3'')'];
    savecmd8 = ['save(',varname8,',',varname8,',','''-v7.3'')'];
    eval(savecmd1);
    eval(savecmd2);
    eval(savecmd3);
    eval(savecmd4);
    eval(savecmd5);
    eval(savecmd6);
    eval(savecmd7);
    eval(savecmd8);
    
    clearvars -except fvalbnd_syllA fvalbnd_syllB fvalbnd_syllC fvalbnd_syllD fvalbnd_syllE ff
    cd ../../
end
toc
    