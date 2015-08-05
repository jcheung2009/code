

[spect, nfft, spect_win, noverlap, t_min, t_max, f_min, f_max]=read_spect('test.20101105.0002.wav.spect')
[filtsong, Fs] = read_filt('test.20101105.0002.wav.filt');

freq_spect = [f_min, f_max];
time_spect = [t_min, t_max];   

% figure;
% set(gcf, 'Color', 'w');
% set(gcf, 'Position', [153 440 893 269]);
% axes('Position',[0.075 0.2 0.9 0.7]);
% cm = disp_idx_spect(spect, time_spect, freq_spect, -50, 10, 1.2, 'gray', 'classic');
% 
% axis([t_min t_max 300 8000]);
% set(gca, 'FontSize', 14, 'FontWeight', 'bold');
% xlabel('Time (sec)', 'FontSize', 14, 'FontWeight', 'bold');
% ylabel('Frequency (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
% title(filename, 'FontSize', 14, 'FontWeight', 'bold');

notes=load('results\test.20101105.0002.wav.not.mat');


%Display just one syllable:

figure;
startidx=notes.onsets*(Fs/1000);
stopidx=notes.offsets*(Fs/1000);
dt_spect=t_max/length(spect)
spect_idx=[notes.onsets(1)/dt_spect notes.offsets(1)/dt_spect]
a.spect=spect(:,spect_idx(1):spect_idx(2));
disp_idx_spect(a.spect, [0 (spect_idx(2)-spect_idx(1))*dt_spect], freq_spect, -50, 10, 1.2, 'gray', 'classic');


%  225:255;



a=filtsong(notes.onsets(1)+240*44.1:notes.onsets(1)+255*44.1);
[autocorr lag]=(xcorr(a))

dt=1/44.1;

figure;
plot(lag*dt,autocorr);

[trash idxb]=max(autocorr); % 0 offset peak by definition. 
[trash idx]=max(autocorr(1:idx-50));
harmonicfreq=dt*(lag(idx)-lag(idxb));



figure;
plot(filtsong);
hold on;

plot(startidx,0,'rx');
plot(stopidx,0,'gx');