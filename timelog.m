% getting timestamps from log file

%lists when all files were saved or discarded
ftimelist = fopen('file_time','w');

fid = fopen(log,'r')
tline = fgets(fid);
while ischar(tline)
       if ~isempty(strfind(tline,'File'))
           fprintf(ftimelist,'%s',tline)
       end
       tline = fgets(fid);
end
fclose(ftimelist);fclose(fid);
return

%finds lines where files were DONE and goes back previous line to get unix
%time, vector is [file number, unix time]
timelist = [];
fid = fopen('file_time','r')
tline = fgets(fid);
while ischar(tline)
    if isempty(strfind(tline,'DONE'))
        prevline = tline;
    else 
        timelist = cat(1,timelist,[str2num(prevline(22:25)), str2num(prevline(end-17:end))]);
        prevline = tline;
    end
    tline = fgets(fid);
end
fclose(fid);
timelist = [timelist(:,1) datenum(unixtime(timelist(:,2)))];
    
% %goes into batch to pull out actual file numbers for use later to pull out
% %from timelist
% filenum = [];
% fid = fopen(batch,'r')
% tline = fgets(fid);
% while ischar(tline)
%     filenum = cat(1,filenum,str2num(tline(end-4:end)));
%     tline = fgets(fid);
% end
% fclose(fid);

