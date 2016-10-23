function tempo = jc_tempo(batch,CHANSPEC)
%measure duration, gaps, and acorr for each song. use for comparing pre and
%post deafening. resegments each syllable in song. Looks at distribution of
%all syllables (not confined to motif)


ff=load_batchf(batch);
cnt = 0;

for i = 1:length(ff)
    fn = ff(i).name;
    fnn = [fn,'.not.mat'];
    
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
    labels = lower(labels);
    labels(strfind(labels,'0'))='-';
    
    gaps = onsets(2:end)-offsets(1:end-1);
    durations = offsets-onsets;
        
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
    tempo(cnt).filename = fn;
    tempo(cnt).datenm = datenm;
%     tempo(cnt).acorr = {lag c};
%     tempo(cnt).firstpeakdistance = acorr;
    tempo(cnt).gaps = gaps;
    tempo(cnt).durations = durations;
end

    
   