%script to run jc_findwnote5 in batch 
%load up fv_parameters

%start in the directory with all data folders
ff = load_batchf('batch2');
tic
for i = 1:length(ff)
    cd(ff(i).name);
    cmd1 = ['fv_syllA_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''a'','''','''',[0.04 0.08],fvalbnd_syllA,512,1,''obs0'',0,0)'];
    cmd2 = ['fv_syllB_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''b'',''a'','''',0.035,fvalbnd_syllB,512,1,''obs0'',0,0)'];
    cmd3 = ['fv_syllC_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''c'','''','''',[0.02 0.04],fvalbnd_syllC,512,1,''obs0'',0,0)'];
    %cmd4 = ['fv_syllW1_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''w'',''r'','''',0.04,fvalbnd_syllW1,512,1,''obs0'',0,0)'];
    %cmd5 = ['fv_syllW2_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''w'',''w'','''',0.04,fvalbnd_syllW2,512,1,''obs0'',0,0)'];
    eval(cmd1);
    eval(cmd2);
    eval(cmd3);
    %eval(cmd4);
    %eval(cmd5);
    cd ../analysis/data_structures
    varname1 = ['''fv_syllA_',ff(i).name,''''];
    varname2 = ['''fv_syllB_',ff(i).name,''''];
    varname3 = ['''fv_syllC_',ff(i).name,''''];
    %varname4 = ['''fv_syllW1_',ff(i).name,''''];
    %varname5 = ['''fv_syllW2_',ff(i).name,''''];
    savecmd1 = ['save(',varname1,',',varname1,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    savecmd3 = ['save(',varname3,',',varname3,',','''-v7.3'')'];
    %savecmd4 = ['save(',varname4,',',varname4,',','''-v7.3'')'];
    %savecmd5 = ['save(',varname5,',',varname5,',','''-v7.3'')'];
    eval(savecmd1);
    eval(savecmd2);
    eval(savecmd3);
    %eval(savecmd4);
    %eval(savecmd5);
    clearvars -except fvalbnd_syllA fvalbnd_syllB fvalbnd_syllC ff
    cd ../../
end
toc
    