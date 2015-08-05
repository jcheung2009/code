function [fvalsstr]=jc_findwnote2(batch,NOTE,PRENOTE,POSTNOTE,cntrng,refrac,TIMESHIFT,fvalbnd,nfft,NFFT,CHANSPEC,USEX,evtaf4);
%7_14_2014
%use for offline pitch measurement of learning: find pitch relative to template detection 
%NFFT = 128, size of template, use for template detection 
%nfft = 512 or more, use for actual pitch measurement
%TIMESHIFT = mean detection/trigger time in seconds
%cntrng = counter range used for labeling and by evtaf for tmp file values 
%fvalbnd = [harm1_lo harm1_hi; harm2_lo harm2_hi; etc...], takes average
%difference between harmonics as estimate of fundamental 
%finds all labelled syllables and then tmp detections that fall within
%onset/offset of target. if not found, uses TIMESHIFT to measure pitch 
%evtaf4 == 1 extract datenm from filename; else evtaf4 == 0 extract from
%recfile


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

if (~exist('nfft'))%nfft for measuring pitch 
    nfft=1024;
elseif (length(nfft)<1)
    nfft=1024;
end


ff=load_batchf(batch);
for ifn=1:length(ff)
    fn=ff(ifn).name;
    fnn=[fn,'.not.mat'];
    
    if (~exist(fnn,'file'))
        continue;
    end
    %disp(fn);
    load(fnn);

    labels = lower(labels);
    labels(findstr(labels,'0'))='-';
    
    rd = readrecf(fn);

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

    %check that there are labelled target syllables, then load tmp file and
    %extract detection times 
    p=findstr(labels,[PRENOTE,NOTE,POSTNOTE])+length(PRENOTE);
    NCNT = length(cntrng);
    cnt = zeros([1,NCNT]);
    if ~isempty(p) 
        pp = findstr(fn,'.cbin');
        if USEX == 1
            tmpdat = load([fn(1:pp(end)-1),'X.tmp']);
        else
            tmpdat=load([fn(1:pp(end)),'tmp']);
        end

        tmpdat2=zeros([fix(length(tmpdat)/NCNT),NCNT]);
        for ii=1:NCNT
            tmpdat2(:,ii)=tmpdat(ii:NCNT:end);
        end
        tmpdat=tmpdat2;
        clear tmpdat2;
        
        refracsam=ceil(refrac/(2*NFFT/fs));
        lasttrig=-refrac;tt=[];
        cnt = 0*cnt;
        
        for kk=1:NCNT
            if (cntrng(kk).MODE==0)%bird taf mode, set count to max for that column
                cnt(kk)=cntrng(kk).MAX+1;
            end
        end
        
        %find all detections based on tmp file values 
        for ii = 1:size(tmpdat,1)

            for kk=1:NCNT
                if (tmpdat(ii,kk)<=cntrng(kk).TH)%if cross threshold and evtaf mode, increase count by 1 for that column
                    if (cntrng(kk).MODE==1)
                        cnt(kk)=cnt(kk)+1;
                    else
                        if (cnt(kk)>=cntrng(kk).BTMIN)%but if in birdtaf mode and count is greater than BTmin, count set to 0 (count for birdtaf increases when template doesn't match, but reset to 0 when it does. this is so that if Birdtaf hits
                            cnt(kk)=0;
                        else
                            cnt(kk)=cnt(kk)+1;
                        end
                    end
                else
                    if (cntrng(kk).MODE==0)%if don't cross threshold and in birdtaf mode, increase count by 1
                        cnt(kk)=cnt(kk)+1;
                    else
                        cnt(kk)=0;%if don't cross threshold and in evtaf mode, count set to 0
                    end
                end
            end


            %if (DO_OR==0)
            %    trig=1;
            %else
            %    trig=0;
            %end
            for kk=1:NCNT
                if ((cnt(kk)>=cntrng(kk).MIN)&(cnt(kk)<=cntrng(kk).MAX))%if count meets min and max, trigger
                    ntrig=1;
                else
                    ntrig=0;
                end
                if (cntrng(kk).NOT==1)%if count meets min and max, but in NOT mode, not trigger 
                    ntrig=~ntrig;
                end
                %if (DO_OR==0)
                if (kk==1)%keep trigger if in column 1
                    trig=ntrig;
                else
                    if (cntrng(kk-1).AND==1)%if in column 2, check column 1 for AND, trigger 
                        trig = trig & ntrig;%AND: trig if both are 1
                    else
                        trig = trig | ntrig;%OR: trig if either is 1
                    end
                end
            end


            if (trig) %computing trigger time with predata buffer 

                    tbefore = rd.tbefore*fs;                                     

                if (abs(ii-lasttrig)>refracsam)
                    %tt=[tt;((ii*nfft*2/fs)+tbefore)*1e3]; %in milliseconds
                    
                    tt = [tt;(ii*NFFT*2+tbefore)]; %trig time in samples, nfft*2 because evtaf uses 256 nfft 
                    lasttrig=ii;
                end
            end
            
        end
        
    else
        continue
    end
    
    %for each syllable, find pitch relative to tmp detection time, or if
    %can't find tmp trigger, find pitch at average tmp trigger time into
    %syllable 
    for ii = 1:length(p)
        if(length(onsets)==length(labels))
            ton=ceil(onsets(p(ii))*1e-3*fs);toff=ceil(offsets(p(ii))*1e-3*fs);%syllable onset and offset in samples
            ind = find(tt>=ton & tt <= toff); %find trigger time from tmp values that correspond to labelled syllable
            
            if ~isempty(ind) 
                nbins = 10;
                if length(ind) > 1
                    ind = ind(1)
                end
                inds = tt(ind)+[-(nfft-1):0];
                dat2 = dat(inds);
                fdat = abs(fft(hamming(nfft).*dat2));
                fv = [0:nfft/2]*fs/nfft;
                for kk = 1:size(fvalbnd,1)
                    tmpind = find(fv >= fvalbnd(kk,1) & fv <= fvalbnd(kk,2));
                    [tmp pf] = max(fdat(tmpind));
                    pf = pf + tmpind(1) - 1;
                    pf = pf + [-nbins:nbins];
                    fval(kk) = sum(fv(pf).*fdat(pf).')./sum(fdat(pf));
                end
                fval = mean(diff([1,fval]));
            else
                ti1= ceil(TIMESHIFT*fs) + ton;
                if (ti1<=length(dat))
                    nbins = 10;
                    dat2=dat([(ti1-nfft+1):ti1]);
                    fdat=abs(fft(dat2.*hamming(length(dat2))));
                    fv=[0:nfft/2]*fs/nfft;
                    for kk = 1:size(fvalbnd,1)
                        tmpind = find(fv >= fvalbnd(kk,1) & fv <= fvalbnd(kk,2));
                        [tmp pf] = max(fdat(tmpind));
                        pf = pf + tmpind(1) - 1;
                        pf = pf + [-nbins:nbins];
                        fval(kk) = sum(fv(pf).*fdat(pf).')./sum(fdat(pf));
                    end
                    fval = mean(diff([1,fval]));
                else
                    disp('hey')
                end
            end
                    
            %extract datenum from rec file, add syllable onset in seconds 
            if evtaf4 == 1
                 pp = findstr(fn,'.cbin');

                 p2=findstr(fn,'.');
                 p3=find(p2==pp(end));
                    if (length(p3)<1)|(p3(1)<2)|(length(p2)<2)
                        disp(['weird fn = ',fn]);
                        return;
                    end
                 pp = p2(p3-1);
                 dy = str2num(fn([pp(end)-13:pp(end)-12]));
                 mnth = str2num(fn([pp(end)-11:pp(end)-10]));
                 yr = str2num(fn([pp(end)-9:pp(end)-8]));
                 year = 2000 + yr;
                 hr = str2num(fn([pp(end)-6:pp(end)-5]));
                 mnut = str2num(fn([pp(end)-4:pp(end)-3]));
                 scnd = str2num(fn([pp(end)-2:pp(end)-1]));
                 dtnm = datenum([year,mnth,dy,hr,mnut,scnd]);
                 dtnm = addtodate(dtnm,round(onsets(p(ii))),'millisecond');
                 fvalsstr = [fvalsstr; [dtnm fval] ];
            else
                
                key = 'created:';
                ind = strfind(rd.header{1},key);
                tmstamp = rd.header{1}(ind+length(key):end);
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed

                ind2 = strfind(rd.header{5},'=');
                filelength = sscanf(rd.header{5}(ind2 + 1:end),'%g');%duration of file

                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
                datenm = addtodate(tm_st, round(onsets(p(ii))), 'millisecond');%add time to onset of syllable

                fvalsstr = [fvalsstr; [datenm fval] ];
            end
                
        else
            disp('hey');
            fid2=fopen('~/output.txt','a+');
            fprintf(fid2, '%s\n',fn);
            fclose(fid2);
        end

    end
end
end
