function motifinfo = jc_findmotifs(batch,params,dtwtemplate,CHANSPEC,fs)
%this function measures spectrotemporal properties of target motif in every
%song file. params is specified by config file 

motif = params.motif;
measurespecs = params.measurespecs;
syllables = params.syllables;
timeshifts = params.timeshifts;
fvalbnd = params.fvalbnd;
check_segmentation = params.check_segmentation;
check_peakfind = params.check_peakfind;
timeband = params.timeband;
nbuffer = floor(0.016*fs);%buffer by 16 ms

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

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
if check_segmentation == 'y' | check_peakfind == 'y'
    h = figure;hold on;
end

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
        smtemp = dat(onsamp:offsamp);
        filtsong=bandpass(smtemp,fs,1000,10000,'hanningffir');
        sm = evsmooth(smtemp,fs,'','','',5);
        
        %determine if catch or trig 
       [TRIG ISCATCH] = trig_or_notrig(rd,ton,toff);
       
       %use autocorrelation to estimate average syll-syll duration
        if strcmp(params.acorrsm,'no log')
            sm2 = sm;
        else
            sm2 = log(sm);
        end
        sm2 = sm2-min(sm2);              
        sm2 = sm2./max(sm2);
        
        [firstpeakdistance lag c locs pks] = find_acorr_peak(sm2,fs,timeband);
        if check_peakfind == 'y'
            clf(h);hold on;
            plot(lag/fs,c,'k',locs/fs,pks,'or');hold on;
            pause
        end

        %determine syllable onsets and offsets by dtw segmentation
        [ons offs] = dtw_segment(smtemp,dtwtemplate,fs);
        if check_segmentation == 'y'
            clf(h);hold on;
            [sp2 f2 tm2] = spectrogram(filtsong,w,overlap,NFFT,fs);
            indf = find(f2>1000 & f2 <10000);
            f2 = f2(indf);
            sp2 = abs(sp2(indf,:));
            imagesc(tm2,f2,log(abs(sp2)));axis('xy');
            plot([ons ons]',[1000 10000],'r');hold on;
            plot([offs offs]',[1000 10000],'r');hold on;
            pause;
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

       %spectral measurements for target syllables
       if measurespecs == 'y'
           numsylls = sum(cellfun(@length,syllablepositions));
           pitchestimates = NaN(numsylls,1);
           volumeestimates = NaN(numsylls,1);
           entropyestimates = NaN(numsylls,1);
           for syllind = 1:length(syllablepositions)
               for syllposind = 1:length(syllablepositions{syllind})
                   onsamp_syll = floor(ons(syllablepositions{syllind}(syllposind))*fs);
                   offsamp_syll = loor(offs(syllablepositions{syllind}(syllposind))*fs);
                   if offsamp_syll 
                   if ceil(offs(syllind)*fs) <= length(smtemp)
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

    
       
        
        
        
        
        
        
        
        
        