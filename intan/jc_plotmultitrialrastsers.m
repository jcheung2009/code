function [motifdata spktms]  = jc_plotmultitrialrastsers(rhd_data,motif)
%to visualize rasters aligned to target motif across all trials
%motif = string
%motifdata: structure where each index is a trial
%   filename
%   index: segment index in song file where motif is found
%   song: amplitude evenlop of motif
%   amp_data: raw signals from all amp channels corresponding to motif
%   spiketimes: structure with fields for each channel with units. Each
%       field/channel contains matrix of spike times in sample points
%       (right column) and unit number (left column)
%   sm: smoothed amp env of motif
%   spec: log of abs(spec) of motif
%spktms: structure with field names for each channel with units. Each
%   field/channel contains structure with fields for each unit in channel. 
%   Each unit field is structure with fields for each motif trial. 
%   Each field trial is vector of spike times in seconds

%% extract song and neural data from each file corresponding to motif
npre = 256;
npost = 256;

motifdata = [];
motifnum = 1;
for i = 1:length(rhd_data)
    if ~exist([rhd_data(i).filename,'.not.mat'])
        continue
    else
        load([rhd_data(i).filename,'.not.mat']);
    end
    
    ind = strfind(labels,motif);
    if isempty(ind)
        continue
    end
    
    fs = rhd_data(i).Fs;
    nms = fieldnames(rhd_data(i).spiketimes);
    for ii = 1:length(ind)
        onsamp = floor(onsets(ind(ii))*1e-3*fs)-npre;
        offsamp = ceil(offsets(ind(ii)+length(motif)-1)*1e-3*fs)+npre;
        motifdata(motifnum).filename = rhd_data(i).filename;
        motifdata(motifnum).index = ind(ii);%label index in song file
        motifdata(motifnum).song = rhd_data(i).song(onsamp:offsamp);
        motifdata(motifnum).amp_data = rhd_data(i).amp_data(:,onsamp:offsamp);%for all channels
        for p = 1:length(nms)
            cluster_class = rhd_data(i).spiketimes.([nms{p}]);
            clusterind = find(cluster_class(:,2) >= onsamp & cluster_class(:,2) <= offsamp);
            spktms = cluster_class(clusterind,:);
            spktms(:,2) = spktms(:,2)-onsamp+1;
            motifdata(motifnum).spiketimes.([nms{p}]) = spktms;
        end
        motifnum = motifnum+1;
    end
end

%% aligning song and neural data by first motif exemplar
low_f = 300;
high_f = 10000;
for i = 1:length(motifdata)
    nms = fieldnames(motifdata(i).spiketimes);
    if i == 1
        [tempsm spec t f] = evsmooth(motifdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
        motifdata(i).sm = tempsm;
        motifdata(i).spec = log(abs(spec));
    else
        sm = evsmooth(motifdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
        [corr lag] = xcorr(tempsm,sm);
        [c k] = max(corr);
        shft = lag(k);
        if shft >= 0
            motifdata(i).song = [zeros(1,shft) abs(motifdata(i).song(1:end-shft))];
            [~,spec t f] = evsmooth(motifdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
            motifdata(i).spec = log(abs(spec));
            motifdata(i).sm = [zeros(1,shft) sm(1:end-shft)];
            motifdata(i).amp_data = [NaN(size(motifdata(i).amp_data,1),shft)...
                motifdata(i).amp_data(:,1:end-shft)];
            for p = length(nms)
                spktms = motifdata(i).spiketimes.([nms{p}])(:,2);
                motifdata(i).spiketimes.([nms{p}])(:,2) = spktms+shft;
            end 
        elseif shft < 0
            motifdata(i).song = [abs(motifdata(i).song(abs(shft)+1:end)) zeros(1,abs(shft))];
            [~,spec t f] = evsmooth(motifdata(i).song,fs,0.01,512,0.8,2,low_f,high_f);
            motifdata(i).spec = log(abs(spec));
            motifdata(i).sm = [sm(abs(shft)+1:end) zeros(1,abs(shft))];
            motifdata(i).amp_data = [motifdata(i).amp_data(:,abs(shft)+1:end)...
                NaN(size(motifdata(i).amp_data,1),abs(shft))];
            for p = length(nms)
                spktms = motifdata(i).spiketimes.([nms{p}])(:,2);
                motifdata(i).spiketimes.([nms{p}])(:,2) = spktms-abs(shft);
            end
        end  
    end
end

%% plot rasters of all trials with average aligned song 
maxsonglength = max(arrayfun(@(x) length(x.sm),motifdata));
avsm = cell2mat(arrayfun(@(x) [x.sm zeros(1,maxsonglength-length(x.sm))],motifdata,'UniformOutput',false)');
avsm = mean(avsm,1);
timevector = [1/fs:1/fs:length(avsm)/fs];
maxspeclength = max(arrayfun(@(x) size(x.spec,2),motifdata));
avsp = arrayfun(@(x) [x.spec zeros(size(x.spec,1),maxspeclength-size(x.spec,2))],motifdata,'UniformOutput',false);
avsp = sum(cat(3,avsp{:}),3);
spectimevector = [(256/fs):(512-floor(0.8*512))/fs:(maxspeclength-1)*(512-floor(0.8*512))/fs];%parameters from evsmooth

figure;hold on;
subtightplot(2,1,1,0.04,0.03,0.1);imagesc(spectimevector,f,avsp);syn();h = get(gca,'xlim');
title('average spectrogram of motif')
% subtightplot(3,1,2,0.06);plot(timevector,avsm,'k','linewidth',2);set(gca,'xlim',h);
% title('average amplitude envelop of motif')

numclustersineachtrial = cell2mat(arrayfun(@(x) structfun(@(y) max(unique(y(:,1))),x.spiketimes),motifdata,'UniformOutput',false));
maxclustersineachtrial = max(numclustersineachtrial,[],2);
maxnumclusters = sum(max(numclustersineachtrial,[],2));
clustercolors = rand(maxnumclusters,3);

spktms = [];
for i = 1:length(motifdata)
    nms = fieldnames(motifdata(i).spiketimes);
    for ii = 1:length(nms)
        numclustersinchannel = maxclustersineachtrial(ii);
        for p = 1:numclustersinchannel
            clusterind = find(motifdata(i).spiketimes.([nms{ii}])(:,1)==p);
            spktms.([nms{ii}]).(['unit',num2str(p)]).(['trial',num2str(i)])=...
                motifdata(i).spiketimes.([nms{ii}])(clusterind,2)./fs;
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
title('rasters aligned to motif')         
set(gca,'xlim',h,'color','none','xtick',[],'ytick',...
    [length(motifdata):length(motifdata):length(motifdata)*(clustercount-1)],...
    'ylim',[0 length(motifdata)*(clustercount-1)],'yticklabel',ylabel);

            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
