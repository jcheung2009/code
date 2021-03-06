%script to run jc_findwnote5 in batch 
%load up fv_parameters

%start in the directory with all data folders
ff = load_batchf('batch');
tic
for i = 1:length(ff)
    cd(ff(i).name);
    cmd1 = ['fv_syllA_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''a'','''','''',[0.02 0.04],[1000 2500],512,1,''w'',0,0,0)'];
    cmd2 = ['fv_syllE_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''e'','''','''',[0.03 0.05],[1500 2700],512,1,''w'',0,0,0)'];
    cmd3 = ['fv_syllT_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''t'','''','''',[0.03 0.05],[1500 2800],512,1,''w'',0,0,0)'];
%     cmd4 = ['fv_syllW1_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''w'',''r'','''',[0.04 0.06],fvalbnd_syllW,512,1,''obs0'',0,0)'];
%     cmd5 = ['fv_syllW2_',ff(i).name,'=','jc_findwnote5(''batch.keep'',''w'',''w'','''',[0.04 0.06],fvalbnd_syllW,512,1,''obs0'',0,0)'];
 
    eval(cmd1);
    eval(cmd2);
    eval(cmd3);
%     eval(cmd4);
%     eval(cmd5);

    cd ../analysis/data_structures
    varname1 = ['''fv_syllA_',ff(i).name,''''];
    varname2 = ['''fv_syllE_',ff(i).name,''''];
    varname3 = ['''fv_syllT_',ff(i).name,''''];
%     varname4 = ['''fv_syllW1_',ff(i).name,''''];
%     varname5 = ['''fv_syllW2_',ff(i).name,''''];
%     
    savecmd1 = ['save(',varname1,',',varname1,',','''-v7.3'')'];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    savecmd3 = ['save(',varname3,',',varname3,',','''-v7.3'')'];
%     savecmd4 = ['save(',varname4,',',varname4,',','''-v7.3'')'];
%     savecmd5 = ['save(',varname5,',',varname5,',','''-v7.3'')'];
    
    eval(savecmd1);
    eval(savecmd2);
    eval(savecmd3);
%     eval(savecmd4);
%     eval(savecmd5);
    
    clearvars -except ff
    cd ../../
end
toc
    