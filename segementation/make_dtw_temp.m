function dtwtemplate=make_dtw_temp(batch,params,CHANSPEC)
%this function makes an amplitude waveform template to be used for dtw
%segmentation in amp_vs_dtw_segmentation

if isempty(params)
    params.motif=input('target syllable/motif:','s');
    params.segmentation=input('segmentation params {minint,mindur,thresh}:');
end
      
motif = params.motif;
if ~isempty(params.segmentation) 
    minint = params.segmentation{1};
    mindur = params.segmentation{2};
    thresh = params.segmentation{3};
else
    minint = 3;
    mindur = 20;
    thresh = 0.3;
end

dtwtemplate.filtsong=[];
dtwtemplate.sm=[];
dtwtemplate.ons = [];
dtwtemplate.offs=[];

h = figure;hold on;
ff = load_batchf(batch);
i = 1;
while isempty(dtwtemplate.filtsong)
    %load song data
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];

    if (~exist(fnn,'file'))
        i = i+1;
        continue;
    end
    load(fnn);
    
    %find motifs in bout
    p = strfind(labels,motif);
    if isempty(p)
        i=i+1;
        continue
    end
    
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
        i=i+1;
        continue;
    end

    %get smoothed amp waveform of motif 
    for ii = 1:length(p)
        if ~isempty(dtwtemplate.filtsong)
            break
        end
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
        filtsong = bandpass(smtemp,fs,500,10000,'hanningffir');
        %plot spectrogram
        clf(h);hold on;
        NFFT = 512;
        overlap = NFFT-10;
        t=-NFFT/2+1:NFFT/2;
        sigma=(1/1000)*fs;
        w=exp(-(t/sigma).^2);
        [sp f tm] = spectrogram(filtsong,w,overlap,NFFT,fs);
        indf = find(f>500 & f <10000);
        imagesc(tm,f(indf),log(abs(sp(indf,:))));set(gca,'YDir','normal');hold on;
        
        sm = evsmooth(smtemp,fs,'','','',2);%smoothed amplitude envelop
        sm2=log(sm);
        sm2=sm2-min(sm2);
        sm2=sm2./max(sm2);
        [ons offs] = SegmentNotes(sm2,fs,minint,mindur,thresh);
        plot([ons ons]',[500 10000],'r');hold on;
        plot([offs offs]',[500 10000],'r');hold on;
        keep_or_nokeep = input('use as template?: ','s');
        if keep_or_nokeep == 'n'
            continue
        end
       
        if length(ons) ~= length(motif)
             continue
        else
            dtwtemplate.filtsong=filtsong;
            dtwtemplate.sm=sm;
            dtwtemplate.ons = ons;
            dtwtemplate.offs=offs;
        end
    end
    i=i+1;
end
        