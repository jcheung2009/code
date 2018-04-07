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
filename = 'combined_data_Pk35G27_MU_06_01_2007_1130_1215_PCA_CH2_TH_recommended.mat';
[dat fs] = evsoundin('','Pk35-G27-06012007.002.cbin','obs0r');
load Pk35-G27-06012007.002.cbin.not.mat
filtsong=bandpass(dat,fs,300,10000,'hanningffir');
ind = strfind(labels,'adefg')
ix = 1;
m = filtsong(floor((onsets(ind(ix)+2)-273)*1e-3*fs):ceil((onsets(ind(ix)+2)+323)*1e-3*fs));
[sp f tm] = jc_spectrogram(m,fs);
tm = tm-0.273;
figure;imagesc(tm,f,log(abs(sp)));axis('xy');colormap('hot');

