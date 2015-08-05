function [h] = jc_plotallrasters(rhd_data,filename)

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

if ~isempty(song)
    numplots = 2;
else
    numplots = 1;
end

plotind = 1;
h = figure;
hold on;

if ~isempty(song)
    [smsong spec t f] = evsmooth(song,rhd_data(ind).Fs,0.01,512,0.8,2,low_f,high_f);
    subtightplot(numplots,1,plotind,0.04,0.03,0.1);
    t = t + t_amplifier(1);
    imagesc(t,f,log(abs(spec)));syn();axis('tight');xlim = get(gca,'xlim');
    title(['audio for ' filename],'interpreter','none');
    plotind = plotind + 1;
%     subtightplot(numplots,1,plotind,0.04,0.03,0.1);
%     plot(t_amplifier,(smsong/max(smsong))*1000,'k');set(gca,'xlim',xlim);
%     plotind = plotind + 1;
end

numcluster = 1;
nms = fieldnames(rhd_data(ind).spiketimes); 
ylabel = {};
for i = 1:length(nms)
    numclustersinchannel = length(unique(rhd_data(ind).spiketimes.(nms{i})(:,1)))-1;
    for ii = 1:numclustersinchannel
        clusterind = find(rhd_data(ind).spiketimes.(nms{i})(:,1) == ii);
        subtightplot(numplots,1,plotind,0.04,0.03,0.1);hold on;
        rowvector = [numcluster*ones(1,length(clusterind));(numcluster-1)*ones(1,length(clusterind))];
        plot(repmat(t_amplifier(rhd_data(ind).spiketimes.(nms{i})(clusterind,2)),2,1),rowvector,'k-','color',rand(1,3),'LineWidth',2);hold on;
        ylabel{numcluster} = ['unit ',num2str(ii),' in ',nms{i}];
        numcluster = numcluster + 1;
    end
end
set(gca,'xlim',xlim,'ylim',[0 length(ylabel)],'color','none','xtick',[],'ytick',[1:length(ylabel)],'yticklabel',ylabel);
title(['rasters for each cluster in all channels']);       
  