function fvalsstr = jc_findrepeat(batch,note,prenote,timeshift,fvalbnd,NFFT,USEFIT, ...
    CHANSPEC)
%extract information for each instance of a repeat run and information for
%each syllable within those repeat runs
%note = repeating syllable, prenote = syllable that precedes the first
%repeat syllable
%fvalsstr:
%   fn
%   datenm
%   ons: onsets of each syllable in run
%   offs: offsets of each syllable in run
%   runlength: number of syllables in run
%   runduration: duration in ms of run
%   sylldurations: duration of each syllable in run
%   syllgaps: gaps between each adjacent syllable in run
%   smtemp: unfiltered amp env of repeat run
%   pitchest = pitch estimate for each syllable in repeat run
%   ent: wiener entropy for each syllable in repeat run
%   ind = index of run
%   amp = volume of each syllable in run
%   sm = smooth filtered amp env of run

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
    
    p = ismember(labels,note);
    kk = [find(diff([-1 p -1])~=0)];
    runlength = diff(kk);
    runlength = runlength(1+(p(1)==0):2:end);
    if isempty(runlength)
        continue
    end
    
    pp = strfind(labels,[prenote,note]);
    onind = pp + 1; %start index for each repeat run
    offind = pp + runlength; %end index for each repeat run
    
    for i = 1:length(pp) %for each instance of a repeat run
        ton = onsets(onind(i)); toff = offsets(offind(i));%in ms
        runduration = toff - ton;
        syllind = onind(i):offind(i);
        syllons = arrayfun(@(x) onsets(x),syllind);
        sylloffs = arrayfun(@(x) offsets(x),syllind);
        
        onsamp = ceil((ton*1e-3)*fs);
        offsamp = ceil((toff*1e-3)*fs);
        if offsamp + 256 < length(dat)
            run_count = run_count + 1;
            smtemp = dat(onsamp-256:offsamp+256);%amplitude envelope of repeat run
            sm = filter(ones(1,256)/256,1,(smtemp.^2));
            %buffered by 8 ms
        else
            disp('time cutoff at end of repeat exceeds file length')
        end
        
        %pitch and entropy measurement for each syllable in repeat
        pitchest = []; amp = []; we= [];
        for ii = 1:length(syllind) %for each syllable in repeat run
            %pitch
            amptmp = dat(floor(syllons(ii)*1e-3*fs):ceil(sylloffs(ii)*1e-3*fs));
            amp = cat(1,amp,mean(amptmp.^2));%volume
            ti1 = ceil((timeshift + syllons(ii)*1e-3)*fs);
            dattmp = dat([ti1:(ti1+NFFT-1)]); 
            fdattmp = abs(fft(dattmp.*hamming(length(dattmp))));
            fvals = [0:length(fdattmp)/2]*fs/(length(fdattmp));
            fdattmp = fdattmp(1:end/2);
            mxtmpvec = zeros([1,size(fvalbnd,1)]);
            for kk = 1:size(fvalbnd,1)
                tmpinds = find((fvals>=fvalbnd(kk,1))&(fvals<=fvalbnd(kk,2)));
                npnts = 10; %number of frequency bins to do weighted average
                [tmp, pf] = max(fdattmp(tmpinds));
                pf = pf + tmpinds(1)-1;
                if (USEFIT==1)%weighted average of frequency bins 
                    tmpxv = pf + [-npnts:npnts];
                    tmpxv = tmpxv(find((tmpxv>0)&(tmpxv<=length(fvals))));
                    mxtmpvec(kk) = fvals(tmpxv)*fdattmp(tmpxv);
                    mxtmpvec(kk) = mxtmpvec(kk)./sum(fdattmp(tmpxv));
                else
                    mxtmpvec(kk) = fvals(pf);
                end
            end
            pitchest = cat(1,pitchest,mean(diff(mxtmpvec)));
            
            %entropy
            dattmp2 = dat(floor(syllons(ii)*1e-3*fs)-128:ceil(sylloffs(ii)*1e-3*fs)+128);
            N = 512; %window size used for spectrogram
            sigma = 1;
            t=-N/2+1:N/2;
            sigma=(sigma/1000)*fs;
            w=exp(-(t/sigma).^2);
            sp = spectrogram(dattmp2,w,N-2,N,fs);
            we = cat(1,we,mean(log(geomean(abs(sp),1)./mean(abs(sp),1))));%wiener entropy for each time bin in spectrogram
        end
        
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
            [yr mon dy hr min sec] = datevec(datenm);
         elseif strcmp(CHANSPEC,'w')
             datenm = fn2datenum(fn);
         end
%    
        fvalsstr(run_count).fn = fn;    
        fvalsstr(run_count).datenm = datenm;
        fvalsstr(run_count).ons = syllons; %in ms, onset of each syllable in run
        fvalsstr(run_count).off = sylloffs;% in ms, offset of each syllable in run
        fvalsstr(run_count).runlength = runlength(i); %number of syllables in run
        fvalsstr(run_count).runduration = runduration; %in ms of run
        fvalsstr(run_count).sylldurations = sylloffs - syllons; %duration of each syllable in run
        fvalsstr(run_count).syllgaps = syllons(2:end) - sylloffs(1:end-1); %gaps between each adjacent syllable in run
        fvalsstr(run_count).smtmp = smtemp; %unfiltered amp env of repeat run
        fvalsstr(run_count).pitchest = pitchest; %pitch estimate for each syllable in repeat run 
        fvalsstr(run_count).ent = we;%wiener entropy for each syllable in repeat run
        fvalsstr(run_count).ind = pp(i);%start index for run in the song
        fvalsstr(run_count).amp = amp; %volume for each syllable in run computed by taking average of smooth, rectified waveform
        fvalsstr(run_count).sm = sm;%smoot, rectified filtered amp env of repeat run
    end
end

    
    