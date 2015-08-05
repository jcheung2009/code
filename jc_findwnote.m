function [fvalsstr]=jc_findwnote(batch,NOTE,PRENOTE,POSTNOTE,...
    TIMESHIFT,FVALBND,NFFT,USEFIT,CHANSPEC,ADDX);
%measure pitch at specified time relative to syllable onset 
%datenum: extracted from rec file which has seconds resolution 
%ADDX: use X.rec 
%FVALBND: [harm1_lo harm1_hi; harm2_lo harm2_hi...]
%USEFIT==1: weighted average for pitch calculation, USEFIT == 0: uses max
%power 
%extracts: file name, datenum, frequency, trig, catch, fft values, raw dat
%at time shift, onsets/offsets,labels in that file, index of the syll in
%that file, num frequency bins for pitch measurement, smoothed amp env, max
%volume 


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

note_cnt=0;avnote_cnt=0;fcnt=0;
ff=load_batchf(batch);
for ifn=1:length(ff)
    fn=ff(ifn).name;
    fnn=[fn,'.not.mat'];
    
    if (~exist(fnn,'file'))
        continue;
    end

    load(fnn);
    % %     if(exist('mod_onset'))
    % %         onsets=mod_onset;
    % %     end

    labels = lower(labels);
    labels(findstr(labels,'0'))='-';
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
    fcnt=fcnt+1;

    p=findstr(labels,[PRENOTE,NOTE,POSTNOTE])+length(PRENOTE);
    
    for ii = 1:length(p)
        if(length(onsets)==length(labels))
            ton=onsets(p(ii));toff=offsets(p(ii));

            if (isfield(rd,'ttimes'))
                trigindtmp=find((rd.ttimes>=ton)&(rd.ttimes<=toff));%find trigger time for syllable
                if (length(trigindtmp)>0)%if exist trigger time for syllable...
                    TRIG=1;%hits
                    if (isfield(rd,'catch'))
                        ISCATCH=rd.catch(trigindtmp);%determine whether trigger time was hit or catch
                    else
                        ISCATCH=-1;%hits
                    end
                else
                    TRIG=0;%escapes and misses
                    ISCATCH=-1;
                end
            else
                TRIG=0;%escapes and misses
                ISCATCH=-1;
            end

            ti1=ceil((TIMESHIFT + ton*1e-3)*fs);
            onsamp = ceil((ton*1e-3)*fs);
            offsamp = ceil((toff*1e-3)*fs);
            if (ti1+NFFT-1<=length(dat))
                note_cnt = note_cnt + 1;
                dattmp=dat([ti1:(ti1+NFFT-1)]);%NFFT samples AFTER timeshift 
                
                smtemp=dat(onsamp-128:offsamp+128);
                %[sm sp t f] = evsmooth(smtemp,Fs,50);
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

          
             %extract datenum from rec file, add syllable ton in seconds
              
                recdata = readrecf([fn(1:end-5),'.rec']);
                key = 'created:';
                ind = strfind(recdata.header{1},key);
                tmstamp = recdata.header{1}(ind+length(key):end);
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
                
                ind2 = strfind(recdata.header{5},'=');
                filelength = sscanf(recdata.header{5}(ind2 + 1:end),'%g');%duration of file
                
                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
                datenm = addtodate(tm_st, round(ton), 'millisecond');%add time to onset of syllable
                [yr mon dy hr min sec] = datevec(datenm);
 
   
                fvalsstr(note_cnt).fn     = fn;
                fvalsstr(note_cnt).yr     = yr;
                fvalsstr(note_cnt).mon     = mon;
                fvalsstr(note_cnt).dy     = dy;
                fvalsstr(note_cnt).hr     = hr;
                fvalsstr(note_cnt).min    = min;
                fvalsstr(note_cnt).scnd    = sec;
                fvalsstr(note_cnt).datenm = datenm;
                
                fvalsstr(note_cnt).mxvals = [1,mxtmpvec];
                fvalsstr(note_cnt).TRIG   = TRIG;
                fvalsstr(note_cnt).CATCH  = ISCATCH;
                fvalsstr(note_cnt).fdat   = fdattmp;
                fvalsstr(note_cnt).datt   = dattmp;
                fvalsstr(note_cnt).ons    = onsets;
                fvalsstr(note_cnt).offs   = offsets;
                fvalsstr(note_cnt).lbl    = labels;
                fvalsstr(note_cnt).ind    = p(ii);%index for syllable in song file
                fvalsstr(note_cnt).ver    = 4;
                fvalsstr(note_cnt).NPNTS  = NPNTS;
                fvalsstr(note_cnt).sm     = sm;
                fvalsstr(note_cnt).maxvol = max(sm);
                
            else
                disp(['timeshift exceeds file length:',fn]);
            end
        else
            disp(['onsets and labels mismatch:',fn]);
%             fid2=fopen('~/output.txt','a+');
%             fprintf(fid2, '%s\n',fn);
%             fclose(fid2);
        end
    end
end
return;
