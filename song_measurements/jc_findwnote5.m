function [fvalsstr]=jc_findwnote5(batch,params,dtwtemplate,CHANSPEC,fs,fb_dur);
%extract spectral and temporal information for target syllable

NOTE = params.syllable;
PRENOTE = params.prenotes;
POSTNOTE = params.postnotes;
TIMESHIFT = params.timeshifts;
FVALBND = params.fvalbnd;
chckpc = params.chckpc;
nbuffer = 0.016*fs;%16 ms buffer for segmenting

fvalsstr=[];
note_cnt=0;
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
    
    if has_nonalphanum([PRENOTE,NOTE,POSTNOTE])
        p=regexp(labels,[PRENOTE,NOTE,POSTNOTE]);
        if ~isempty(PRENOTE)
            p=p+1;
        end
    else
        p = strfind(labels,[PRENOTE,NOTE,POSTNOTE])+length(PRENOTE);
    end
    
    for ii = 1:length(p)
        if(length(onsets)==length(labels))
            ton=onsets(p(ii));toff=offsets(p(ii));%in milliseconds
            
            %Determine whether syllable triggered detection
            [TRIG ISCATCH trigtime] = trig_or_notrig(rd,ton,toff,fb_dur);
            
            %dtw segmentation (alternatively use syl_ampsegment)
            onsamp = floor((ton*1e-3)*fs);
            offsamp = ceil((toff*1e-3)*fs);
            if offsamp + nbuffer < length(dat)
                smtemp=dat(onsamp-nbuffer:offsamp+nbuffer);%unfiltered amplitude envelop of syllable
                [sm_ons sm_offs] = dtw_segment(smtemp,dtwtemplate,fs);
                sm_ons=sm_ons*fs;sm_offs=sm_offs*fs;
                onsamp = onsamp-nbuffer+sm_ons;
                offsamp = onsamp-nbuffer+sm_offs;
                ton = (onsamp/fs)*1e3;%best estimate of time onset in song in ms
                toff = (offsamp/fs)*1e3;%best estimate of time offset in song in ms
                smtemp=dat(onsamp-nbuffer:offsamp+nbuffer);
                filtsong=bandpass(smtemp,fs,1000,10000,'hanningffir'); 
                sm=evsmooth(smtemp,fs,'','','',5);
            else
                error([fn,' time cutoff at end of syllable exceeds file length']);
            end
            
            %spectral measurements
            [mxvals pc spectempent sp f tm] = measure_specs(filtsong,FVALBND,TIMESHIFT,fs);
            pc = [tm' pc]; 

            %extract datenum from rec file, add syllable ton in seconds
            datenm = fn2datenm(fn,CHANSPEC,ton);
             
            note_cnt = note_cnt+1;
            spec(note_cnt).sp = sp;
            spec(note_cnt).tm = tm;
            spec(note_cnt).f = f;
            
            fvalsstr(note_cnt).fn     = fn;
            fvalsstr(note_cnt).datenm = datenm;
            fvalsstr(note_cnt).mxvals = mxvals;%pitch estimate at timeshift
            fvalsstr(note_cnt).pitchcontour = pc;
            fvalsstr(note_cnt).spent = spectempent;%spectral entropy 
            fvalsstr(note_cnt).TRIG   = TRIG;
            fvalsstr(note_cnt).trigtime = trigtime;
            fvalsstr(note_cnt).CATCH  = ISCATCH;
            fvalsstr(note_cnt).smtmp = smtemp; %unfiltered amp envelope of whole syllable
            fvalsstr(note_cnt).ons    = ton;%onset of syllable in song
            fvalsstr(note_cnt).offs   = toff;%offset of syllable in song
            fvalsstr(note_cnt).lbl    = labels;
            fvalsstr(note_cnt).ind    = p(ii);%index for syllable in song file
            fvalsstr(note_cnt).sm     = sm;%smooth amplitude envelop
            fvalsstr(note_cnt).maxvol = mean(filtsong.^2); 
        else
            disp(['onsets and labels mismatch:',fn]);
        end
    end
end

%% check pitch contours with average spectrograms 
if chckpc == 1
    [maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec));
    freqlength = max(arrayfun(@(x) length(x.f),spec));
    avgspec = zeros(freqlength,maxlength);
    for ii = 1:length(spec)
        pad = maxlength-length(spec(ii).tm);
        avgspec = avgspec+[spec(ii).sp,zeros(size(spec(ii).sp,1),pad)];
    end
    avgspec = avgspec./length(spec);

    pcstruct = jc_getpc(fvalsstr);

    figure;hold on;
    imagesc(spec(ind1).tm,spec(ind1).f,log(avgspec));axis('xy');hold on;
    plot(pcstruct.tm,nanmean(pcstruct.pc,2),'k');
    title([PRENOTE upper(NOTE) POSTNOTE]);
end

return;

