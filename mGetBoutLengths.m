function boutlengths = mGetBoutLengths(batch)
%
% returns vector of times that song files were saved, gleaned from
% filenames.
% 
%
%
%

if (~exist(batch));
    disp('Error. Nonexistent Batch File.');
    return;
end

fid=fopen(batch,'r');
filenum = 1;
boutlengths = zeros(1,5000);

disp('working...');

while(1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    [pth,nm,ext]=fileparts(fn);
     if (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,'0r');
    else
        [dat,fs]=evsoundin('',fn,'w'); %note hardcoded channelspec suitable for .wav 
     end
    
    boutlengths(filenum) = length(dat) / fs;
    filenum = filenum +1;    
end;

boutlengths = boutlengths(1:filenum-1);

disp('done');