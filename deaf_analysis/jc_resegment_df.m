function jc_resegment_df(batch,int,dur,threshstd,CHANSPEC)


ff=load_batchf(batch);

if strcmp(CHANSPEC,'w')
    fn = dir('background/*.wav');
    bgfn = fn.name;
    [dat fs] = audioread(['background/',bgfn]);
else
    fn = dir('background/*.cbin');
    bgfn = fn.name;
    [dat fs] = evsoundin('background',bgfn,'obs0');
end
bgsm = evsmooth(dat,fs,'','','',5);
bgsm = log(bgsm);
thresh = mean(bgsm)+threshstd*std(bgsm);%amplitude threshold for resegmentation

for i = 1:length(ff)
    fn = ff(i).name;
    fnn = [fn,'.not.mat'];
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
   
    if ~exist(fnn,'file')
        datsm = log(evsmooth(dat,fs,'','','',5));
        [ons offs] = SegmentNotes(datsm,fs,int,dur,thresh);%in seconds
        onsets = [];
        offsets = [];
        for ii = 1:length(ons)
            tempon = ons(ii);tempoff=offs(ii);
            temponsamp = floor(tempon*fs);
            tempoffsamp = ceil(tempoff*fs);
            if (temponsamp - 256) < 0 | (tempoffsamp + 256)>length(dat)
                continue
            end
            smtmp2 = dat(temponsamp-256:tempoffsamp+256);
            sm2 = evsmooth(smtmp2,fs,'','','',5);
            sm2 = log(sm2);
            sm2 = sm2-min(sm2);
            sm2 = sm2./max(sm2);
            abovethresh = find(sm2>=0.3);
            sm_ons = abovethresh(1);
            sm_offs = abovethresh(end);
            sm_onsamp = temponsamp-256+sm_ons;
            sm_offsamp = temponsamp-256+sm_offs;
            onsets = [onsets; (sm_onsamp/fs)];
            offsets = [offsets;(sm_offsamp/fs)];
        end
        labels = char(ones([1,length(onsets)])*fix('-'));
        onsets = onsets*1e3;
        offsets = offsets*1e3;
        min_int = int;
        min_dur = dur;
        threshold = exp(thresh);
        fname = fn;
        Fs = fs;
        sm_win = 2;
        cmd = ['save ',fn,'.not.mat fname sm_win Fs onsets offsets min_int min_dur threshold labels;'];
        eval(cmd);
        
    else
        load(fnn);
        labels = lower(labels);
        labels(findstr(labels,'0'))='-';
        
        datsm = log(evsmooth(dat,fs,'','','',5));
        ton = onsets(1);toff=offsets(end);%in ms
        onsamp = floor((ton*1e-3)*fs)-1600;
        offsamp = ceil((toff*1e-3)*fs)+1600;
        if onsamp<0 
            ton = onsets(2);toff=offsets(end);%in ms
            onsamp = floor((ton*1e-3)*fs)-1600;
            offsamp = ceil((toff*1e-3)*fs)+1600;
        elseif offsamp>length(dat)
            ton = onsets(1);toff=offsets(end-1);%in ms
            onsamp = floor((ton*1e-3)*fs)-1600;
            offsamp = ceil((toff*1e-3)*fs)+1600;
        elseif onsamp<0 & offsamp>length(dat)
            ton = onsets(2);toff=offsets(end-1);%in ms
            onsamp = floor((ton*1e-3)*fs)-1600;
            offsamp = ceil((toff*1e-3)*fs)+1600;
        end
        smtmp = dat(onsamp:offsamp);
        sm = evsmooth(smtmp,fs,'','','',5);
        sm = log(sm);
        [ons offs] = SegmentNotes(sm,fs,int,dur,thresh);%in seconds
        ons = ons+(onsamp/fs); offs = offs+(onsamp/fs);
        newonsets = [];
        newoffsets = [];
        for ii = 1:length(ons)
            tempon = ons(ii);tempoff=offs(ii);
            temponsamp = floor(tempon*fs);
            tempoffsamp = ceil(tempoff*fs);
            smtmp2 = dat(temponsamp-256:tempoffsamp+256);
            sm2 = evsmooth(smtmp2,fs,'','','',5);
            sm2 = log(sm2);
            sm2 = sm2-min(sm2);
            sm2 = sm2./max(sm2);
            abovethresh = find(sm2>=0.3);
            sm_ons = abovethresh(1);
            sm_offs = abovethresh(end);
            sm_onsamp = temponsamp-256+sm_ons;
            sm_offsamp = temponsamp-256+sm_offs;
            newonsets = [newonsets; (sm_onsamp/fs)];
            newoffsets = [newoffsets;(sm_offsamp/fs)];
        end

        labels2 = char(ones([1,length(newonsets)])*fix('-'));
        syllind = regexp(labels,'[a-z]');
        for ii = 1:length(syllind)
            nt = labels(syllind(ii));
            [~,minind] = min(abs(newonsets-onsets(syllind(ii))*1e-3));
            labels2(minind) = nt;
        end
        labels = labels2;

        onsets = newonsets*1e3;
        offsets = newoffsets*1e3;
        min_int = int;
        min_dur = dur;
        threshold = exp(thresh);
        cmd = ['save ',fn,'.not.mat onsets offsets min_int min_dur threshold labels -append;'];
        eval(cmd);
    end
end
    