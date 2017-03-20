function motifinfo = jc_findmotif(batch,params)
%this function measures spectrotemporal properties of target motif in every
%song file. params is specified by config file 

motif = params.findmotif.motif;
jitter = params.findmotif.jitter;
measurespecs = params.findmotif.measurespecs;
syllables = params.findmotif.syllables;
timeshifts = params.findmotif.timeshifts;
fvalbnd = params.findmotif.fvalbnd;
if measurespecs == 'y'
    for i = 1:length(syllables)
        k = strfind(motif,syllables{i});
        syllablepositions{i} = k;
    end 
end
if ~isempty(params.findmotif.segmentation)
    minint = params.findmotif.segmentation{1};
    mindur = params.findmotif.segmentation{2};
    thresh = params.findmotif.segmentation{3};
else
    minint = 3;
    mindur = 20;
    thresh = 0.3;
end
check_segmentation = params.findmotif.check_segmentation;

ff = load_batchf(batch);
motif_cnt = 0;
motifinfo = struct();
for i = 1:length(ff)
    %load song data
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
    rd = readrecf(fn);
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
    p = strfind(labels,motif);
    if isempty(p)
        continue
    end

    %get smoothed amp waveform of motif 
    for ii = 1:length(p)
        ton = onsets(p(ii));
        toff=offsets(p(ii)+length(motif)-1);
        onsamp = ceil((ton*1e-3)*fs);
        offsamp = ceil((toff*1e-3)*fs);
        nbuffer = 0.016*fs;%buffer by 16 ms
        if offsamp+nbuffer > length(dat)
            offsamp = length(dat);
        else
            offsamp = offsamp+nbuffer;
        end
        if onsamp-nbuffer < 1
            onsamp = 1;
        else
            onsamp = onsamp-nbuffer;
        end
        smtemp = dat(onsamp:offsamp);%amplitude envelope of motif
        sm = evsmooth(smtemp,fs,'','','',5);%smoothed amplitude envelop
        
        %determine if catch or trig (TRIG=1,ISCATCH=1/0 for detect/hit or
        %catch; TRIG=1,ISCATCH=-1 for detect/hit; TRIG=-1,ISCATCH=-1 for
        %escape; TRIG=0,ISCATCH=-1 for escape)
       if (isfield(rd,'ttimes'))
            trigindtmp=find((rd.ttimes>=ton)&(rd.ttimes<toff));%find trigger time for syllable
            if (length(trigindtmp)>0)%if exist trigger time for syllable...
                TRIG=rd.ttimes(trigindtmp);%hits
                if (isfield(rd,'catch'))
                    ISCATCH=rd.catch(trigindtmp);%determine whether trigger time was hit or catch
                else
                    ISCATCH=-1;%hits
                end
            else
                TRIG=-1;%escapes and misses
                ISCATCH=-1;
            end
       else
            TRIG=0;%escapes and misses
            ISCATCH=-1;
       end
       
       %use autocorrelation to estimate average syll-syll duration
        if params.findmotif.acorrsm = 'no log'
            sm2 = sm;
        else
            sm2 = log(sm);
        end
        sm2 = sm2-min(sm2);
        sm2 = sm2./max(sm2);
        [c lag] = xcorr(sm2,'coeff');
        c = c(ceil(length(lag)/2):end);
        lag = lag(ceil(length(lag)/2):end);
        %peakdistance = 0.05*fs; %50 ms 
        [pks locs] = findpeaks(c,'minpeakwidth',256);
        if isempty(locs)
            firstpeakdistance = NaN;
        else
            firstpeakdistance = locs(1)/fs;%average time in seconds between adjacent syllables from autocorr
        end
        
        %determine syllable onsets and offsets: segment each syllable in motif separately 
        if jitter == 'y'
            nbuffer = 0.008*fs;%buffer by 8 ms
            ons = [];offs = [];
            for n = 1:length(motif)
                onsamp_syll = floor(onsets(p(ii)+n-1)*1e-3*fs)-nbuffer;
                offsamp_syll = ceil(offsets(p(ii)+n-1)*1e-3*fs)+nbuffer;
                smtemp_syll = dat(onsamp_syll:offsamp_syll);
                sm_syll = evsmooth(smtemp_syll,fs);
                sm_syll = log(sm_syll);
                sm_syll = sm-min(sm_syll);
                sm_syll = sm_syll./max(sm_syll);
                abovethresh = find(sm_syll>=thresh);
                sm_ons = abovethresh(1);
                sm_offs = abovethresh(end);
                onsamp_syll = (onsamp_syll+sm_ons)-onsamp;
                offsamp_syll = (onsamp_syll+sm_offs)-onsamp;
                ons = [ons;onsamp_syll/fs];%seconds into smtmp 
                offs = [offs;offsamp_syll/fs];
            end
        else %determine onset/offset: segment log transformed and normalized sm 
            sm2 = log(sm);
            [ons offs] = SegmentNotes(sm2,fs,minint,mindur,thresh);
            disp([num2str(length(ons)),' syllables detected']);
            if check_segmentation == 'y'
                h = figure;hold on;
                if length(ons) ~= length(motif)
                    while length(ons) ~= length(motif) 
                        clf(h);
                        plot(sm2,'k');hold on;
                        plot([floor(ons*fs) ceil(offs*fs)],[thresh thresh],'r');hold on;
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
                end
            end
        end
        
        if length(ons) ~= length(motif)
            syllabledurations = [];
            gapdurations = [];
            motifduration = offs(end)-ons(1);
            pitchestimates = [];
            volumeestimates = [];
            entropyestimates = [];
        else
            syllabledurations = offs-ons;%in seconds
            gapdurations = ons(2:end)-offs(1:end-1);
            motifduration = offs(end)-ons(1); 
        end

       %pitch,entropy,volume measurements for specified syllables
       if measurespecs == 'y'
           spNFFT = 0.016*fs;%16 ms window to compute whole syllable spectrogram for entropy
           overlap = spNFFT-2;
           t = -spNFFT/2+1:spNFFT/2;
           sigma=(1/1000)*fs;
           w=exp(-(t/sigma).^2);
           USEFIT = 1;
           numsylls = sum(cellfun(@length,syllablepositions));
           pitchestimates = NaN(numsylls,1);
           volumeestimates = NaN(numsylls,1);
           entropyestimates = NaN(numsylls,1);
           for syllind = 1:length(syllablepositions)
               for syllposind = 1:length(syllablepositions{syllind})
                   if ceil(offs(syllind)*fs) <= length(smtemp)
                       filtsong = bandpass(smtemp,fs,300,10000,'hanningffir'); 
                       if floor(offs(syllablepositions{syllind}(syllposind))*fs) > length(filtsong)
                           offs(syllablepositions{syllind}(syllposind)) = (length(filtsong)-129)/fs;
                       end
                       [sp f tm pxx] = spectrogram(filtsong(floor(ons(syllablepositions{syllind}(syllposind))*fs):...
                           ceil(offs(syllablepositions{syllind}(syllposind))*fs)),w,overlap,spNFFT,fs);
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
                        ti1 = find(tm>=timeshifts{syllind}(1)&tm<=timeshifts{syllind}(2));
                        pitchestimates(syllind) = mean(pc(ti1,2));%pitch estimate at timeshift
  
                        %Spectral temporal entropy
                        indf = find(f>=300 & f <= 10000);
                        pxx = pxx(indf,:);
                        pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));
                        entropyestimates(syllind) = -sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:)));

                        %volume
                        volumeestimates(syllind)=mean(filtsong(floor(ons(syllablepositions{syllind}(syllposind))*fs):...
                            ceil(offs(syllablepositions{syllind}(syllposind))*fs)-1).^2);
                 else
                        continue
                 end
               end
           end
        else
           pitchestimates = [];
           volumeestimates = [];
           entropyestimates = [];
       end
          
      %extract datenum from rec file, add syllable ton in seconds
      if (strcmp(CHANSPEC,'obs0'))
         if isfield(rd,'header')
            key = 'created:';
            ind = strfind(rd.header{1},key);
            tmstamp = rd.header{1}(ind+length(key):end);
            try
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
                ind2 = strfind(rd.header{5},'=');
                filelength = sscanf(rd.header{5}(ind2 + 1:end),'%g');%duration of file

                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of filefiltsong
                datenm = addtodate(tm_st, round(ton), 'millisecond');%add time to onset of syllable
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
        motifinfo(motif_cnt).TRIG = TRIG;
        motifinfo(motif_cnt).CATCH=ISCATCH;

       
    end
end

    
       
        
        
        
        
        
        
        
        
        