function fvalsstr = jc_findrepeat5(batch,params,dtwtemplate,CHANSPEC,fs)
%extract information for each instance of a repeat run and information for
%each syllable within those repeat runs
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
%   pitch = pitch estimate for each syllable in repeat run
%   ent: spectemp entropy for each syllable in repeat run
%   ind = index of run
%   amp = volume of each syllable in run
%   sm = smooth filtered amp env of run
tic

note = params.repnote;
prenote = params.prenote;
fvalbnd = params.fvalbnd;
timeshift = params.timeshift;
computespec = params.computespec;
timeband = params.timeband;
check_segmentation = params.check_segmentation;
check_peakfind = params.check_peakfind;
timeband = params.timeband;
if check_segmentation == 'y' | check_peakfind == 'y'
    h = figure;hold on;
end
%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

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
    
    %% get segment index for onset and offset of each repeat instance
    p = ismember(labels,note);
    kk = [find(diff([-1 p -1])~=0)];
    runlength = diff(kk);
    runlength = runlength(1+(p(1)==0):2:end);
    if isempty(runlength)
        continue
    end
    pp = find(diff([0 p])==1);
    onind = pp;%start index for each repeat run
    offind = pp+runlength-1;%end index for each repeat run
    
    if ~isempty(prenote)
        pp2 = strfind(labels,[prenote,note]);
        onind = pp2 + 1; 
        runlength = runlength(ismember(pp,onind));
        offind = pp2 + runlength; 
    end

    %% measure tempo, syll/gap duration, and spectral features in each repeat
    %instance
    nbuffer = 0.016*fs;%16 ms buffer for segmenting repeats
    for i = 1:length(runlength) 
        ton = onsets(onind(i)); toff = offsets(offind(i));%ms
        onsamp = ceil((ton*1e-3)*fs);
        offsamp = ceil((toff*1e-3)*fs);
        if offsamp + nbuffer > length(dat)
            offsamp = length(dat);
        else
            offsamp = offsamp+nbuffer;
        end
        if onsamp - nbuffer < 1
            onsamp = 1;
        else 
            onsamp = onsamp-nbuffer;
        end
        
        smtemp = dat(onsamp:offsamp);
        filtsong = bandpass(smtemp,fs,1000,10000,'hanningffir');
        sm = evsmooth(smtemp,fs,'','','',5);
        sm = log(sm);sm = sm-min(sm);sm = sm./max(sm);
        
        %measure tempo using autocorrelation of smoothed amp env
        if runlength(i) >= 3
            [firstpeakdistance lag c locs pks] = find_acorr_peak(sm,fs,timeband);
            if check_peakfind == 'y'
                clf(h);hold on;
                plot(lag/fs,c,'k',locs/fs,pks,'or');hold on;
                pause
            end
        else
            firstpeakdistance = NaN;
        end
        
        %get syll durs and gaps by dtw segmentation
        ons = [];offs = [];
        nbuffer2 = 0.016*fs;%buffer by 16 ms for each individual syll in repeat
        for n = 1:runlength(i)
            onsamp_syll = floor(onsets(onind(i)+n-1)*1e-3*fs)-nbuffer;
            offsamp_syll = ceil(offsets(onind(i)+n-1)*1e-3*fs)+nbuffer;
            smtemp_syll = dat(onsamp_syll:offsamp_syll);
            [sm_ons sm_offs] = dtw_segment(smtemp_syll,dtwtemplate,fs);
            sm_ons=sm_ons*fs;sm_offs=sm_offs*fs;
            onsamp_syll2 = (onsamp_syll+sm_ons)-onsamp;
            offsamp_syll2 = (onsamp_syll+sm_offs)-onsamp;
            ons = [ons;onsamp_syll2/fs];%seconds into filtsong
            offs = [offs;offsamp_syll2/fs];
        end
        disp([num2str(length(ons)),' syllables detected']);
        
        %check segmentation
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
        
        if length(ons) ~= runlength(i) 
            sylldurations = NaN;
            gapdurations = NaN;
        else
            sylldurations = offs-ons;
            gapdurations = ons(2:end)-offs(1:end-1);
        end
        
        %pitch,volume, entropy measurement for each syllable in repeat
        if computespec == 'y'
            if length(ons) ~= runlength(i)
                pitch = NaN;
                amp = NaN;
                pitchcontours_all_syllables = NaN;
                ons = NaN;
                offs = NaN;
                spectempent = NaN;
            else
                pitch=[];amp =[];spectempent=[];pitchcontours_all_syllables=cell(length(ons),1);
                for ii = 1:length(ons)
                    onsamp_syll = floor(ons(ii)*fs)-nbuffer2;
                    offsamp_syll = ceil(offs(ii)*fs)+nbuffer2;
                    if onsamp_syll < 0 
                        onsamp_syll = 1;
                    end
                    if offsamp_syll > length(filtsong)
                        offsamp_syll = length(filtsong);
                    end
                    try
                        filtsong_syll = filtsong(onsamp_syll:offsamp_syll);
                    catch
                        error([fn,' time cutoff at end of syllable exceeds file length']);
                    end
                    
                    %volume
                    amp = cat(1,amp,mean(filtsong_syll.^2));
                   
                    %pitch, pitchcontour, spectempent
                    [fv pc spent] = measure_specs(filtsong_syll,fvalbnd,timeshift,fs);
                    pitch=[pitch;fv];spectempent=[spectempent;spent];
                    pitchcontours_all_syllables{ii} = pc;
                end
                maxpclength = max(cellfun(@length,pitchcontours_all_syllables));
                pitchcontours_all_syllables = cell2mat(cellfun(@(x) [x;NaN(maxpclength-length(x),1)]',...
                    pitchcontours_all_syllables,'UniformOutput',false));
                timebins_for_pc = NFFT/2/fs+([0:maxpclength-1]*(NFFT-overlap)/fs);
                pitchcontours_all_syllables = [timebins_for_pc;pitchcontours_all_syllables];
            end
        end
 
        %extract datenum from rec file, add syllable ton in seconds
        datenm = fn2datenm(fn,CHANSPEC,ton);
                          
        run_count=run_count+1;
        fvalsstr(run_count).fn = fn;    
        fvalsstr(run_count).datenm = datenm;
        fvalsstr(run_count).firstpeakdistance = firstpeakdistance;%interval-interval duration in seconds
        fvalsstr(run_count).ons = ons; %in ms, onset of each syllable in run into smtemp
        fvalsstr(run_count).off = offs;% in ms, offset of each syllable in run into smtemp
        fvalsstr(run_count).runlength = runlength(i); %number of syllables in run
        fvalsstr(run_count).sylldurations = sylldurations; %duration of each syllable in run
        fvalsstr(run_count).syllgaps = gapdurations; %gaps between each adjacent syllable in run
        fvalsstr(run_count).smtmp = smtemp; %unfiltered amp env of repeat run
        fvalsstr(run_count).ind = pp(i);%start index for run in the song
        fvalsstr(run_count).sm = sm;%smooth, rectified and log filtered amp env of repeat run
        if computespec == 'y'
            fvalsstr(run_count).pitch = pitch; %pitch estimate for each syllable in repeat run 
            fvalsstr(run_count).ent = spectempent;%spectral entropy for each syllable in repeat run
            fvalsstr(run_count).pc = pitchcontours_all_syllables; %pitch contour for each syllable in repeat run, each row is syllable, first row is time vector
            fvalsstr(run_count).amp = amp; %volume for each syllable in run computed by taking average of smooth, rectified waveform
        end
        
    end
    
end
toc