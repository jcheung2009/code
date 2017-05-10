function bout = jc_findbouts(batch,motifinfo,params,CHANSPEC)
%this function organizes spectrotemporal measurements by bout, also used
%for counting singing rate
%params specified by config 
%define bout by each song file 
%motifinfo from jc_findmotif
% measure_intro = 1 if intro notes should be measured, beginning of bout
% labelled "i"

motif=params.motif;
measure_intro = params.measure_intro;

ff = load_batchf(batch);
bout_cnt = 0;
for i = 1:length(ff)
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
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
    
    %number of motifs 
    try
        ind = find(arrayfun(@(x) strcmp(x.filename,ff(i).name),motifinfo));
    catch
        ind = find(arrayfun(@(x) strcmp(x.fn,ff(i).name),motifinfo));
    end
    if isempty(ind)
        continue
    end
    nummotifsinbout = length(ind);
    
    %number of intro notes at the beginning of bout
    if measure_intro == 1
        intronoteind = strfind(labels,'i');
        ton = onsets(intronoteind(1)); toff = offsets(intronoteind(end));
        onsamp = ceil((ton*1e-3)*fs) - 0.3*fs;%300 ms buffer before intro notes start
        if onsamp  < 1
            onsamp = 1;
        end
        offsamp = ceil((toff*1e-3)*fs)+0.03*fs;%30 ms buffer after intro notes 
        smtemp = dat(onsamp:offsamp);
        sm = evsmooth(smtemp,fs);
        sm2 = log(sm);
        sm2 = sm2./max(sm2);
        minint = 10;%gap
        mindur = 20;%syllable
        thresholdforsegmentation = graythresh(sm2);
        [ons offs] = SegmentNotes(sm2,fs,minint,mindur,thresholdforsegmentation);
        numintronotes = length(ons);

        intronoteduration = offs-ons;%seconds
        intronotegaps = ons(2:end)-offs(1:end-1);

        intronotevolume = [];
        for k = 1:length(ons)
            if ceil(offs(k)*fs) > length(smtemp)
                intronotevolume(k) = mean(smtemp(floor(ons(k)*fs):end).^2);
            else
                intronotevolume(k) = mean(smtemp(floor(ons(k)*fs):ceil(offs(k)*fs)).^2);
            end
        end
    end
    
    %pitch, volume, entropy, and tempo patterns of motif syllables within bout
    if length(motif) > 1
        boutvolume = [];
        boutpitch = [];
        boutentropy = [];
        bouttempo = [];
        boutacorr = [];
        for m = 1:length(ind)
            boutvolume = [boutvolume; motifinfo(ind(m)).syllvol];
            boutpitch = [boutpitch; motifinfo(ind(m)).syllpitch];
            boutentropy = [boutentropy; motifinfo(ind(m)).syllent];
            bouttempo = [bouttempo; motifinfo(ind(m)).motifdur];
            boutacorr = [boutacorr; motifinfo(ind(m)).firstpeakdistance];
        end
    elseif length(motif) == 1
        boutvolume = [];
        boutpitch = [];
        boutentropy = [];
        bouttempo = NaN(length(ind),1);
        boutacorr = NaN(length(ind),1);
        for m = 1:length(ind)
            boutvolume = [boutvolume; motifinfo(ind(m)).maxvol];
            boutpitch = [boutpitch; motifinfo(ind(m)).mxvals];
            boutentropy = [boutentropy; motifinfo(ind(m)).spent];
        end
    end
    
    bout_cnt = bout_cnt+1;
    bout(bout_cnt).filename = fn;
    bout(bout_cnt).datenm = motifinfo(ind(1)).datenm;
    bout(bout_cnt).nummotifs = nummotifsinbout;
    if measure_intro == 'y'
        bout(bout_cnt).numintro = numintronotes;
        bout(bout_cnt).intronoteduration = intronoteduration;
        bout(bout_cnt).intronotegaps = intronotegaps;
        bout(bout_cnt).intronotevolume = intronotevolume;
        bout(bout_cnt).logsm = sm2;
    end
    bout(bout_cnt).boutvolume = boutvolume;%volume of a syllable in each motif in the bout, columns are syllables
    bout(bout_cnt).boutpitch = boutpitch;
    bout(bout_cnt).boutentropy = boutentropy;
    bout(bout_cnt).bouttempo = bouttempo;% motif duration for each motif in bout
    bout(bout_cnt).boutacorr = boutacorr;
    if ~(strcmp(CHANSPEC,'w'))
        bout(bout_cnt).iscatch = rd.iscatch;
    end
    
end
    
    
    