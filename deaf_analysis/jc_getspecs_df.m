function spec = jc_getspecs_df(batch,CHANSPEC)
%measures volume for every syllable, use for comparing pre and post
%deafening

ff = load_batchf(batch);
cnt = 0;
for i = 1:length(ff)
    
    fn = ff(i).name;
    fnn = [fn,'.not.mat'];
    load(fnn);
    if (strcmp(CHANSPEC,'w'))
            [dat,fs] = audioread(fn);
    else
        [dat,fs]=evsoundin('',fn,CHANSPEC);
    end
    if (isempty(dat))
        disp(['hey no data!']);
        continue;
    end
    
    vol = [];
    for i = 1:length(onsets)
        onsamp = onsets(i)*1e-3*fs; offsamp = offsets(i)*1e-3*fs;
        smtmp = dat(floor(onsamp-256):ceil(offsamp+256));
        filtsong = bandpass(smtmp,fs,300,10000,'hanningffir');
        vol = [vol; mean(filtsong.^2)];
    end
    
     if (strcmp(CHANSPEC,'obs0'))
            rd = readrecf(fn);
            key = 'created:';
            ind = strfind(rd.header{1},key);
            tmstamp = rd.header{1}(ind+length(key):end);
            tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed

            ind2 = strfind(rd.header{5},'=');
            filelength = sscanf(rd.header{5}(ind2 + 1:end),'%g');%duration of file

            tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
            datenm = tm_st;
            [yr mon dy hr minutes sec] = datevec(datenm);
     elseif strcmp(CHANSPEC,'w')
         %datenm = fn2datenum(fn);
         formatIn = 'yyyymmddHHMMSS';
         datenm = datenum(datevec(fn(end-17:end-4),formatIn));
     end
     
     cnt = cnt+1;
     spec(cnt).filename = fn;
     spec(cnt).datenm = datenm;
     spec(cnt).volume = vol;
     
end

     
    
     