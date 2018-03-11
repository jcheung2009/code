%% figure 1 gap 

%spectrogram, navigate to file with song files 
filename = 'combined_data_G26G23_SU_5_28_2006_1020_1314_PCA_CH0_TH_recommended.mat';
[dat fs] = evsoundin('','G26-G23-05292006.200.cbin','obs0r');
load G26-G23-05292006.200.cbin.not.mat
filtsong=bandpass(dat,fs,300,10000,'hanningffir');
ind = strfind(labels,'abcddd')
ix = 2;
m = filtsong(floor((offsets(ind(ix)+2)-378)*1e-3*fs):ceil((offsets(ind(ix)+2)+304)*1e-3*fs));
[sp f tm] = jc_spectrogram(m,fs);
tm = tm-0.378;
figure;imagesc(tm,f,log(abs(sp)));axis('xy');colormap('hot');

%% figure 1 syll
filename = '.mat';
[dat fs] = evsoundin('','G26-G23-05282006.002.cbin','obs0r');
load G26-G23-05282006.002.cbin.not.mat
filtsong=bandpass(dat,fs,300,10000,'hanningffir');
ind = strfind(labels,'iabcd')
ix = 2;
m = filtsong(floor((onsets(ind(ix)+2)-379)*1e-3*fs):ceil((onsets(ind(ix)+2)+353)*1e-3*fs));
[sp f tm] = jc_spectrogram(m,fs);
tm = tm-0.379;
figure;imagesc(tm,f,log(abs(sp)));axis('xy');colormap('hot');

