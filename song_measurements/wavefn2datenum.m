function datenm = wavefn2datenum(fn);
formatIn = 'yyyymmddHHMMSS';
datenm = datenum(datevec(fn(end-17:end-4),formatIn));