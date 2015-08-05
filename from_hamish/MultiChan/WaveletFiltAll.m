
directoryname='wavefiltered';

if ~exist(directoryname)
    mkdir(directoryname);
end;


a=dir('AllSongsChan*.mat');

for i=1:length(a)
    load(a(i).name);
    data=wavefilter(data,6);
    save([directoryname '/' a(i).name],'data');
end



