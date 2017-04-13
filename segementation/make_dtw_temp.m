function dtwtemplate=make_dtw_temp(batch,params,CHANSPEC)
%this function makes an amplitude waveform template to be used for dtw
%segmentation in amp_vs_dtw_segmentation

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

ff = load_batchf(batch);
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
        if ~isempty(dtwtemplate.filtsong)
            break
        end
        ton = onsets(p(ii));
        toff=offsets(p(ii)+length(motif)-1);
        onsamp = ceil((ton*1e-3)*fs);
        offsamp = ceil((toff*1e-3)*fs);
        nbuffer = floor(0.032*fs);%buffer by 32 ms
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
        sm = evsmooth(smtemp,fs,'','','',2);%smoothed amplitude envelop
        sm2=log(sm);
        sm2=sm2-mean(sm2);
        [ons offs] = SegmentNotes(sm2,fs,minint,mindur,0);
        if length(ons) ~= length(motif)
             dtwtemplate.filtsong=[];
             dtwtemplate.sm=[];
        else
            dtwtemplate.filtsong=bandpass(smtemp,fs,1000,10000,'hanningffir');
            dtwtemplate.sm=sm;
            dtwtemplate.ons = ons;
            dtwtemplate.offs=offs;
        end
    end
end
        