function motifinfo = jc_findmotifs_dtw(batch,params,dtwtemplate,CHANSPEC)
%this function measures spectrotemporal properties of target motif in every
%song file. params is specified by config file. gap and syllable
%measurements done by dynamic time warp to template spectrogram

%% setting parameters
motif = params.motif;
jitter = params.jitter;
fs = params.fs;
measurespecs = params.measurespecs;
syllables = params.syllables;
timeshifts = params.timeshifts;
fvalbnd = params.fvalbnd;
if measurespecs == 'y'
    for i = 1:length(syllables)
        k = strfind(motif,syllables{i});
        syllablepositions{i} = k;
    end 
end
if ~isempty(params.segmentation)
    minint = params.segmentation{1};
    mindur = params.segmentation{2};
    thresh = params.segmentation{3};
else
    minint = 3;
    mindur = 20;
    thresh = 0.3;
end
check_segmentation = params.check_segmentation;
check_peakfind = params.check_peakfind;
if check_segmentation == 'y' | check_peakfind == 'y'
    h = figure;hold on;
end
timeband = params.timeband;

%params for spectrogram
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%template measurements
if ~isempty(dtwtemplate)
    temp = abs(dtwtemplate.filtsong);
    temp_ons=dtwtemplate.ons;
    temp_offs=dtwtemplate.offs;
    [sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
    indf = find(f>1000 & f<10000);
    temp = abs(sp(indf,:));
    temp = temp./sum(temp,2);
else
    dtwtemplate = make_dtw_temp(batch,params,CHANSPEC);
    temp = abs(dtwtemplate.filtsong);
    temp_ons=dtwtemplate.ons;
    temp_offs=dtwtemplate.offs;
    [sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
    indf = find(f>1000 & f<10000);
    temp = abs(sp(indf,:));
    temp = temp./sum(temp,2);
end
%%
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
        nbuffer = floor(0.016*fs);%buffer by 16 ms
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
        filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
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
        if strcmp(params.acorrsm,'no log')
            sm2 = sm;
        else
            sm2 = log(sm);
        end
        sm2 = sm2-min(sm2);              
        sm2 = sm2./max(sm2);
        [c lag] = xcorr(sm2,'coeff');
        c = c(ceil(length(lag)/2):end);
        lag = lag(ceil(length(lag)/2):end);
        [pks locs] = findpeaks(c,'minpeakwidth',256);
        if check_peakfind == 'y'
            clf(h);hold on;
            plot(lag/fs,c,'k',locs/fs,pks,'or');hold on;
            pause
        end
        if isempty(locs)
            firstpeakdistance = NaN;
        else
            if ~isempty(timeband)
                pkind = find(locs > timeband(1)*fs & locs < timeband(2)*fs);
                if length(pkind) == 1
                    firstpeakdistance = locs(pkind)/fs;
                else
                    firstpeakdistance = NaN;
                end
            else
                firstpeakdistance = locs(1)/fs;
            end
        end
        
        %dtw segmentation
        [sp f tm2] = spectrogram(filtsong,w,overlap,NFFT,fs);
        indf = find(f>1000 & f <10000);
        sm2 = abs(sp(indf,:));
        sm2 = sm2./sum(sm2,2);
        
        [dist ix iy] = dtw(temp,sm2);
        onind = [];offind = [];
        for m = 1:length(temp_ons)
            [~, onind(m)] = min(abs(temp_ons(m)-tm1));
            [~, offind(m)]=min(abs(temp_offs(m)-tm1));
        end
        ons = [];
        offs = [];
       for m = 1:length(onind)
            ind = find(ix==onind(m));
            ind = ind(ceil(length(ind)/2));
            ons = [ons;iy(ind)];
            ind = find(ix==offind(m));
            ind = ind(ceil(length(ind)/2));
            offs = [offs;iy(ind)];
       end
       ons = tm2(ons)';offs=tm2(offs)';

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
           spNFFT = floor(0.016*fs);%16 ms window to compute whole syllable spectrogram for entropy
           spoverlap = spNFFT-2;
           spt = -spNFFT/2+1:spNFFT/2;
           spsigma=(1/1000)*fs;
           spw=exp(-(spt/spsigma).^2);
           USEFIT = 1;
           numsylls = sum(cellfun(@length,syllablepositions));
           pitchestimates = NaN(numsylls,1);
           volumeestimates = NaN(numsylls,1);
           entropyestimates = NaN(numsylls,1);
           syllcnt = 1;
           for syllind = 1:length(syllablepositions)
               for syllposind = 1:length(syllablepositions{syllind})
                   if ceil(offs(syllind)*fs) <= length(smtemp)
                       filtsong = bandpass(smtemp,fs,300,10000,'hanningffir'); 
                       if floor(offs(syllablepositions{syllind}(syllposind))*fs) > length(filtsong)
                           offs(syllablepositions{syllind}(syllposind)) = (length(filtsong)-129)/fs;
                       end
                       [sp f tm pxx] = spectrogram(filtsong(floor(ons(syllablepositions{syllind}(syllposind))*fs):...
                           ceil(offs(syllablepositions{syllind}(syllposind))*fs)),spw,spoverlap,spNFFT,fs);
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
                        pitchestimates(syllcnt) = mean(pc(ti1,2));%pitch estimate at timeshift
  
                        %Spectral temporal entropy
                        indf = find(f>=300 & f <= 10000);
                        pxx = pxx(indf,:);
                        pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));
                        entropyestimates(syllcnt) = -sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:)));

                        %volume
                        volumeestimates(syllcnt)=mean(filtsong(floor(ons(syllablepositions{syllind}(syllposind))*fs):...
                            ceil(offs(syllablepositions{syllind}(syllposind))*fs)-1).^2);
                        
                        syllcnt=syllcnt+1;
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
         else sm
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
        motifinfo(motif_cnt).smtemp = smtemp;%raw amplitude waveform
        motifinfo(motif_cnt).sm = sm;%smoothed motif amp env
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

    
       
        
        
        
        
        
        
        
        
        