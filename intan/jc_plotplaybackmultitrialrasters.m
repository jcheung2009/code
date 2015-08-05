function [BOSdata spktms] = jc_plotplaybackmultitrialrasters(rhd_data,batchrhdBOS)

BOSdata = [];
BOSsongs = load_batchf(batchrhdBOS);
low_f = 300;
high_f = 10000;

for i = 1:length(BOSsongs)
    ind = find(arrayfun(@(x) strcmp(x.filename,BOSsongs(i).name),rhd_data)); 
    fs = rhd_data(ind).Fs;
    BOSdata(i).filename = rhd_data(ind).filename;
    BOSdata(i).song = rhd_data(ind).song;
    BOSdata(i).amp_data = rhd_data(i).amp_data;
    
    nms = fieldnames(rhd_data(ind).spiketimes);
    if i == 1
        [tempsm spec t f] = evsmooth(rhd_data(ind).song,fs,0.01,512,0.8,2,low_f,high_f);
        BOSdata(i).sm = tempsm;
        BOSdata(i).spec = log(abs(spec));
        BOSdata(i).spiketimes = rhd_data(ind).spiketimes;
    else
        sm = evsmooth(rhd_data(ind).song,fs,0.01,512,0.8,2,low_f,high_f);
        [corr lag] = xcorr(tempsm,sm);
        [~, k] = max(corr);
        shft = lag(k);
        if shft >= 0
            BOSdata(i).song = [zeros(1,shft) abs(BOSdata(i).song(1:end-shft))];
            [~,spec t f] = evsmooth(BOSdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
            BOSdata(i).spec = log(abs(spec));
            BOSdata(i).sm = [zeros(1,shft) sm(1:end-shft)];
            BOSdata(i).amp_data = [NaN(size(BOSdata(i).amp_data,1),shft)...
                BOSdata(i).amp_data(:,1:end-shft)];     
            for p = 1:length(nms)
                spktms = rhd_data(ind).spiketimes.([nms{p}]);
                spktms(:,2) = spktms(:,2)+shft;
                BOSdata(i).spiketimes.([nms{p}]) = spktms;
            end 
        elseif shft<0
            BOSdata(i).song = [abs(BOSdata(i).song(abs(shft)+1:end)) zeros(1,abs(shft))];
            [~,spec t f] = evsmooth(BOSdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
            BOSdata(i).spec = log(abs(spec));
            BOSdata(i).sm = [sm(abs(shft)+1:end) zeros(1,abs(shft))];
            BOSdata(i).amp_data = [BOSdata(i).amp_data(:,abs(shft)+1:end)...
                NaN(size(BOSdata(i).amp_data,1),abs(shft))]; 
            for p = 1:length(nms)
                spktms = rhd_data(ind).spiketimes.([nms{p}]);
                spktms(:,2) = spktms(:,2)-abs(shft);
                BOSdata(i).spiketimes.([nms{p}]) = spktms;
            end 
        end
    end
end

%% plot rasters of all trials with average aligned BOS
maxsonglength = max(arrayfun(@(x) length(x.sm),BOSdata));
avsm = cell2mat(arrayfun(@(x) [x.sm zeros(1,maxsonglength-length(x.sm))],BOSdata,'UniformOutput',false)');
avsm = mean(avsm,1);
timevector = [1/fs:1/fs:length(avsm)/fs];
maxspeclength = max(arrayfun(@(x) size(x.spec,2),BOSdata));
avsp = arrayfun(@(x) [x.spec zeros(size(x.spec,1),maxspeclength-size(x.spec,2))],BOSdata,'UniformOutput',false);
avsp = sum(cat(3,avsp{:}),3);
spectimevector = [(256/fs):(512-floor(0.8*512))/fs:(maxspeclength-1)*(512-floor(0.8*512))/fs];

figure;hold on;
subtightplot(2,1,1,0.04,0.03,0.1);imagesc(spectimevector,f,avsp);syn();h = get(gca,'xlim');
title('average spectrogram of BOS')
% subtightplot(3,1,2,0.06);plot(timevector,avsm,'k','linewidth',2);set(gca,'xlim',h);
% title('average amplitude envelop of motif')

numclustersineachtrial = cell2mat(arrayfun(@(x) structfun(@(y) max(unique(y(:,1))),x.spiketimes),BOSdata,'UniformOutput',false));
maxclustersineachtrial = max(numclustersineachtrial,[],2);
maxnumclusters = sum(max(numclustersineachtrial,[],2));
clustercolors = rand(maxnumclusters,3);
            
spktms = [];
for i = 1:length(BOSdata)
    nms = fieldnames(BOSdata(i).spiketimes);
    for ii = 1:length(nms)
        numclustersinchannel = maxclustersineachtrial(ii);
        for p = 1:numclustersinchannel
            clusterind = find(BOSdata(i).spiketimes.([nms{ii}])(:,1)==p);
            spktms.([nms{ii}]).(['unit',num2str(p)]).(['trial',num2str(i)])=...
                BOSdata(i).spiketimes.([nms{ii}])(clusterind,2)./fs;
        end
    end
end   


count = 1;
clustercount = 1;
channelnames = fieldnames(spktms);
ylabel = {};
for i = 1:length(channelnames)
    clusternames = fieldnames(spktms.([nms{i}]));
    for ii = 1:length(clusternames)
        trialnames = fieldnames(spktms.([nms{i}]).([clusternames{ii}]));
        for k = 1:length(trialnames)
            rowvector = [count*ones(1,length(spktms.([nms{i}]).([clusternames{ii}]).([trialnames{k}])));...
                (count-1)*ones(1,length(spktms.([nms{i}]).([clusternames{ii}]).([trialnames{k}])))];
            subtightplot(2,1,2,0.04,0.03,0.1);hold on;
            plot(repmat(spktms.([nms{i}]).([clusternames{ii}]).([trialnames{k}])',2,1),rowvector,'k-','color',...
                clustercolors(clustercount,:),'LineWidth',2);hold on;
            count = count+1;
        end
        ylabel{clustercount} = [clusternames{ii},' in ',channelnames{i}];
        clustercount = clustercount+1;
    end
end
title('rasters aligned to BOS')         
set(gca,'xlim',h,'color','none','xtick',[],'ytick',...
    [length(BOSdata):length(BOSdata):length(BOSdata)*clustercount],'yticklabel',ylabel);            
            
            
            