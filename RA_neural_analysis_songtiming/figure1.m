%% figure 1 gap 

%spectrogram, navigate to file with song files 
filename = 'combined_data_pu44w52_3_20_2006_1026_1125_PCA_CH2_TH_recommended.mat';
[dat fs] = evsoundin('','pu44w52_100x_200306_1041.52.cbin','obs0');
filtsong=bandpass(dat,fs,300,10000,'hanningffir');
ind = strfind(labels,'iabicd')
ix = 2;
m = filtsong(floor((offsets(ind(ix)+2)-275)*1e-3*fs):ceil((offsets(ind(ix)+2)+303)*1e-3*fs));
[sp f tm] = jc_spectrogram(m,fs);
tm = tm-0.275;
figure;imagesc(tm,f,log(abs(sp)));axis('xy');colormap('hot');

%% figure 1 syll
filename = 'combined_data_pu44w52_3_17_2006_1805-2025_PCA_CH2_TH_reco.mat';
[dat fs] = evsoundin('','pu44w52_100x_170306_1902.15.cbin','obs0');
load pu44w52_100x_170306_1902.15.cbin.not.mat
filtsong=bandpass(dat,fs,300,10000,'hanningffir');
ind = strfind(labels,'dijii')
ix = 1;
m = filtsong(floor((onsets(ind(ix)+2)-300)*1e-3*fs):ceil((onsets(ind(ix)+2)+243)*1e-3*fs));
[sp f tm] = jc_spectrogram(m,fs);
tm = tm-0.3;
figure;imagesc(tm,f,log(abs(sp)));axis('xy');colormap('hot');

