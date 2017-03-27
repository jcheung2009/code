motif = 'abcccb';
NFFT = 512;
ff = load_batchf('batch.keep');
motif_cnt = 0;
for i = 1:length(ff)
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
    [pthstr,tnm,ext] = fileparts(fn);
    if (strcmp('obs0','w'))
            [dat,fs] = wavread(fn);
    elseif (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,'obs0');
    else
        [dat,fs]=evsoundin('',fn,'obs0');
    end
    if (isempty(dat))
        disp(['hey no data!']);
        continue;
    end
    
     p = strfind(labels,motif);%start index for each motif
      for ii = 1:length(p)
            motif_cnt = motif_cnt+1;
            ton = onsets(p(ii)); toff = offsets(p(ii)+length(motif)-1);
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
        filtsong = bandpass(smtemp,fs,300,15000,'hanningffir');
        
        overlap = NFFT-2;
        t=-NFFT/2+1:NFFT/2;
        sigma=(1/1000)*fs;
        w=exp(-(t/sigma).^2);%gaussian window for spectrogram
        
        [sp f tm] = spectrogram(filtsong,w,overlap,NFFT,fs);
        spec(motif_cnt).sp = abs(sp);
        spec(motif_cnt).tm = tm;
        spec(motif_cnt).f = f;
      end
end

        
        
[maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec2));
    freqlength = max(arrayfun(@(x) length(x.f),spec2));
    avgspec = zeros(freqlength,maxlength);
    for ii = 1:length(spec2)
        pad = maxlength-length(spec2(ii).tm);
        avgspec = avgspec+[spec2(ii).sp,zeros(size(spec2(ii).sp,1),pad)];
    end
    avgspec = avgspec./length(spec2);
    
     figure;hold on;
    imagesc(spec(ind1).tm,spec(ind1).f,log(avgspec));hold on;colormap('jet');
        
        