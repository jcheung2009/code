function [playbacks] = cleanplaybacks(batch,playbacklog)
%
% function [playbacks] = mcleanplaybacks(batch,playbacklog)
%
% creates a batch.playback file containing filenames of tutor song playbacks
% based on log file.
%
%

fid=fopen(batch,'r');
fplayback=fopen([batch,'.playback'],'w');
pbid = fopen(playbacklog,'r');

numfiles = mcountfilelines(playbacklog);
pbMtx = zeros(2,numfiles);
index=1;
while (1) % each line in log goes into pbMtx
    pbline=fgetl(pbid);
    if (~ischar(pbline))
        break;
    end
    
    if(isempty(strfind(pbline,'Cleared'))) % if tutor song triggered
        spaceidx = strfind(pbline,' ');
        timestr = pbline(1:spaceidx(1)-1);
        AMPMstr = pbline(spaceidx(1)+1:spaceidx(2)-1);
        datestr = pbline(spaceidx(2)+1:spaceidx(3)-1);
        if(isempty(strmatch('PM',AMPMstr)))
            PM=0;
        else
            PM=1;
        end
        
        dateval = str2num(mdate2datestr(datestr));
        timeval = str2num(mtime2timestr(timestr,PM));
        pbMtx(1,index) = dateval;
        pbMtx(2,index) = timeval;
        index = index+1;
    end   
        
end

for i=1:length(pbMtx)
    thedate = pbMtx(1,i);
    thetime = pbMtx(2,i);
    frewind(fid);
    while (1) % check against files in batch
        wavfile=fgetl(fid);
        if (~ischar(wavfile))
            break;
        end
        wavdate=str2num(mgetwavdate(wavfile));
        wavtime=str2num(mgetwavtime(wavfile));
        if(wavdate == thedate && abs(wavtime-thetime)<10)            
            fprintf(fplayback,'%s\n',wavfile);
        end
    end
end
fclose(fid);fclose(fplayback);

return;