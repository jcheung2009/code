function motifinfo = jc_findmotif(batch,motif,syllables,fvalbnd,timeshifts,varseq,jitter,CHANSPEC)
%syllables = {'a','b','c'}
%fvalbnds = {[fvalbnd for syllable A], [fvalbnd for syllable C],...}
%timeshifts = {timeshift for A, timeshift for B, timeshift for C}
%if using a variable motif, motif should be for regexp ( ex: 'j[abc]+')
%varseq = 'y' or 'n', jitter = 'y' or 'n'
%** MUST CHECK REGULAR EXPRESSION MATCHES ONSET AND OFFSET
%CHANSPEC = 'obs0';
% varseq = input('motif is variable (y/n):','s');
% jitter = input('Were syllables manually edited?:','s');

if varseq ~= 'y'
    for i = 1:length(syllables)
        k = strfind(motif,syllables{i});
        syllablepositions{i} = k(1);
    end 
end
    
ff = load_batchf(batch);
motif_cnt = 0;
for i = 1:length(ff)
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
     %load rec file
    rd = readrecf(fn);
     %load raw song data
    [pthstr,tnm,ext] = fileparts(fn);
    if (strcmp(CHANSPEC,'w'))
            [dat,fs] = audioread(fn);
    elseif (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,CHANSPEC);
    else
        [dat,fs]=evsoundin('',fn,CHANSPEC);
    end
    if (isempty(dat))
        disp(['hey no data!']);
        continue;
    end
    
    %find motifs in bout
    if varseq == 'y'
        [p pend] = regexp(labels,motif);
        %pend = pend-1;%change according to regular expressing you're using
        motiflength = pend-p+1;
    else
        p = strfind(labels,motif);%start index for each motif
    end
    

        if jitter == 'y'
            %segment each syllable in motif separately and changes the
            %onsets/offsets variables 
            for z = 1:length(p)
                if varseq == 'y'
                    for v = 1:motiflength(z)
                        onsamp = floor(onsets(p(z)+v-1)*1e-3*fs)-256;
                        offsamp = ceil(offsets(p(z)+v-1)*1e-3*fs)+256;
                        smtemp = dat(onsamp:offsamp);
                        sm = evsmooth(smtemp,fs);
                        sm = log(sm);
                        sm = sm-min(sm);
                        sm = sm./max(sm);
                        abovethresh = find(sm>=0.3);
                        sm_ons = abovethresh(1);
                        sm_offs = abovethresh(end);
                        onsamp = onsamp+sm_ons;
                        offsamp = onsamp+sm_offs;
                        onsets(p(z)+v-1) = (onsamp/fs)*1e3;
                        offsets(p(z)+v-1) = (offsamp/fs)*1e3;
                    end
                else
                    for v = 1:length(motif)
                        onsamp = floor(onsets(p(z)+v-1)*1e-3*fs)-256;
                        offsamp = ceil(offsets(p(z)+v-1)*1e-3*fs)+256;
                        smtemp = dat(onsamp:offsamp);
                        sm = evsmooth(smtemp,fs);
                        sm = log(sm);
                        sm = sm-min(sm);
                        sm = sm./max(sm);
                        abovethresh = find(sm>=0.3);
                        sm_ons = abovethresh(1);
                        sm_offs = abovethresh(end);
                        onsamp = onsamp+sm_ons;
                        offsamp = onsamp+sm_offs;
                        onsets(p(z)+v-1) = (onsamp/fs)*1e3;
                        offsets(p(z)+v-1) = (offsamp/fs)*1e3;%in ms;
                    end
                end
            end
        end
    
    for ii = 1:length(p)
        if varseq=='y'
            ton = onsets(p(ii));toff=offsets(p(ii)+motiflength(ii)-1);
        else
            ton = onsets(p(ii)); toff = offsets(p(ii)+length(motif)-1);
        end
        onsamp = ceil((ton*1e-3)*fs);
        offsamp = ceil((toff*1e-3)*fs);
        
        if offsamp + 512 > length(dat)
            offsamp = length(dat);
        else
            offsamp = offsamp+512;%buffer by 16 ms
        end
        
        if onsamp - 512 < 1
            onsamp = 1;
        else
            onsamp = onsamp-512;%buffer by 16 ms
        end

        smtemp = dat(onsamp:offsamp);%amplitude envelope of motif
        sm = evsmooth(smtemp,fs,'','','',5);%smoothed amplitude envelop
        sm2 = log(sm);%to better see amplitude envelop and to better segment
        sm2 = sm2-min(sm2);
        sm2 = sm2./max(sm2);
        
        [c lag] = xcorr(sm2,'coeff');
        c = c(ceil(length(lag)/2):end);
        lag = lag(ceil(length(lag)/2):end);
        %peakdistance = 0.05*fs; %50 ms 
        [pks locs] = findpeaks(c,'minpeakwidth',256);
        if isempty(locs)%when number of syllables in motif < 4
            firstpeakdistance = NaN;
        else
            firstpeakdistance = locs(1)/fs;%average time in seconds between adjacent syllables from autocorr
        end
        
        if jitter == 'n'
            minint = 3;%gap
            mindur = 20;%syllable
            thresholdforsegmentation = {0.5,minint,mindur};%{graythresh(sm2),minint,mindur};%otsu's method
            [ons offs] = SegmentNotes(sm2,fs,thresholdforsegmentation{2},...
                thresholdforsegmentation{3},thresholdforsegmentation{1});
            disp([num2str(length(ons)),' syllables detected']);
            if varseq=='y'
                if length(ons) ~= motiflength(ii)
                    figure;hold on;
                end    
                while length(ons) ~= motiflength(ii)
                    clf
                     plot(sm2,'k');hold on;plot([floor(ons(1)*fs) ceil(offs(end)*fs)],...
                    [thresholdforsegmentation{1} thresholdforsegmentation{1}],'r');
                    disp([num2str(length(ons)),' syllables detected']);
                    accept_or_not = input('accept segmentation? (y/n):','s');
                    if accept_or_not == 'y'
                        break
                    else
                        thresholdforsegmentation = input('try new {thresholdhold,minint,mindur}:');
                        [ons offs] = SegmentNotes(sm2,fs,thresholdforsegmentation{2},...
                            thresholdforsegmentation{3},thresholdforsegmentation{1});
                    end 
                end
            else
