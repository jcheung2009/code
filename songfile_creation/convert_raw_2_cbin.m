function [] = convert_raw_2_cbin(rawfile)


[song,fs] = soundin('',char(rawfile),'raw');
songfile = rawfile(1:end-4);
make_obs(songfile,song)