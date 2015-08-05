function [Type] = DataFileType(Data,FileName);

    if isfield(Data,'VStep')
        Type='VC';
    elseif isfield(Data,'IStep')
        Type='IC';
    elseif ~isempty(regexp(FileName,'Pass'));
        Type='Pass'; 
    elseif ~isempty(regexp(FileName,'Stim'))||~isempty(regexp(FileName,'Control'));
        Type='Stims';
    elseif ~isempty(regexp(FileName,'PPRs'))||~isempty(regexp(FileName,'Control'));
        Type='Stims';  
    elseif ~isempty(regexp(FileName,'LTP'))||~isempty(regexp(FileName,'Control'));
        Type='LTP';              
    elseif ~isempty(regexp(FileName,'RepStim'))||~isempty(regexp(FileName,'Control'));
        Type='Stims';   
    elseif ~isempty(regexp(FileName,'FI'))||~isempty(regexp(FileName,'Control'));
        Type='Old_IC';          
    else
        disp('Unsupported Filetype');
        Type='crap';
    end;  
end

