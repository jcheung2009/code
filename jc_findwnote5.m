function [fvalsstr]=jc_findwnote5(batch,NOTE,PRENOTE,POSTNOTE,...
    TIMESHIFT,FVALBND,NFFT,USEFIT,CHANSPEC,evtaf,ADDX,varargin);
%combines jc_findwnote and jc_evtaffv3 and pitch contour code
%datenum: extracted from rec file which has seconds resolution 
%ADDX: use X.rec 
%FVALBND: [harm1_lo harm1_hi; harm2_lo harm2_hi...]
%USEFIT==1: weighted average for pitch calculation
%USEFIT == 0: uses max power
%NFFT: size of window to compute pitch, usually 512 (16 ms)
%varargin: {cntrng,refrac,tempNFFT,fvalbnd,USEX} used with evtaf == 1 to get evtaf pitch measurements 
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
%   we: wiener entropy 
%   spent: spectral entropy
%   evtaf: pitch values for hits and escapes 
%   tmpttime: trig time from tmp file
tic
fvalsstr=[];
if (~exist('PRENOTE'))
    PRENOTE='';
elseif (length(PRENOTE)<1)
    PRENOTE='';
end

if (~exist('CHANSPEC'))
    CHANSPEC='obs0';
elseif (length(CHANSPEC)<1)
    CHANSPEC='obs0';
end

if (~exist('NFFT'))
    NFFT=512;
elseif (length(NFFT)<1)
    NFFT=512;
end

if (~exist('USEFIT'))
    USEFIT=1;
elseif (length(USEFIT)<1)
    USEFIT=1;
end

if (~exist('ADDX'))
    ADDX=0;
elseif (length(ADDX)<1)
    ADDX=0;
