function jc_playBOS(playbacklog, BOS, REV, CON)
%writes log file of when songs were played back
%create auditory stimuli folder with subfolders for BOS, REV, and CON_songs
%OR go into a folder containing all BOS/REV/CON and input the file names
%for each

if ~exist(playbacklog,'file')
    flog = fopen(playbacklog,'w');
else
    flog = fopen(playbacklog,'a');
end

ntrials = 75;
trialset = [ones(1,ntrials/3), zeros(1,ntrials/3) -1*ones(1,ntrials/3)];
trialset = trialset(randperm(ntrials));
if isempty(BOS)
    BOS = uigetfile;
    [song1 fs nbits] = wavread(['BOS/',BOS]);
else
    [song1 fs nbits] = wavread(BOS);
end
if isempty(REV)
    REV = uigetfile;
    song2 = wavread(['REV/',REV]);
else
    song2 = wavread(REV);
end
if isempty(CON)
    CON = uigetfile;
    song3 = wavread(['CON_songs/',CON]);
else
    song3 = wavread(CON);
end

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


