function jc_playBOS(playbacklog, BOS, REV, CON)
%writes log file of when songs were played back
%create auditory stimuli folder with subfolders for BOS, REV, and CON_songs
%OR go into a folder containing all BOS/REV/CON and input the file names
%for each
%if BOS/REV/CON == 0, will only play the ones with identifiers
%use '' to trigger uigetfile

if ~exist(playbacklog,'file')
    flog = fopen(playbacklog,'w');
else
    flog = fopen(playbacklog,'a');
end

count = 0;
if isempty(BOS)
    BOS = uigetfile;
   [song1 fs nbits] = wavread(['BOS/',BOS]);
elseif BOS == 0
    song1 = [];
    count = count+1;
else
    [song1 fs nbits] = wavread(BOS);
end
if isempty(REV)
    REV = uigetfile;
    [song2 fs nbits] = wavread(['REV/',REV]);
elseif REV == 0
    song2 = [];
    count = count+1;
else
    [song2 fs nbits] = wavread(REV);
end
if isempty(CON)
    CON = uigetfile;
    [song3 fs nbits] = wavread(['CON_songs/',CON]);
elseif CON == 0
    song3 = [];
    count = count+1;
else
    [song3 fs nbits] = wavread(CON);
end

ntrials = 14;
if count == 1 %only two types of songs
    if BOS == 0
        trialset = [zeros(1,ntrials/2) -1*ones(1,ntrials/2)];
    elseif REV == 0
        trialset = [ones(1,ntrials/2) -1*ones(1,ntrials/2)];
    elseif CON == 0
        trialset = [ones(1,ntrials/2) zeros(1,ntrials/2)];
    end
elseif count == 0 %all three types of songs
    trialset = [ones(1,ntrials/3), zeros(1,ntrials/3) -1*ones(1,ntrials/3)];
elseif count == 2 %only one type of song
    if BOS == 0 & REV == 0
        trialset = [-1*ones(1,ntrials)];
    elseif BOS == 0 & CON == 0
        trialset = [zeros(1,ntrials)];
    elseif REV == 0 & CON == 0
        trialset = [ones(1,ntrials)];
    end
end
trialset = trialset(randperm(ntrials));

for i = 1:ntrials
    if trialset(i) == 1
        t = now;
        sound(song1,fs,nbits);
        fprintf(flog,'%s\n',[datestr(t),' ',BOS,' BOS']);
    elseif trialset(i) == 0
        t = now;
        sound(song2,fs,nbits);
        fprintf(flog,'%s\n',[datestr(t),' ',REV,' REV']);
    elseif trialset(i) == -1
        t = now;
        sound(song3,fs,nbits);
        fprintf(flog,'%s\n',[datestr(t),' ',CON,' CON']);
    end
    pause(8);    
end

fclose(flog);