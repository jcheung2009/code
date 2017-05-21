function datenm = fn2datenm(fn,CHANSPEC,varargin);
%extract datenum from filename and also add time into file (in ms) to seconds 

if ~isempty(varargin)
    time_to_add = round(varargin{1});%time into file to add to start file time (ms)
end

if (strcmp(CHANSPEC,'obs0'))
    rd = readrecf(fn);
     if isfield(rd,'header')
        key = 'created:';
        ind = strfind(rd.header{1},key);
        tmstamp = rd.header{1}(ind+length(key):end);
        try
            tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
            ind2 = strfind(rd.header{5},'=');
            filelength = sscanf(rd.header{5}(ind2 + 1:end),'%g');%duration of file

            tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of filefiltsong
            datenm = addtodate(tm_st, time_to_add, 'millisecond');
            [yr mon dy hr minutes sec] = datevec(datenm);     
        catch
            datenm = fn2datenum(fn);
        end
     else
         datenm = fn2datenum(fn);
     end
 elseif strcmp(CHANSPEC,'w')
     formatIn = 'yyyymmddHHMMSS';
     datenm = datenum(datevec(fn(end-17:end-4),formatIn));
     datenm = addtodate(tm_st, time_to_add, 'millisecond');
 end