end

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
    if (ADDX==1)
        ptemp=findstr(fnn,'.cbin');
        if (isempty(ptemp))
            ptemp=findstr(fnn,'.cbin');
        end
        fnrt=[fnn(1:ptemp(end)-1),'X.rec'];
    else
        fnrt=fn;
    end
    rd = readrecf(fnrt);

    %load raw song data
    [pthstr,tnm,ext] = fileparts(fn);
    if (strcmp(CHANSPEC,'w'))
            [dat,fs] = wavread(fn);
    elseif (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,CHANSPEC);
    else
        [dat,fs]=evsoundin('',fn,CHANSPEC);
    end
    if (isempty(dat))
        disp(['hey no data!']);
        continue;
    end
    
    if evtaf == 1 %if compute evtaf pitch estimate find temp file detections
        NCNT = length(varargin{1}); %number of templates
        cnt = zeros([1,NCNT]);%used for counts in tmp  
        pp = findstr(fn,'.cbin');
        
        %load tmp file
        if varargin{5} == 1
            tmpdat = load([fn(1:pp(end)),'X.tmp']);
        else
            tmpdat = load([fn(1:pp(end)),'tmp']);
        end
        
        %transforming temp values in tmp file into columns matching template   
        tmpdat2=zeros([fix(length(tmpdat)/NCNT),NCNT]);
        for ii=1:NCNT
            tmpdat2(:,ii)=tmpdat(ii:NCNT:end);
        end
        tmpdat=tmpdat2;
        clear CHANSPECtmpdat2;
        
        refracsam=ceil(varargin{2}/(2*varargin{3}/fs));
        lasttrig=-varargin{2};tt=[];%tt = tmp detections 
        cnt = 0*cnt;

        for kk=1:NCNT
            if (varargin{1}(kk).MODE==0)%bird taf mode, set count to max for that column
                cnt(kk)=varargin{1}(kk).MAX+1;
            end
        end

        %find all detections based on tmp file values 
        for ii = 1:size(tmpdat,1)

            for kk=1:NCNT
                if (tmpdat(ii,kk)<=varargin{1}(kk).TH)%if cross threshold and evtaf mode, increase count by 1 for that column
                    if (varargin{1}(kk).MODE==1)
                        cnt(kk)=cnt(kk)+1;
                    else
                        if (cnt(kk)>=varargin{1}(kk).BTMIN)%but if in birdtaf mode and count is greater than BTmin, count set to 0 (count for birdtaf increases when template doesn't match, but reset to 0 when it does. this is so that if Birdtaf hits
                            cnt(kk)=0;
                        else
                            cnt(kk)=cnt(kk)+1;
                        end
                    end
                else
                    if (varargin{1}(kk).MODE==0)%if don't cross threshold and in birdtaf mode, increase count by 1
                        cnt(kk)=cnt(kk)+1;
                    else
                        cnt(kk)=0;%if don't cross threshold and in evtaf mode, count set to 0
                    end
                end
            end

            for kk=1:NCNT
                if ((cnt(kk)>=varargin{1}(kk).MIN)&(cnt(kk)<=varargin{1}(kk).MAX))%if count meets min and max, trigger
                    ntrig=1;
                else
                    ntrig=0;
                end
                if (varargin{1}(kk).NOT==1)%if count meets min and max, but in NOT mode, not trigger 
                    ntrig=~ntrig;
                end
                %if (DO_OR==0)
                if (kk==1)%keep trigger if in column 1
                    trig=ntrig;
                else
                    if (varargin{1}(kk-1).AND==1)%if in column 2, check column 1 for AND, trigger 
                        trig = trig & ntrig;%AND: trig if both are 1
                    else
                        trig = trig | ntrig;%OR: trig if either is 1
                    end
                end
            end

            if (trig) %computing trigger time with predata buffer 
                tbefore = rd.tbefore*fs;
                if (abs(ii-lasttrig)>refracsam)
                    tt = [tt;((ii*varargin{3}*2)+tbefore)]; %trig time in samples, NFFT*2 because evtaf uses 256 nfft 
                    lasttrig=ii;
                end
            end
        end
    end
               
    p=findstr(labels,[PRENOTE,NOTE,POSTNOTE])+length(PRENOTE);
    
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
                filtsong = bandpass(smtemp,fs,300,15000,'hanningffir');
                
                %resegment based on normalized smooth amp env, important if
                %segmentation was done manually because of jitter
                len = round(fs*2/1000);%2 ms window for smoothing
                h   = ones(1,len)/len;
                sm = conv(h,filtsong.^2);
                offset = round((length(sm)-length(filtsong))/2);
                sm=sm(1+offset:length(filtsong)+offset);
                
                logsm = log(sm);
                logsm = logsm-min(logsm);
                logsm = logsm./max(logsm);
                abovethresh = find(logsm>=0.5);
                sm_ons = abovethresh(1);
                sm_offs = abovethresh(end);
                onsamp = onsamp-256+sm_ons;
                offsamp = onsamp-256+sm_offs;
                ton = (onsamp/fs)*1e3;%best estimate of time onset in song in ms
                toff = (offsamp/fs)*1e3;%best estimate of time offset in song in ms
                
                %recompute filtsong with new onsamp and offsamp 
                smtemp = dat(onsamp-256:offsamp+256);
                filtsong = bandpass(smtemp,fs,300,15000,'hanningffir');
                
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
                    if (USEFIT==1)%weighted average 
                        tmpxv=pf + [-NPNTS:NPNTS];
                        tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(f))));
                        mxtmpvec(kk)=f(tmpxv)'*fdat(tmpxv);
                        mxtmpvec(kk)=mxtmpvec(kk)./sum(fdat(tmpxv));
                    else
                        mxtmpvec(kk) = f(pf);
                    end
                end
                pc = cat(1,pc,mean(diff([0,mxtmpvec])));
            end
            pc = [tm' pc];            
            ti1 = find(tm<=TIMESHIFT);
            ti1 = ti1(end);
            mxvals = pc(ti1,2);%pitch estimate at timeshift
            
            %uses autocorrelation of spectrogram to determine pitch
%             for m = 1:size(sp,2)
%                 fdat = abs(sp(:,m));
%                 c = xcorr(fdat,'coeff');%
%                 c = c(ceil(length(c)/2):end);
%                 [pks locs] = findpeaks(c);
%                 ind = find(f(locs) >= FVALBND(1) & f(locs) <= FVALBND(2));%finds indices of peaks within freq range
%                 [mx id] = max(pks(ind)); %finds peak with max power within freq range
%                 if isempty(id)
%                     pc = cat(1,pc,NaN);
%                 else
%                     maxpowerind = locs(ind(id)); 
%                     maxpowerind = maxpowerind + [-1:1];%get three points surrounding peak ind
%                     pc = cat(1,pc,pinterp(f(maxpowerind),c(maxpowerind)));
%                 end
%             end

            %entropy measurements
%             we = mean(log(geomean(abs(sp),1))); %wiener entropy by averaging all WE values in every timebin of spec
            pxx = bsxfun(@rdivide,pxx,sum(pxx));
            spent = [];%spectral entropy
            for qq = 1:size(pxx,2)
                spent = [spent; -sum(pxx(:,qq).*log(pxx(:,qq)))];
            end
            spent = mean(spent);
%             %pith measurement based on time into syllable
%             ti1=ceil((TIMESHIFT + ton*1e-3)*fs);
%             onsamp = ceil((ton*1e-3)*fs);
%             offsamp = ceil((toff*1e-3)*fs);
%             if (ti1+NFFT-1<=length(dat))
%                 note_cnt = note_cnt + 1;
%                 dattmp=dat([ti1:(ti1+NFFT-1)]);%NFFT samples AFTER timeshift 
%                 smtemp=dat(onsamp-128:offsamp+128);
%                 sm = filter(ones(1,256)/256,1,(smtemp.^2));
%                 fdattmp=abs(fft(dattmp.*hamming(length(dattmp))));
%                 %get the freq vals in Hertz
%                 fvals=[0:length(fdattmp)/2]*fs/(length(fdattmp));
%                 fdattmp=fdattmp(1:end/2);
%                 mxtmpvec=zeros([1,size(FVALBND,1)]);
%                 for kk = 1:size(FVALBND,1)
%                     tmpinds=find((fvals>=FVALBND(kk,1))&(fvals<=FVALBND(kk,2)));
%                     NPNTS=10;%number of frequency bins to do weighted average
%                     [tmp,pf] = max(fdattmp(tmpinds));
%                     pf = pf + tmpinds(1) - 1;
%                     if (USEFIT==1)%weighted average 
%                         tmpxv=pf + [-NPNTS:NPNTS];
%                         tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(fvals))));
%                         mxtmpvec(kk)=fvals(tmpxv)*fdattmp(tmpxv);
%                         mxtmpvec(kk)=mxtmpvec(kk)./sum(fdattmp(tmpxv));
%                     else
%                         mxtmpvec(kk) = fvals(pf);
%                     end
%                 end
                
             %evtaf pitch estimates based on tmp detection
             if evtaf == 1
                evtafv = []; tmpttime = [];
                pp = find((tt.*(1e3/fs)>=ton)&(tt.*(1e3/fs)<=toff));
                if ~isempty(pp)
                    nfft = 2*varargin{3};%8 ms before tmp trig time
                    nbins = 3;
                    if length(pp) > 1
                        disp(fn)
                    end
                    inds = tt(pp)+[-(nfft-1):0];
                    datchunk = dat(inds);
                    fdatchunk = abs(fft(hamming(nfft).*datchunk));
                    fv = [0:nfft/2]*fs/nfft;
                    tmpind = find(fv >= varargin{4}(1) & fv <= varargin{4}(2));
                    [tmp pf] = max(fdatchunk(tmpind));
                    pf = pf + tmpind(1) -1;
                    pf = pf + [-nbins:nbins];
                    evtafv = sum(fv(pf).*fdatchunk(pf).')./sum(fdatchunk(pf));
                    tmpttime = tt(pp)*1e3/fs;
                end
             end
   
             %extract datenum from rec file, add syllable ton in seconds
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
                 datenm = fn2datenum(fn);
             end
%    
                 fvalsstr(note_cnt).fn     = fn;
%                 fvalsstr(note_cnt).yr     = yr;
%                 fvalsstr(note_cnt).mon     = mon;
%                 fvalsstr(note_cnt).dy     = dy;
%                 fvalsstr(note_cnt).hr     = hr;
%                 fvalsstr(note_cnt).min    = minutes;
%                 fvalsstr(note_cnt).scnd    = sec;
                fvalsstr(note_cnt).datenm = datenm;
                fvalsstr(note_cnt).mxvals = mxvals;%pitch estimate at timeshift
                fvalsstr(note_cnt).TRIG   = TRIG;
                fvalsstr(note_cnt).CATCH  = ISCATCH;
                fvalsstr(note_cnt).smtmp = smtemp; %unfiltered amp envelope of whole syllable
                fvalsstr(note_cnt).ons    = ton;%onset of syllable in song
                fvalsstr(note_cnt).offs   = toff;%offset of syllable in song
                fvalsstr(note_cnt).lbl    = labels;
                fvalsstr(note_cnt).ind    = p(ii);%index for syllable in song file
                fvalsstr(note_cnt).NPNTS  = NPNTS;
                fvalsstr(note_cnt).sm     = sm;%smooth amplitude envelop
                fvalsstr(note_cnt).maxvol = mean(filtsong.^2);
                fvalsstr(note_cnt).pitchcontour = pc;
                %fvalsstr(note_cnt).we = we;%wiener entropy
                 fvalsstr(note_cnt).spent = spent;%spectral entropy 
%                 fvalsstr(note_cnt).spec.sp = abs(sp);%spectrogram
%                 fvalsstr(note_cnt).spec.f = f;%frequency values for spec
%                 fvalsstr(note_cnt).spec.tm = tm;%time values for spec
 
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
imagesc(spec(ind1).tm,spec(ind1).f,log(avgspec));hold on;
plot(pcstruct.tm,nanmean(pcstruct.pc,2),'k');

return;
toc
