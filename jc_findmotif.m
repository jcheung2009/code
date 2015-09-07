function motifinfo = jc_findmotif(batch,motif,syllables,fvalbnd,timeshifts)
%syllables = {'a','b','c'}
%fvalbnds = {[fvalbnd for syllable A], [fvalbnd for syllable C],...}
%timeshifts = {timeshift for A, timeshift for B, timeshift for C}
%if using a variable motif, motif should be for regexp ( ex: 'j[abc]+')
%** MUST CHECK REGULAR EXPRESSION MATCHES ONSET AND OFFSET
CHANSPEC = 'obs0';
varseq = input('motif is variable (y/n):','s');
jitter = input('Were syllables manually edited?:','s');

if varseq ~= 'y'
    for i = 1:length(syllables)
        syllablepositions{i} = strfind(motif,syllables{i});
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
        sm = evsmooth(smtemp,fs);%smoothed amplitude envelop
        sm2 = log(sm);%to better see amplitude envelop and to better segment
        sm2 = sm2-min(sm2);
        sm2 = sm2./max(sm2);
        
        [c lag] = xcorr(sm2,'coeff');
        c = c(ceil(length(lag)/2):end);
        lag = lag(ceil(length(lag)/2):end);
        %peakdistance = 0.05*fs; %50 ms 
        [pks locs] = findpeaks(c);
        if isempty(locs)%when number of syllables in motif < 4
            firstpeakdistance = [];
        else
            firstpeakdistance = locs(1)/fs;%average time in seconds between adjacent syllables from autocorr
        end
        
        if jitter == 'n'
            minint = 15;%gap
            mindur = 30;%syllable
            thresholdforsegmentation = {0.3,minint,mindur};%{graythresh(sm2),minint,mindur};%otsu's method
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
                if length(ons) ~= length(motif)
                    figure;hold on;
                end
                while length(ons) ~= length(motif) 
                    clf
                    plot(sm2,'k');hold on;plot([floor(ons(1)*fs) ceil(offs(end)*fs)],...
                        [thresholdforsegmentation{1} thresholdforsegmentation{1}],'r');
                    accept_or_not = input('accept segmentation? (y/n):','s');
                    if accept_or_not == 'y'
                        break
                    else
                        thresholdforsegmentation = input('try new {thresholdhold,minint,mindur}:');
                            [ons offs] = SegmentNotes(sm2,fs,thresholdforsegmentation{2},...
                                thresholdforsegmentation{3},thresholdforsegmentation{1});
                            disp([num2str(length(ons)),' syllables detected']);
                    end
                end
                if length(ons) ~= length(motif)
                    continue
                end
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
        
        if length(ons) > length(motif)
            continue
        end
        if length(ons) < length(syllablepositions) 
            continue
        end
        syllabledurations = offs-ons;%in seconds
        gapdurations = ons(2:end)-offs(1:end-1);
        motifduration = offs(end)-ons(1); 
        
       %pitch,entropy,volume measurements for specified syllables
       NFFT = 256;%8 ms window to compute fft for pitch measurement
       spNFFT = 512;%16 ms window to compute whole syllable spectrogram for entropy
       overlap = spNFFT-2;
       t = -spNFFT/2+1:spNFFT/2;
       sigma=(1/1000)*fs;
       w=exp(-(t/sigma).^2);
       
       if varseq == 'y'
           for r = 1:length(syllables)
                syllablepositions{r} = strfind(labels(p:pend-1),syllables{r});
           end
       end
       pitchestimates = [];
       volumeestimates = [];
       entropyestimates = [];
       for syllind = 1:length(syllablepositions)
           ti1 = ceil((timeshifts{syllind}+ons(syllablepositions{syllind}))*fs);
           if ti1+NFFT > length(smtemp)
               pitchestimates(syllind) = NaN;
               volumeestimates(syllind) = NaN;
               entropyestimates(syllind) = NaN;
           end
           filtsong = bandpass(smtemp,fs,300,15000,'hanningffir');
           if ti1+NFFT-1 > length(filtsong)
               continue
           end
           dattmp = filtsong([ti1:(ti1+NFFT-1)]);
           fdattmp = abs(fft(dattmp.*hamming(length(dattmp))));
           fvals =[0:length(fdattmp)/2]*fs/length(fdattmp);
           fdattmp = fdattmp(1:end/2);
           mxtmpvec = zeros([1,size(fvalbnd{syllind},1)]);
           for kk = 1:size(fvalbnd{syllind},1)
               tmpinds = find((fvals>=fvalbnd{syllind}(kk,1)&fvals<=fvalbnd{syllind}(kk,2)));
               npnts = 10;
               [tmp,pf] = max(fdattmp(tmpinds));
               pf=pf+tmpinds(1)-1;
               tmpxv =pf+[-npnts:npnts];
               tmpxv = tmpxv(find((tmpxv>0)&(tmpxv<=length(fvals))));
               mxtmpvec(kk)=fvals(tmpxv)*fdattmp(tmpxv);
               mxtmpvec(kk)=mxtmpvec(kk)./sum(fdattmp(tmpxv));
               pitchestimates(syllind) = mean(diff([0,mxtmpvec]));
           end
           if ceil(offs(syllind)*fs) <= length(filtsong)
                volumeestimates(syllind)=mean(filtsong(ceil(ons(syllind)*fs):ceil(offs(syllind)*fs)).^2);
                [sp f t pxx] = spectrogram(filtsong(ceil(ons(syllind)*fs):ceil(offs(syllind)*fs)),w,overlap,spNFFT,fs);
           else
               volumeestimates(syllind)=mean(filtsong(ceil(ons(syllind)*fs):ceil(offs(syllind)*fs)-1).^2);
               [sp f t pxx] = spectrogram(filtsong(ceil(ons(syllind)*fs):ceil(offs(syllind)*fs)-1),w,overlap,spNFFT,fs);
           end
           
            pxx = bsxfun(@rdivide,pxx,sum(pxx));
            spent = [];%spectral entropy
            for qq = 1:size(pxx,2)
                spent = [spent; -sum(pxx(:,qq).*log(pxx(:,qq)))];
            end
          
           entropyestimates(syllind)=mean(spent);
           
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
             datenm = fn2datenum(fn);
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

    
       
        
        
        
        
        
        
        
        
        