%                 %uncomment this section if want to see segmentation
%                 if length(ons) ~= length(motif)
%                     figure;hold on;
%                 end
%                 while length(ons) ~= length(motif) 
%                     clf
%                     plot(sm2,'k');hold on;
%                     plot([floor(ons(1)*fs) ceil(offs(end)*fs)],...
%                         [thresholdforsegmentation{1} thresholdforsegmentation{1}],'r');
%                         plot([floor(ons*fs) ceil(offs*fs)],[thresholdforsegmentation{1} thresholdforsegmentation{1}],'r');hold on;
%                     accept_or_not = input('accept segmentation? (y/n):','s');
%                     if accept_or_not == 'y'
%                         break
%                     else
%                         thresholdforsegmentation = input('try new {thresholdhold,minint,mindur}:');
%                             [ons offs] = SegmentNotes(sm2,fs,thresholdforsegmentation{2},...
%                                 thresholdforsegmentation{3},thresholdforsegmentation{1});
%                             disp([num2str(length(ons)),' syllables detected']);
%                     end
%                 end
%                 if length(ons) ~= length(motif)
%                     continue
%                 end
                %%
            end
        else
            if varseq == 'y'
                ons = floor(onsets(p(ii):p(ii)+motiflength(ii)-1)*1e-3*fs);
                ons = ons-onsamp;
                offs = ceil(offsets(p(ii):p(ii)+motiflength(ii)-1)*1e-3*fs);
                offs = offs-onsamp;
                ons = ons/fs;%in seconds
                offs = offs/fs;%in seconds
            else
                ons = floor(onsets(p(ii):p(ii)+length(motif)-1)*1e-3*fs);
                ons = ons-onsamp;
                offs = ceil(offsets(p(ii):p(ii)+length(motif)-1)*1e-3*fs);
                offs = offs-onsamp;
                ons = ons/fs;%in seconds
                offs = offs/fs;%in seconds
            end
        end
        
        if length(ons) ~= length(motif)
            continue
        end
        if length(ons) < length(syllablepositions) 
            continue
        end
        syllabledurations = offs-ons;%in seconds
        gapdurations = ons(2:end)-offs(1:end-1);
        motifduration = offs(end)-ons(1); 
        
       %pitch,entropy,volume measurements for specified syllables
      
       spNFFT = 512;%16 ms window to compute whole syllable spectrogram for entropy
       overlap = spNFFT-2;
       t = -spNFFT/2+1:spNFFT/2;
       sigma=(1/1000)*fs;
       w=exp(-(t/sigma).^2);
       USEFIT = 1;
       
       if varseq == 'y'
           for r = 1:length(syllables)
                syllablepositions{r} = strfind(labels(p:pend-1),syllables{r});
           end
       end
       
       pitchestimates = [];
       volumeestimates = [];
       entropyestimates = [];
       for syllind = 1:length(syllablepositions)
           pitchestimates(syllind) = NaN;
           volumeestimates(syllind) = NaN;
           entropyestimates(syllind) = NaN;
           
           if ceil(offs(syllind)*fs) <= length(smtemp)
               filtsong = bandpass(smtemp,fs,300,10000,'hanningffir'); 
               if floor(offs(syllablepositions{syllind})*fs) > length(filtsong)
                   offs(syllablepositions{syllind}) = (length(filtsong)-129)/fs;
               end
               [sp f tm pxx] = spectrogram(filtsong(ceil(ons(syllablepositions{syllind})*fs):floor(offs(syllablepositions{syllind})*fs)),w,overlap,spNFFT,fs);
               pc = [];
               for m = 1:size(sp,2)
                   fdat = abs(sp(:,m));
                        mxtmpvec = zeros([1,size(fvalbnd{syllind},1)]);
                        for kk = 1:size(fvalbnd{syllind},1)
                            tmpinds = find((f>=fvalbnd{syllind}(kk,1))&(f<=fvalbnd{syllind}(kk,2)));
                            NPNTS = 10;
                            [tmp pf] = max(fdat(tmpinds));
                            pf = pf+tmpinds(1)-1;
                            if (USEFIT==1)%weighted average 
                                tmpxv=pf + [-NPNTS:NPNTS];
                                tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(f))));
                                mxtmpvec(kk)=f(tmpxv)'*fdat(tmpxv);
                                mxtmpvec(kk)=mxtmpvec(kk)./sum(fdat(tmpxv));
                            else
                                mxtmpvec(kk) = f(pf);
                            end
                        end
                        pc = cat(1,pc,mean(diff([0,mxtmpvec])));
               end
                %pitch
                pc = [tm' pc];
                if length(timeshifts{syllind})==1
                    ti1 = find(tm<=timeshifts{syllind});
                    ti1 = ti1(end);
                    pitchestimates(syllind) = pc(ti1,2);%pitch estimate at timeshift
                elseif length(timeshifts{syllind}) == 2
                    ti1 = find(tm>=timeshifts{syllind}(1)&tm<=timeshifts{syllind}(2));
                    pitchestimates(syllind) = mean(pc(ti1,2));%pitch estimate at timeshift
                end
                
                %Spectral temporal entropy
                indf = find(f>=300 & f <= 10000);
                pxx = pxx(indf,:);
                pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));
                entropyestimates(syllind) = -sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:)));
                
                %volume
                volumeestimates(syllind)=mean(filtsong(ceil(ons(syllablepositions{syllind})*fs):ceil(offs(syllablepositions{syllind})*fs)-1).^2);
           else
               continue
           end        
       end
       
       
      %extract datenum from rec file, add syllable ton in seconds
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
             %datenm = fn2datenum(fn);
             formatIn = 'yyyymmddHHMMSS';
             datenm = datenum(datevec(fn(end-17:end-4),formatIn));
         end
         
       motif_cnt = motif_cnt+1;
       motifinfo(motif_cnt).filename = fn;
       motifinfo(motif_cnt).datenm = datenm;
       motifinfo(motif_cnt).acorr = {lag c};
       motifinfo(motif_cnt).firstpeakdistance= firstpeakdistance;
       motifinfo(motif_cnt).sm = sm;%smoothed motif amp env
       motifinfo(motif_cnt).logsm = sm2;%log smooth
       motifinfo(motif_cnt).durations = syllabledurations;
       motifinfo(motif_cnt).gaps = gapdurations;
       motifinfo(motif_cnt).motifdur = motifduration;
       motifinfo(motif_cnt).syllpitch = pitchestimates;
       motifinfo(motif_cnt).syllvol = volumeestimates;
       motifinfo(motif_cnt).syllent = entropyestimates;
       motifinfo(motif_cnt).boutind = ii;%motif number in song file
       
    end
end

    
       
        
        
        
        
        
        
        
        
        