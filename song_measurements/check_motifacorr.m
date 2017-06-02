function check_motifacorr(batch,motif,log_or_nolog,CHANSPEC);
%plots average autocorr of motif sm amp waveform to estimate peak times


ff = load_batchf(batch);
motif_cnt = 0;
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
    nbuffer = floor(0.016*fs);
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
        
        if strcmp(log_or_nolog,'no log')
            sm2 = sm;
        else
            sm2 = log(sm);
        end
        sm2 = sm2-min(sm2);              
        sm2 = sm2./max(sm2);
        
        motif_cnt=motif_cnt+1;
        [~, lag{motif_cnt} c{motif_cnt}] = find_acorr_peak(sm2,fs,'');
    end
end

figure;hold on;
[maxlen ind] = max(cellfun(@length,lag));
c = cell2mat(cellfun(@(x) [x; NaN(maxlen-length(x),1)],c,'unif',0));
plot(lag{ind}/fs,mean(c,2));hold on;
