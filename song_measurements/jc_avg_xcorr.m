function jc_avg_xcorr(batch,motif,CHANSPEC);
%plots average cross correlation of motif amp waveform. use to determine
%timeband for measuring the first peak in jc_findmotifs

ff = load_batchf(batch);
avcorr = {};
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
        sm = evsmooth(smtemp,fs,'','','',5);%smoothed amplitude envelop
        sm2 = log(sm);
        sm2 = sm2-min(sm2);              
        sm2 = sm2./max(sm2);
        [c lag] = xcorr(sm2,'coeff');
        c = c(ceil(length(lag)/2):end);
        avcorr = [avcorr;c];
    end
end


maxlength = max(cellfun(@length,avcorr));
avcorr = cellfun(@(x) [x;NaN(maxlength-length(x),1)],avcorr,'unif',0);
avcorr = cell2mat(avcorr');
figure;plot([1:maxlength]/fs,nanmean(avcorr,2));


        
        
    