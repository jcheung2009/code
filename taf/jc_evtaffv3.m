function [vals trigtime hitcount] = jc_evtaffv3(batch,NT,cntrng,refrac,NFFT,fvalbnd,tmpdetect,USEX,evtaf4)

%7_16_2014
%must label songs first 
%simulates online pitch measurements from evtaf: measures pitch relative to detection time
%takes 8 ms (256 sample) chunk before detection/trigger time and finds
%frequency of max power in fft, takes weighted average of +/- nbins 
%tmpdetect = 1: find detections based on tmp file data using cntrng to pull
%values that cross threshold; splits tmp detections into hits and escapes
%based on difference from rec file trigger times
%tmpdetect = 0: compute pitch for all rec file triggers that correspond to
%labelled target syllable
%fvalbnd = [hi lo] = frequency band to look for pitch measurement
%refrac = refractory period for syllable detection
%NFFT = number of samples in template, 128 (evtaf uses 256 = 8 ms segments) 
%trigtime = time into labelled syllable at detection/WN trigger
%hitcount: [hit esc] in 1 and 0, use for computing running hit rate
%evtaf4 == 1 for datenm extraction from file name; else evtaf4 == 0 extract
%datenm from rec file 
%USEX == 1 if made X.tmp from mk_tempf, when data was acquired not with
%template of interest


fid=fopen(batch,'r');
files=[];cnt=0;
while (1)
	fn=fgetl(fid);
	if (~ischar(fn))
		break;
	end
	cnt=cnt+1;
	files(cnt).fn=fn;
end
fclose(fid);
 
% fcheck = fopen('fcheck','w');
% escapetime = [];

if tmpdetect == 1 %do for all triggers in tmp file (escapes + hits) 
     
    NCNT = length(cntrng); %number of templates
    cnt = zeros([1,NCNT]);
    
    trigtime = struct('esc',[],'hit',[]);
    vals = struct('esc',[],'hit',[]);
    hitcount = [];

    for i = 1:length(files)
        rdat=readrecf(files(i).fn);
        if ~exist([files(i).fn,'.not.mat'])
            continue
        else
            load([files(i).fn,'.not.mat']);
        end
        pp = findstr(files(i).fn,'.cbin');
        if USEX == 1
            tmpdat = load([files(i).fn(1:pp(end)-1),'X.tmp']);
        else
            tmpdat=load([files(i).fn(1:pp(end)),'tmp']);
            if isempty(tmpdat)
                disp(['empty tmp:',files(i).fn])
                continue
            end
        end
        [rawsong fs] = evsoundin('',files(i).fn,'obs0');

        %transforming temp values in tmp file into columns matching template    
        tmpdat2=zeros([fix(length(tmpdat)/NCNT),NCNT]);
        for ii=1:NCNT
            tmpdat2(:,ii)=tmpdat(ii:NCNT:end);
        end
        tmpdat=tmpdat2;
        clear tmpdat2;

%         if length(tmpdat)*256+64000 - rdat.nsamp > 32
%             disp(['longer tmpdat',files(i).fn])
%         end
%         if rdat.nsamp - length(tmpdat)*256+64000 > 32
%             disp(['shorter tmpdat',files(i).fn])
%         end
%         
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
                
%                  if length(tmpdat)*256 + rdat.tbefore*fs > rdat.nsamp
%                          tbefore = rdat.tbefore*fs - ((length(tmpdat)*256 + rdat.tbefore*fs)-rdat.nsamp);
%                  elseif length(tmpdat)*256+rdat.tbefore*fs < rdat.nsamp
%                          tbefore = rdat.tbefore*fs + (rdat.nsamp - (length(tmpdat)*256+rdat.tbefore*fs));
%                  else   
%                      tbefore = rdat.tbefore*fs;   
%                  end
                    
                tbefore = rdat.tbefore*fs;

                if (abs(ii-lasttrig)>refracsam)
                    %tt=[tt;((ii*NFFT*2/fs)+tbefore)*1e3]; %in milliseconds
                    
                    tt = [tt;((ii*NFFT*2)+tbefore)]; %trig time in samples, NFFT*2 because evtaf uses 256 nfft 
                    lasttrig=ii;
                end
            end

        end
        
        %remove trigger times from recdata that were on non-target
        %syllables
        ttimes = [];
        for jj = 1:length(rdat.ttimes)
            pp = find((onsets<=rdat.ttimes(jj)) & (offsets>=rdat.ttimes(jj)));
            if strcmp(labels(pp),NT)
                ttimes = [ttimes;rdat.ttimes(jj)];
            end
        end 
            
        %restrict tt from tmp detection to labelled syllables
       tt2 = [];
        for kk = 1:length(tt)
            pp = find((onsets<=tt(kk)*1e3/fs)&(offsets>=tt(kk)*1e3/fs));
            if strcmp(labels(pp),NT)
               tt2 = [tt2; tt(kk)]; 
            end
        end
        tt = tt2;
        clear tt2;
        if length(tt) ~= length(strfind(labels,NT))
            disp(['tmp detections and number of labels mismatch',files(i).fn])
        end
