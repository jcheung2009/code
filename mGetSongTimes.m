function songtimes = mGetSongTimes(batch)
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

songtimes = zeros(1,5000);

while(1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    
    [pth,nm,ext]=fileparts(fn);
    sepIdx = strfind(nm,'_');
    timeStr = nm(sepIdx(2)+1:length(nm));
    songtimes(filenum) = mEvTime2RealTime(timeStr);
     
    filenum = filenum +1;    
end;

songtimes = songtimes(1:filenum-1);