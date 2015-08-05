function downsample_batch(batch,CHANSPEC,newfs)
%
%
%
%
%

if (~exist('CHANSPEC'))
    CHANSPEC='w';
end

fid=fopen(batch,'r');
while (1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    if (~exist(fn,'file'))
        continue;
    end
    %disp(fn);

    [pth,nm,ext]=fileparts(fn);
    if (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,'0r');
    else
        [dat,fs]=evsoundin('',fn,CHANSPEC);
    end
    newDat = resample(dat,newfs,fs);
    wavwrite(newDat,newfs,fn);
end
fclose(fid);
return