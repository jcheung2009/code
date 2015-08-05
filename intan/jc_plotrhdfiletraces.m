function jc_plotrhdfiletraces(rhd_data,filename)

if ~exist('filename')
    filename = uigetfile('*.rhd');
end

ind = find(arrayfun(@(x) strcmp(x.filename,filename),rhd_data));
song = rhd_data(ind).song;
amplifier_data = rhd_data(ind).amp_data;
t_amplifier = rhd_data(ind).t_amp;
    

high_f = 10000;
low_f = 300;
nyq = rhd_data(ind).Fs/2;
[a b]=butter(8,[low_f/nyq high_f/nyq]);

numampchan = rhd_data(ind).filedata.num_amplifier_channels;
if ~isempty(song)
    numplots = numampchan + 2;
else
    numplots = numampchan;
end

plotind = 1;
figure;
hold on;

if ~isempty(song)
    [smsong spec t f] = evsmooth(song,rhd_data(ind).Fs,0.01,512,0.8,2,low_f,high_f);
    subtightplot(numplots,1,plotind,0.04,0.03,0.05);
    t = t + t_amplifier(1);
    imagesc(t,f,log(abs(spec)));syn();axis('tight');xlim = get(gca,'xlim');
    title(['audio for ' filename],'interpreter','none');
    plotind = plotind + 1;
    subtightplot(numplots,1,plotind,0.04,0.03,0.05);
    plot(t_amplifier,(smsong/max(smsong))*1000,'k');set(gca,'xlim',xlim);
    plotind = plotind + 1;
end


for i = 1:size(amplifier_data,1)
     output=amplifier_data(i,:);
     SpikeOut=wavefilter(amplifier_data(i,:),6); % LP at ~250hz (i,:);
     SpikeOut=filtfilt(a,b,output); 
     subtightplot(numplots,1,plotind,0.04,0.03,0.05);
     plot(t_amplifier,SpikeOut,'k');set(gca,'xlim',xlim);
     title(['amplifier channel' num2str(i)]);
     plotind = plotind + 1;
end


