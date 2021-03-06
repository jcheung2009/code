function fvalsstr = jc_findrepeat4(batch,note,prenote,fvalbnd,timeshift,NFFT, ...
    CHANSPEC,computespec)
%extract information for each instance of a repeat run and information for
%each syllable within those repeat runs
%note = repeating syllable, prenote = syllable that precedes the first
%repeat syllable
%timebins = [start time in syllable, end time in syllable] for computing
%pitch contour in seconds
%note can be in form of regular expression *BUT BE SURE TO CHECK INDICES
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
%computespec = input('compute spectral features?:','s');
%includes a time limit to identify repeat string lengths


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

fvalsstr=[];
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
    
    p = strfind(labels,note);
    if isempty(p)
        continue
    end
    runlength = [];
    onind = [p(1)];
    offind = [];
    cnt = 1;
    for i = 1:length(p)-1
        if (p(i+1) == p(i)+1) & (onsets(p(i+1))-offsets(p(i)))<=100
            cnt = cnt+1;
            if i == length(p)-1
                runlength = [runlength;cnt];
                offind = [offind;p(i+1)];
            end
        else
            runlength = [runlength; cnt];
            cnt = 1;
            offind = [offind;p(i)];
            onind = [onind;p(i+1)];
            if i == length(p)-1
                runlength = [runlength;cnt];
                offind = [offind;p(i+1)];
                onind = [onind;p(i+1)];
            end
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
        sm = evsmooth(smtemp,fs,'','','',5);
        sm = log(sm);%better for segmentation
        sm = sm-min(sm);
        sm = sm./max(sm);
        
        if runlength(i) >= 3
            [c lag] = xcorr(sm,'coeff');
            c = c(ceil(length(lag)/2):end);
            lag = lag(ceil(length(lag)/2):end);
            %peakdistance = 0.05*fs; %50 ms 
            [pks locs] = findpeaks(c,'minpeakwidth',256);
            if isempty(locs)%when number of syllables in motif < 4
                firstpeakdistance = NaN;
            else
                firstpeakdistance = locs(1)/fs;%average time in seconds between adjacent syllables from autocorr
            end
        else
            firstpeakdistance = NaN;
        end
        
        minint = 5;
        mindur = 20;
        thresholdforsegmentation = {0.3,minint,mindur};
        [ons offs] = SegmentNotes(sm,fs,thresholdforsegmentation{2},...
            thresholdforsegmentation{3},thresholdforsegmentation{1});
        disp([num2str(length(ons)),' syllables detected']);
        %% comment this part if don't want to see segmentation
        if length(ons) ~= runlength(i) | floor(ons(1)*fs) == 1
            figure;hold on;
        end
        
        while length(ons)~=runlength(i) | floor(ons(1)*fs) == 1
            clf
            plot(sm,'k');hold on;%plot([floor(ons(1)*fs) ceil(offs(end)*fs)],...
                %[thresholdforsegmentation{1} thresholdforsegmentation{1}],'r');
                plot([floor(ons*fs) ceil(offs*fs)],[thresholdforsegmentation{1} thresholdforsegmentation{1}],'r');hold on;
            disp([num2str(length(ons)),' syllables detected']);
            accept_or_not = input('accept segmentation? (y/n):','s');
            if accept_or_not=='y'
                break
            else
                thresholdforsegmentation=input('try new {threshold,minint,mindur}:');
                [ons offs] = SegmentNotes(sm,fs,thresholdforsegmentation{2},...
                    thresholdforsegmentation{3},thresholdforsegmentation{1});
            end
        end
        %%
       
        if length(ons) ~= runlength(i) | floor(ons(1)*fs) == 1
            sylldurations = NaN;
            gapdurations = NaN;
            pitchest = NaN;
            amp = NaN;
            we = NaN;
            pitchcontours_all_syllables = NaN;
            ons = NaN;
            offs = NaN;
            spent = NaN;
        else
                sylldurations = offs-ons;%in seconds
                gapdurations = ons(2:end)-offs(1:end-1);

                %pitch,volume, entropy measurement for each syllable in repeat
                if computespec == 'y'
                    pitchest = []; amp = [];spent = [];pitchcontours_all_syllables = cell(length(ons),1);
                    for ii = 1:length(ons) %for each syllable in repeat run
                        filtsong = bandpass(smtemp,fs,300,15000,'hanningffir');%band pass filter required for good entropy estimates
                        if ii == 1
                            if floor(ons(ii)*fs) <= 128
                                ons(ii) = 129/fs;
                            end
                            if ceil(offs(ii)*fs)+128 > length(filtsong)
                                offs(ii) = (length(filtsong)-129)/fs;
                            end
                            datsyll = filtsong(floor(ons(ii)*fs)-128:ceil(offs(ii)*fs)+128);
                        else
                            if ceil(offs(ii)*fs)+128 > length(filtsong)
                                offs(ii) = (length(filtsong)-129)/fs;
                            end
                            datsyll = filtsong(floor(ons(ii)*fs)-128:ceil(offs(ii)*fs)+128);
                            [corr lag] = xcorr(abs(filtsong(floor(ons(1)*fs):ceil(offs(1)*fs))),...
                                abs(datsyll));
                            [mx mxshft] = max(corr);
                            shft = lag(mxshft);
                            if shft > 0 %shift second signal to right
                                datsyll = [zeros(shft,1);datsyll];
                            elseif shft < 0 %shift second signal to left
                                datsyll = [datsyll(abs(shft)+1:end)];
                            end
                        end

                        %volume
                        amp = cat(1,amp,mean(datsyll.^2));

                        N = 512; %window size for spectrogram segments
                        overlap = N-2;
                        t=-N/2+1:N/2;
                        sigma=(1/1000)*fs;
                        w=exp(-(t/sigma).^2);%gaussian window for spectrogram
                        
                        if length(w) > length(datsyll)%syllable too short
                            pitchest = cat(1,pitchest,NaN);
                            pitchcontours_all_syllables{ii} = NaN;
                            spent = cat(1,spent,NaN);
                            continue
                        end
                            
                        [sp f tm pxx] = spectrogram(datsyll,w,overlap,N,fs);
                        %use weighted average of power and fft values from sp
                        pc = [];
                        for m = 1:size(sp,2)
                            fdat = abs(sp(:,m));
                            mxtmpvec = zeros([1,size(fvalbnd,1)]);
                            for kk = 1:size(fvalbnd,1)
                                tmpinds = find((f>=fvalbnd(kk,1))&(f<=fvalbnd(kk,2)));
                                NPNTS = 10;
                                [tmp pf] = max(fdat(tmpinds));
                                pf = pf+tmpinds(1)-1;
                                %weighted average
                                tmpxv=pf + [-NPNTS:NPNTS];
                                tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(f))));
                                mxtmpvec(kk)=f(tmpxv)'*fdat(tmpxv);
                                mxtmpvec(kk)=mxtmpvec(kk)./sum(fdat(tmpxv));
                         
                            end
                            pc = cat(1,pc,mean(diff([0,mxtmpvec])));
                        end
                        pitchcontours_all_syllables{ii} = pc;
                        if length(timeshift) == 1
                            ti1 = find(tm<=timeshift);
                            ti1 = ti1(end);
                            pitchest = cat(1,pitchest,pc(ti1));%pitch estimate at timeshift 
                        elseif length(timeshift) == 2
                            ti1 = find(tm>=timeshift(1) & tm<= timeshift(2));
                            pitchest = cat(1,pitchest,mean(pc(ti1)));
                        end

                         %Spectral temporal entropy
                        indf = find(f>=300 & f <= 10000);
                        pxx = pxx(indf,:);
                        pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));
                        spent = cat(1,spent,-sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:))));

  
                    end
                    maxpclength = max(cellfun(@length,pitchcontours_all_syllables));
                    pitchcontours_all_syllables = cell2mat(cellfun(@(x) [x;NaN(maxpclength-length(x),1)]',...
                        pitchcontours_all_syllables,'UniformOutput',false));
                    timebins_for_pc = N/2/fs+([0:maxpclength-1]*(N-overlap)/fs);
                    pitchcontours_all_syllables = [timebins_for_pc;pitchcontours_all_syllables];
                end
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
            [yr mon dy hr minutes sec] = datevec(datenm);
         elseif strcmp(CHANSPEC,'w')
              formatIn = 'yyyymmddHHMMSS';
                 datenm = datenum(datevec(fn(end-17:end-4),formatIn));
             %datenm = fn2datenum(fn);
         end
        run_count=run_count+1;
        fvalsstr(run_count).fn = fn;    
        fvalsstr(run_count).datenm = datenm;
        fvalsstr(run_count).firstpeakdistance = firstpeakdistance;
        fvalsstr(run_count).ons = ons; %in ms, onset of each syllable in run into smtemp
        fvalsstr(run_count).off = offs;% in ms, offset of each syllable in run into smtemp
        fvalsstr(run_count).runlength = runlength(i); %number of syllables in run
        fvalsstr(run_count).sylldurations = sylldurations; %duration of each syllable in run
        fvalsstr(run_count).syllgaps = gapdurations; %gaps between each adjacent syllable in run
        fvalsstr(run_count).smtmp = smtemp; %unfiltered amp env of repeat run
        if computespec == 'y'
            fvalsstr(run_count).pitchest = pitchest; %pitch estimate for each syllable in repeat run 
            %fvalsstr(run_count).ent = we;%wiener entropy for each syllable in repeat run
            fvalsstr(run_count).ent = spent;%spectral entropy for each syllable in repeat run
            fvalsstr(run_count).pc = pitchcontours_all_syllables; %pitch contour for each syllable in repeat run, each row is syllable, first row is time vector
            fvalsstr(run_count).amp = amp; %volume for each syllable in run computed by taking average of smooth, rectified waveform
        end
        fvalsstr(run_count).ind = onind(i);%start index for run in the song
        fvalsstr(run_count).sm = sm;%smooth, rectified and log filtered amp env of repeat run
    end
    
end
toc