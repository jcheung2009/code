function fvalsstr = jc_findrepeat3(batch,note,prenote, ...
    CHANSPEC)
%similar to jc_findrepeat2 except does not resegment the repeat
%written to analyze repeats in w8o86 because those were manually edited in
%evsonganaly
%does not compute spectral features, only counts repeat number and saves
%waveform
tic 
usingregexp = input('using regular expression? (y/n):','s');

fvalsstr=[];

if (~exist('prenote'))
    prenote='';
elseif (length(prenote)<1)
    prenote='';
end

if (~exist('CHANSPEC'))
    CHANSPEC='obs0';
elseif (length(CHANSPEC)<1)
    CHANSPEC='obs0';
end

if (~exist('NFFT'))
    NFFT=1024;
elseif (length(NFFT)<1)
    NFFT=1024;
end

if (~exist('USEFIT'))
    USEFIT=1;
elseif (length(USEFIT)<1)
    USEFIT=1;
end

run_count=0;
ff=load_batchf(batch);
for ifn=1:length(ff)
    
    fn=ff(ifn).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
    labels = lower(labels);
    labels(findstr(labels,'0'))='-';
    
    %load rec file
    rd = readrecf(fn);

    %load raw song data
    [pthstr,tnm,ext] = fileparts(fn);
    if (strcmp(CHANSPEC,'w'))
            [dat,fs] = wavread(fn);
    elseif (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,CHANSPEC);
    else
        [dat,fs]=evsoundin('',fn,CHANSPEC);
    end
    if (isempty(dat))
        disp(['hey no data!']);
        continue;
    end
    
    if usingregexp == 'y'
        [onind offind] = regexp(labels,note);
        offind = offind-1;
        runlength = offind-onind+1;
        if isempty(runlength)
            continue
        end
        pp = onind; 
    else
        p = ismember(labels,note);
        kk = [find(diff([-1 p -1])~=0)];
        runlength = diff(kk);
        runlength = runlength(1+(p(1)==0):2:end);
        if isempty(runlength)
            continue
        end
        if ~isempty(prenote)
            pp = strfind(labels,[prenote,note]);
            onind = pp + 1; %start index for each repeat run
            offind = pp + runlength; %end index for each repeat run
        else
            pp = find(diff(p)==1);
            onind = pp+1;
            offind = pp+runlength;
        end
    end
    
    for z = 1:length(onind)
        for v = 1:runlength(z) 
            onsamp = floor(onsets(onind(z)+v-1)*1e-3*fs)-256;
            offsamp = ceil(offsets(onind(z)+v-1)*1e-3*fs)+256;
            smtemp = dat(onsamp:offsamp);
            sm = evsmooth(smtemp,fs);
            sm = log(sm);
            sm = sm-min(sm);
            sm = sm./max(sm);
            abovethresh = find(sm>=0.5);
            sm_ons = abovethresh(1);
            sm_offs = abovethresh(end);
            onsamp = onsamp+sm_ons;
            offsamp = onsamp+sm_offs;
            onsets(onind(z)+v-1) = (onsamp/fs)*1e3;
            offsets(onind(z)+v-1) = (offsamp/fs)*1e3;
        end
    end
    
    
    for i = 1:length(runlength) %for each instance of a repeat run
        ton = onsets(onind(i)); toff = offsets(offind(i));%in ms

        onsamp = ceil((ton*1e-3)*fs);
        offsamp = ceil((toff*1e-3)*fs);
        if offsamp + 512 > length(dat)       
            offsamp = length(dat);
        else
            offsamp = offsamp+512;%buffer by 16 ms
        end
        if onsamp - 1024 < 1%buffer by 32 ms
            onsamp = 1;
        else 
            onsamp = onsamp-1024;
        end
        
        smtemp = dat(onsamp:offsamp);
        sm = evsmooth(smtemp,fs);
        sm = log(sm);%better for segmentation
        sm = sm-min(sm);
        sm = sm./max(sm);
        
        ons = onsets(onind(i):onind(i)+runlength(i)-1); 
        offs = offsets(onind(i):onind(i)+runlength(i)-1);
        sylldurations = offs-ons;
        gapdurations = ons(2:end)-offs(1:end-1);

        %compute datenum from rec file by adding repeat ton in milliseconds
         if (strcmp(CHANSPEC,'obs0'))
            key = 'created:';
            ind = strfind(rd.header{1},key);
            tmstamp = rd.header{1}(ind+length(key):end);
            tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed

            ind2 = strfind(rd.header{5},'=');
            filelength = sscanf(rd.header{5}(ind2 + 1:end),'%g');%duration of file

            tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
            datenm = addtodate(tm_st, round(ton), 'millisecond');%add time to onset of syllable
            [yr mon dy hr minutes sec] = datevec(datenm);
         elseif strcmp(CHANSPEC,'w')
             datenm = fn2datenum(fn);
         end
        run_count=run_count+1;
        fvalsstr(run_count).fn = fn;    
        fvalsstr(run_count).datenm = datenm;
%         fvalsstr(run_count).ons = ons; %in ms, onset of each syllable in run into smtemp
%         fvalsstr(run_count).off = offs;% in ms, offset of each syllable in run into smtemp
         fvalsstr(run_count).runlength = runlength(i); %number of syllables in run
         fvalsstr(run_count).sylldurations = sylldurations; %duration of each syllable in run
         fvalsstr(run_count).syllgaps = gapdurations; %gaps between each adjacent syllable in run
        fvalsstr(run_count).smtmp = smtemp; %unfiltered amp env of repeat run
%         fvalsstr(run_count).pitchest = pitchest; %pitch estimate for each syllable in repeat run 
%         fvalsstr(run_count).ent = spent;%spectral entropy for each syllable in repeat run
%         fvalsstr(run_count).pc = pitchcontours_all_syllables; %pitch contour for each syllable in repeat run, each row is syllable, first row is time vector
        fvalsstr(run_count).ind = pp(i);%start index for run in the song
%         fvalsstr(run_count).amp = amp; %volume for each syllable in run computed by taking average of smooth, rectified waveform
        fvalsstr(run_count).sm = sm;%smooth, rectified and log filtered amp env of repeat run
    end
    
end
toc