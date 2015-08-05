function jc_checkmotifraster(rhd_data,motif,shft)
%use to test that jc_plotmultitrialrasters is correctly pulling out motifs
%and spike times from rhd files. 
%plots two figures: 1) from jc_plotallrasters, 2) specs and rasters
%corresponding to every motif found in the specified rhd file. 

filename = uigetfile('*.rhd');


ind = find(arrayfun(@(x) strcmp(x.filename,filename),rhd_data));
song = rhd_data(ind).song;
amplifier_data = rhd_data(ind).amp_data;
t_amplifier = rhd_data(ind).t_amp;
fs = rhd_data(ind).Fs;
h = jc_plotallrasters(rhd_data,rhd_data(ind).filename);
figure(h);hold on;m = get(gcf,'children');ylim = get(m(1),'ylim');

load([filename,'.not.mat']);

motifind = strfind(labels,motif);
if isempty(ind)
    error('no motif in this file')
end

npre = 256;npost =256;
motifdata = [];
nms = fieldnames(rhd_data(ind).spiketimes);
for ii = 1:length(motifind)
    onsamp = floor(onsets(motifind(ii))*1e-3*fs)-npre;
    offsamp = ceil(offsets(motifind(ii)+length(motif)-1)*1e-3*fs)+npre;
    motifdata(ii).song = song(onsamp:offsamp);
    figure(h);hold on;p1 = patch([t_amplifier(onsamp) t_amplifier(offsamp) t_amplifier(offsamp) t_amplifier(onsamp)],...
        [ylim(1) ylim(1) ylim(2) ylim(2)],'k','Parent',m(1));set(p1,'FaceAlpha',0.50,'edgecolor','none');
    for p = 1:length(nms)
        cluster_class = rhd_data(ind).spiketimes.([nms{p}]);
        clusterind = find(cluster_class(:,2) >= onsamp & cluster_class(:,2) <= offsamp);
        spktms = cluster_class(clusterind,:);
        spktms(:,2) = spktms(:,2)-onsamp+1;
        motifdata(ii).spiketimes.([nms{p}]) = spktms;
    end
end

low_f = 300;
high_f = 10000;
figure; hold on;
for i = 1:length(motifdata)
    numcluster = 1;
    ylabel = {};
    if shft > 0
        motifdata(i).song =[zeros(1,shft) abs(motifdata(i).song(1:end-shft))];
    elseif shft < 0
        motifdata(i).song = [abs(motifdata(i).song(abs(shft)+1:end)) zeros(1,abs(shft))];
    end
    [~, spec t f] = evsmooth(motifdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
    subtightplot(2,length(motifdata),i,0.04,0.03,0.1);hold on;
    imagesc(t,f,log(abs(spec)));syn();axis tight; xlim = get(gca,'xlim');
    title(['spectrogram for motif ',num2str(i)]);
    for p = 1:length(nms)
        numclustersinchannel = length(unique(motifdata(i).spiketimes.(nms{p})(:,1)))-1;
        for ii = 1:numclustersinchannel
            clusterind = find(motifdata(i).spiketimes.([nms{p}])(:,1)==ii);
            rowvector = [numcluster*ones(1,length(clusterind));...
                (numcluster-1)*ones(1,length(clusterind))];
            if shft > 0
                spktms = (motifdata(i).spiketimes.([nms{p}])(clusterind,2)+shft)/fs;
            elseif shft < 0 
                spktms = (motifdata(i).spiketimes.([nms{p}])(clusterind,2)-abs(shft))/fs;
            elseif shft == 0
                spktms = (motifdata(i).spiketimes.([nms{p}])(clusterind,2))/fs;
            end
            h=subtightplot(2,length(motifdata),i+length(motifdata),0.04,0.03,0.1);hold on;
            plot(repmat(spktms',2,1),rowvector,'k-','color',...
                rand(1,3),'LineWidth',2);hold on;
            ylabel{numcluster} = ['unit ',num2str(ii),' in ',nms{p}];
            numcluster = numcluster+1;
        end
    end
    if i == 1
        set(h,'xlim',xlim,'color','none','xtick',[],'ytick',[1:length(ylabel)],'yticklabel',ylabel);
    else
        set(h,'xlim',xlim,'color','none','xtick',[],'ytick',[]);
    end
end
    
        
        

    