function motifsegment = amp_vs_phase_segmentation(batch,params,CHANSPEC);
%this function extracts the onset/offset of syllables within target motif
%based on amplitude or phase segmentation (for testing)

motif = params.motif;
timeband = params.timeband;
if ~isempty(params.segmentation)
    minint = params.segmentation{1};
    mindur = params.segmentation{2};
    thresh = params.segmentation{3};
else
    minint = 3;
    mindur = 20;
    thresh = 0.3;
end

ff = load_batchf(batch);
motif_cnt = 0;
motifsegment = struct();
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
        sm = evsmooth(smtemp,fs,'','','',10);%smoothed amplitude envelop
        
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
        if strcmp(params.check_peakfind, 'y')
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
        
        %amplitude segmentation
        sm2 = log(sm);
        sm2 = sm2-min(sm2);
        sm2 = sm2./max(sm2);
        [ons offs] = SegmentNotes(sm2,fs,minint,mindur,thresh);
        disp([num2str(length(ons)),' syllables detected']);
        
         if length(ons) ~= length(motif)
            sylldurations = [];
            gapdurations = [];
            motifduration = offs(end)-ons(1);
         else
            sylldurations = offs-ons;%in seconds
            gapdurations = ons(2:end)-offs(1:end-1);
            motifduration = offs(end)-ons(1); 
         end
         
         %phase segmentation
         sm2 = log(sm);
         sm2 = (sm2-mean(sm2))/std(sm2);
         if ~isempty(params.phshft)
             sm2 = sm2+params.phshft;
         end
         ph = angle(hilbert(sm2));
         syllsegments = (ph>=-0.5*pi & ph<0.5*pi);
         [ons offs] = SegmentNotes(syllsegments,fs,minint,mindur,0.5);
         if length(ons) ~= length(motif)
             sylldurations2 = [];
             gapdurations2 = [];
             motifduration2 = NaN;
         else
             sylldurations2 = offs-ons;
             gapdurations2 = ons(2:end)-offs(1:end-1);
             motifduration2 = offs(end)-ons(1); 
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
         datenm = wavefn2datenum(fn);
     end
         
     
     motif_cnt = motif_cnt+1;
     motifsegment(motif_cnt).filename = fn;
     motifsegment(motif_cnt).datenm = datenm;
     motifsegment(motif_cnt).sm = sm;
     motifsegment(motif_cnt).amp_durs = sylldurations;
     motifsegment(motif_cnt).amp_gaps = gapdurations;
     motifsegment(motif_cnt).ph_durs = sylldurations2;
     motifsegment(motif_cnt).ph_gaps = gapdurations2;
     motifsegment(motif_cnt).amp_motifdur = motifduration;
     motifsegment(motif_cnt).ph_motifdur = motifduration2;
     motifsegment(motif_cnt).firstpeakdistance = firstpeakdistance;
    end
    
end
        
        
        
        