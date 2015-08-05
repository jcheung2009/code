close all; clear all; clc

data = load('~/data/doupe_lab/stimuli/syllable_database.mat')
data = data.data; 
ksyl = 12;

fig = figure;
for snr = [100 50 40 30 20 15 12.5 10 9 8 7 6 5 4 3 2 1]
nwf = add_noise(data.syllables(ksyl).wf,snr);
figure(fig)
subplot(2,2,1)
t = (1:length(data.syllables(ksyl).wf))/data.fs; 
plot_bird_ossiligram(t,data.syllables(ksyl).wf,'norm_type',1);
subplot(2,2,3)
plot_bird_spectrogram(data.syllables(ksyl).wf,data.fs); 
subplot(2,2,2)
plot_bird_ossiligram(t,nwf,'norm_type',1);
subplot(2,2,4)
plot_bird_spectrogram(nwf,data.fs); 


ap = audioplayer(data.syllables(ksyl).wf, data.fs); 
ap.play();
pause(.5);
ap = audioplayer(nwf, data.fs);
ap.play(); 
pause(1)
end