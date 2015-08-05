function [fvalsstr]=jc_findwnote4(batch,NOTE,PRENOTE,POSTNOTE,...
    TIMESHIFT,FVALBND,NFFT,USEFIT,CHANSPEC,ADDX,evtaf,varargin);
%combines jc_findwnote and jc_evtaffv3 and puts all information in one
%structure
%datenum: extracted from rec file which has seconds resolution 
%ADDX: use X.rec 
%FVALBND: [harm1_lo harm1_hi; harm2_lo harm2_hi...]
%USEFIT==1: weighted average for pitch calculation
%USEFIT == 0: uses max power
%NFFT: size of window to compute pitch, usually 512 (16 ms)
%varargin: {cntrng,refrac,tempNFFT,fvalbnd,USEX} 
%fvalsstr:
%   fn
%   yr
%   mon
%   dy
%   hr
%   min
%   sec
%   datenm
%   mxvals: [1, harm1, harm2, harm3...etc]
%   TRIG: trigger time if WN delivered, -1 = escape/miss
%   CATCH: -1 = not catch, catch times (triggered but no WN)
%   fdat: fft 
%   dattmp: amp env of NFFT segment from time shift
%   smptmp: amp env of whole syllable     
%   ons
%   offs
%   lbl
%   ind: index for syllable in song file labels
%   NPTNS: number of points used to weight fv values
%   sm
%   maxvol
%   evtaf: pitch values for hits and escapes 
%   tmpttime: trig time from tmp file


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
    NFFT=1024;
elseif (length(NFFT)<1)
    NFFT=1024;
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
            ton=onsets(p(ii));toff=offsets(p(ii));
            
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
            
            %pith measurement based on time into syllable
            ti1=ceil((TIMESHIFT + ton*1e-3)*fs);
            onsamp = ceil((ton*1e-3)*fs);
            offsamp = ceil((toff*1e-3)*fs);
            if (ti1+NFFT-1<=length(dat))
                note_cnt = note_cnt + 1;
                dattmp=dat([ti1:(ti1+NFFT-1)]);%NFFT samples AFTER timeshift 
                smtemp=dat(onsamp-128:offsamp+128);
                sm = filter(ones(1,256)/256,1,(smtemp.^2));
                fdattmp=abs(fft(dattmp.*hamming(length(dattmp))));
                %get the freq vals in Hertz
                fvals=[0:length(fdattmp)/2]*fs/(length(fdattmp));
                fdattmp=fdattmp(1:end/2);
                mxtmpvec=zeros([1,size(FVALBND,1)]);
                for kk = 1:size(FVALBND,1)
                    tmpinds=find((fvals>=FVALBND(kk,1))&(fvals<=FVALBND(kk,2)));
                    NPNTS=10;%number of frequency bins to do weighted average
                    [tmp,pf] = max(fdattmp(tmpinds));
                    pf = pf + tmpinds(1) - 1;
                    if (USEFIT==1)%weighted average 
                        tmpxv=pf + [-NPNTS:NPNTS];
                        tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(fvals))));
                        mxtmpvec(kk)=fvals(tmpxv)*fdattmp(tmpxv);
                        mxtmpvec(kk)=mxtmpvec(kk)./sum(fdattmp(tmpxv));
                    else
                        mxtmpvec(kk) = fvals(pf);
                    end
                end
                
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
                [yr mon dy hr min sec] = datevec(datenm);
             elseif strcmp(CHANSPEC,'w')
                 datenm = fn2datenum(fn);
             end
%    
                 fvalsstr(note_cnt).fn     = fn;
%                 fvalsstr(note_cnt).yr     = yr;
%                 fvalsstr(note_cnt).mon     = mon;
%                 fvalsstr(note_cnt).dy     = dy;
%                 fvalsstr(note_cnt).hr     = hr;
%                 fvalsstr(note_cnt).min    = min;
%                 fvalsstr(note_cnt).scnd    = sec;
                fvalsstr(note_cnt).datenm = datenm;
                fvalsstr(note_cnt).mxvals = [1,mxtmpvec];
                fvalsstr(note_cnt).TRIG   = TRIG;
                fvalsstr(note_cnt).CATCH  = ISCATCH;
                fvalsstr(note_cnt).fdat   = fdattmp; %fft
                fvalsstr(note_cnt).dattmp   = dattmp;%unfiltered amp envelope of NFFT segment from timeshift
                fvalsstr(note_cnt).smtmp = smtemp; %unfiltered amp envelope of whole syllable
                fvalsstr(note_cnt).ons    = onsets;
                fvalsstr(note_cnt).offs   = offsets;
                fvalsstr(note_cnt).lbl    = labels;
                fvalsstr(note_cnt).ind    = p(ii);%index for syllable in song file
                fvalsstr(note_cnt).ver    = 4;
                fvalsstr(note_cnt).NPNTS  = NPNTS;
                fvalsstr(note_cnt).sm     = sm;
                fvalsstr(note_cnt).maxvol = max(sm);
                
                if evtaf == 1
                    fvalsstr(note_cnt).evtaf = evtafv;
                    fvalsstr(note_cnt).tmpttime = tmpttime;
                end
                
            else
                disp(['timeshift exceeds file length:',fn]);
            end
        else
            disp(['onsets and labels mismatch:',fn]);
        end
    end
end
return;