%         
        %find tt's that were escapes or hits (acquisition detected in rec file)
        tescapes = [];
        thits = [];
        if isempty(ttimes)
            tescapes = tt;
            hitcount = [hitcount;[zeros(length(tt),1),ones(length(tt),1)]];
        elseif isempty(tt)
            continue
        else
            for ll = 1:length(tt)
                di = min(abs((ttimes.*1e-3*fs)-tt(ll)));
                if di > 3200 %allow jitter of 100 ms
                    tescapes = [tescapes; tt(ll)];
                    hitcount = [hitcount;[0 1]];
                else
                    thits = [thits; tt(ll)];
                    hitcount = [hitcount;[1 0]];
                end
            end
        end
        
        
        %find trig times for escapes and hits
        for mm = 1:length(tescapes)
            pp = find((onsets<=tescapes(mm)*1e3/fs)&(offsets>=tescapes(mm)*1e3/fs));
            trigtime.esc = [trigtime.esc;(tescapes(mm)*1e3/fs)-onsets(pp)];
        end
        for nn = 1:length(thits)
            pp = find((onsets<=thits(nn)*1e3/fs)&(offsets>=thits(nn)*1e3/fs));
            trigtime.hit = [trigtime.hit;(thits(nn)*1e3/fs)-onsets(pp)];
        end
        
        %compute pitch for escapes and hits, 8 ms before trigtime
        nfft = 2*NFFT;
        nbins = 3; %number of frequency bins to take weighted average for pitch measurement
        for nn = 1:length(tescapes)
            
            %measure pitch at max power, weighted average 
            inds = tescapes(nn)+[-(nfft-1):0];
            datchunk = rawsong(inds);
            fdatchunk = abs(fft(hamming(nfft).*datchunk));
            fv = [0:nfft/2]*fs/nfft;
            %fdatchunk = fdatchunk(1:nfft/2+1);
            tmpind = find(fv >= fvalbnd(1) & fv <= fvalbnd(2));
            [tmp pf] = max(fdatchunk(tmpind));
            pf = pf + tmpind(1) - 1;
            pf = pf + [-nbins:nbins];
            fval1 = sum(fv(pf).*fdatchunk(pf).')./sum(fdatchunk(pf));
            
            %extract datenum from rec file and add syllable onset in
            %seconds
            if evtaf4 == 1
                fn = files(i).fn;
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
                 dtnm = addtodate(dtnm,round(tescapes(nn)*1e3/fs),'millisecond');
                 vals.esc = [vals.esc; [dtnm fval1] ];
            else 
                key = 'created:';
                ind = strfind(rdat.header{1},key);
                tmstamp = rdat.header{1}(ind+length(key):end);
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
                ind2 = strfind(rdat.header{5},'=');
                filelength = sscanf(rdat.header{5}(ind2+1:end),'%g');%duration of file
                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
                datenm = addtodate(tm_st,round(tescapes(nn)*1e3/fs),'millisecond');%add syllable onset to file start time
                vals.esc = [vals.esc; [datenm fval1] ];
            end
        end
        
        for nn = 1:length(thits)
            %measure pitch at max power, weighted average 
            inds = thits(nn)+[-(nfft-1):0];
            datchunk = rawsong(inds);
            fdatchunk = abs(fft(hamming(nfft).*datchunk));
            fv = [0:nfft/2]*fs/nfft;
            %fdatchunk = fdatchunk(1:nfft/2+1);
            tmpind = find(fv >= fvalbnd(1) & fv <= fvalbnd(2));
            [tmp pf] = max(fdatchunk(tmpind));
            pf = pf + tmpind(1) - 1;
            pf = pf + [-nbins:nbins];
            fval2 = sum(fv(pf).*fdatchunk(pf).')./sum(fdatchunk(pf));
            
            %extract datenum from rec file and add syllable onset in
            %seconds
            if evtaf4 == 1
                fn = files(i).fn;
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
                 dtnm = addtodate(dtnm,round(thits(nn)*1e3/fs),'millisecond');
                 vals.hit = [vals.hit; [dtnm fval2] ];
            else 
                key = 'created:';
                ind = strfind(rdat.header{1},key);
                tmstamp = rdat.header{1}(ind+length(key):end);
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
                ind2 = strfind(rdat.header{5},'=');
                filelength = sscanf(rdat.header{5}(ind2+1:end),'%g');%duration of file
                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
                datenm = addtodate(tm_st,round(thits(nn)*1e3/fs),'millisecond');%add syllable onset to file start time
                vals.hit = [vals.hit; [datenm fval2] ];
            end
        end
    end


elseif tmpdetect == 0 %measuring pitch from trigger times in rec file 
    
    NCNT = length(cntrng); %number of templates
    cnt = zeros([1,NCNT]);
    trigtime = [];
    vals = [];
    
    for i = 1:length(files)
        rdat=readrecf(files(i).fn);
        pp = findstr(files(i).fn,'.cbin');
        
        if ~exist([files(i).fn,'.not.mat'])
            continue
        else
            load([files(i).fn,'.not.mat']);
        end
        
        [rawsong fs] = evsoundin('',files(i).fn,'obs0');

        %get trigger times from rec file
        if (~isfield(rdat,'ttimes'))
            continue
        else
            tt = rdat.ttimes*1e-3;
        end
        
        %restrict trigger times to labelled target syllable
        tt2 = [];
        for kk = 1:length(tt)
            pp = find((onsets<=tt(kk)*1e3)&(offsets>=tt(kk)*1e3));
            if strcmp(labels(pp),NT)
                tt2 = [tt2; tt(kk)];
                trigtime = [trigtime;(tt(kk)*1e3)-onsets(pp)];
            end
        end
        tt = tt2;
        clear tt2;

        %fft on 256 window before trig time 
        nfft = 2*NFFT;
        nbins = 3; %number of frequency bins to take weighted average for pitch measurement
        for kk = 1:length(tt)

            inds = fix(tt(kk)*fs)+[-(nfft-1):0];
            datchunk = rawsong(inds);
            fdatchunk = abs(fft(hamming(nfft).*datchunk));
            fv = [0:nfft/2]*fs/nfft;
            %fdatchunk = fdatchunk(1:nfft/2+1);
            tmpind = find(fv >= fvalbnd(1) & fv <= fvalbnd(2));
            [tmp pf] = max(fdatchunk(tmpind));
            pf = pf + tmpind(1) - 1;
            pf = pf + [-nbins:nbins];
            fval = sum(fv(pf).*fdatchunk(pf).')./sum(fdatchunk(pf));

            %extract datenum from rec file and add syllable onset in
            %seconds
             if evtaf4 == 1
                fn = files(i).fn;
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
                 dtnm = addtodate(dtnm,round(tt(kk)*1e3/fs),'millisecond');
                 vals = [vals; [dtnm fval] ];
            else 
                key = 'created:';
                ind = strfind(rdat.header{1},key);
                tmstamp = rdat.header{1}(ind+length(key):end);
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
                ind2 = strfind(rdat.header{5},'=');
                filelength = sscanf(rdat.header{5}(ind2+1:end),'%g');%duration of file
                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
                datenm = addtodate(tm_st,round(tt(kk)*1e3/fs),'millisecond');%add syllable onset to file start time
                vals = [vals; [datenm fval] ];
            end
 
        end
    end

end

    