function [fvalsstr]=jc_findwnote5(batch,params,CHANSPEC);
%extract spectral and temporal information for target syllable
%fvalsstr:
%   fn
%   datenm
%   mxvals: pitch estimate at time shift
%   TRIG: trigger time if WN delivered, -1 = escape/miss
%   CATCH: -1 = not catch, catch times (triggered but no WN)
%   smptmp: amp env of whole syllable     
%   ons
%   offs
%   lbl
%   ind: index for syllable in song file labels
%   NPTNS: number of points used to weight fv values
%   sm
%   maxvol
%   pitchcontour: [timebase pitchcontour]
%   spent: spectral entropy
%   tmpttime: trig time from tmp file

NOTE = params.syllable;
PRENOTE = params.prenotes;
POSTNOTE = params.postnotes;
TIMESHIFT = params.timeshifts;
FVALBND = params.fvalbnd;
NFFT = params.nfft;
evtaf = params.evtaf;
chckpc = params.chckpc;

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
               
    p=strfind(labels,[PRENOTE,NOTE,POSTNOTE])+length(PRENOTE);
    
    for ii = 1:length(p)
        if(length(onsets)==length(labels))
            ton=onsets(p(ii));toff=offsets(p(ii));%in milliseconds
            
            %Determine whether syllable triggered detection 
            if (isfield(rd,'ttimes'))
                trigindtmp=find((rd.ttimes>=ton)&(rd.ttimes<=toff));%find trigger time for syllable
                if (length(trigindtmp)>0)%if exist trigger time for syllable...
                    TRIG=rd.ttimes(trigindtmp);%hits
                    if (isfield(rd,'catch'))
                        ISCATCH=rd.catch(trigindtmp);%determine whether trigger time was hit or catch
                    else
                        ISCATCH=-1;%hits
                    end
                else
                    TRIG=-1;%escapes and misses
                    ISCATCH=-1;
                end
            else
                TRIG=0;%escapes and misses
                ISCATCH=-1;
            end
            
            % pitch contour
            onsamp = floor((ton*1e-3)*fs);
            offsamp = ceil((toff*1e-3)*fs);

                overlap = NFFT-2;
                t=-NFFT/2+1:NFFT/2;
                sigma=(1/1000)*fs;
                w=exp(-(t/sigma).^2);%gaussian window for spectrogram
      
    
            if offsamp + 256 < length(dat)
                note_cnt = note_cnt+1;
                smtemp=dat(onsamp-256:offsamp+256);%unfiltered amplitude envelop of syllable
                filtsong = bandpass(smtemp,fs,300,10000,'hanningffir');
                
                %resegment based on normalized smooth amp env, important if
                %segmentation was done manually because of jitter
                len = round(fs*5/1000);%2 ms window for smoothing
                h   = ones(1,len)/len;
                sm = conv(h,filtsong.^2);
                offset = round((length(sm)-length(filtsong))/2);
                sm=sm(1+offset:length(filtsong)+offset);
                
                logsm = log(sm);
                logsm = logsm-min(logsm);
                logsm = logsm./max(logsm);
                abovethresh = find(logsm>=0.3);
                sm_ons = abovethresh(1);
                sm_offs = abovethresh(end);
                onsamp = onsamp-256+sm_ons;
                offsamp = onsamp-256+sm_offs;
                ton = (onsamp/fs)*1e3;%best estimate of time onset in song in ms
                toff = (offsamp/fs)*1e3;%best estimate of time offset in song in ms
                
                %recompute filtsong with new onsamp and offsamp 
                smtemp = dat(onsamp-256:offsamp+256);
                filtsong = bandpass(smtemp,fs,300,10000,'hanningffir');
                
            else
                error([fn,' time cutoff at end of syllable exceeds file length']);
            end
            
   
                [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
                spec(note_cnt).sp = abs(sp);
                spec(note_cnt).tm = tm;
                spec(note_cnt).f = f;
                pc = [];   
                %use weighted average of power and fft values from sp
                for m = 1:size(sp,2)
                    fdat = abs(sp(:,m));
                    mxtmpvec = zeros([1,size(FVALBND,1)]);
                    for kk = 1:size(FVALBND,1)
                        tmpinds = find((f>=FVALBND(kk,1))&(f<=FVALBND(kk,2)));
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
                pc = [tm' pc];      
                if length(TIMESHIFT) == 1
                    ti1 = find(tm<=TIMESHIFT);
                    ti1 = ti1(end);
                    mxvals = pc(ti1,2);%pitch estimate at timeshift
                elseif length(TIMESHIFT) == 2
                    ti1 = find(tm >= TIMESHIFT(1) & tm <= TIMESHIFT(2));
                    mxvals = mean(pc(ti1,2));
                end
                

                %Spectral temporal entropy
                indf = find(f>=300 & f <= 10000);
                pxx = pxx(indf,:);
                pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));
                
                spent = -sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:)));

             %extract datenum from rec file, add syllable ton in seconds
             datenm = fn2datenm(fn,CHANSPEC,ton);

            fvalsstr(note_cnt).fn     = fn;
            fvalsstr(note_cnt).datenm = datenm;
            fvalsstr(note_cnt).mxvals = mxvals;%pitch estimate at timeshift
            fvalsstr(note_cnt).pitchcontour = pc;
            fvalsstr(note_cnt).spent = spent;%spectral entropy 
            fvalsstr(note_cnt).TRIG   = TRIG;
            fvalsstr(note_cnt).CATCH  = ISCATCH;
            fvalsstr(note_cnt).smtmp = smtemp; %unfiltered amp envelope of whole syllable
            fvalsstr(note_cnt).ons    = ton;%onset of syllable in song
            fvalsstr(note_cnt).offs   = toff;%offset of syllable in song
            fvalsstr(note_cnt).lbl    = labels;
            fvalsstr(note_cnt).ind    = p(ii);%index for syllable in song file
            fvalsstr(note_cnt).sm     = sm;%smooth amplitude envelop
            fvalsstr(note_cnt).maxvol = mean(filtsong.^2); 

            if evtaf == 1
                fvalsstr(note_cnt).evtaf = evtafv;
                fvalsstr(note_cnt).tmpttime = tmpttime;
            end
                
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
    imagesc(spec(ind1).tm,spec(ind1).f,log(avgspec));hold on;colormap('jet');
    plot(pcstruct.tm,nanmean(pcstruct.pc,2),'k');
end

return;

