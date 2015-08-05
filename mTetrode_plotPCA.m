function [] = mTetrode_plotPCA(tetstruct,PCAmtx,clustIDs,fs,plotspikes)
%
% function [] = mTetrode_plotPCA(tetstruct,PCAmtx,clustIDs,fs,plotspikes)
% 
% scatter plots of channel(1).peak vs channel(2).peak etc, colors points by cluster ID.
%
% plots overlaid extracted spikes, colored by cluster, from each channel if plotspikes = 1
%
% can use mTetrode_kmeans() to get cluster IDs
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds. all are scalar except waveform, which is a
% vector
% 
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc

numclusts = max(clustIDs);
structsize = size(tetstruct);
numchannels = structsize(2);

% generate distinct colors for each cluster
cmap = brighten(colormap(jet),.5);
colorvect = zeros(numclusts,3);
colorvect(1,:) = cmap(1,:);
for i=2:1:length(colorvect);
   coloridx = i*floor(length(cmap)/length(colorvect));
   colorvect(i,:) = cmap(coloridx,:);   
end

h=figure();hold on;title('peak vs peak')
for i=1:1:numclusts
    subplot(3,2,1);hold on;plot(tetstruct(1).peak(find(clustIDs==i)),tetstruct(2).peak(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,2);hold on;plot(tetstruct(1).peak(find(clustIDs==i)),tetstruct(3).peak(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,3);hold on;plot(tetstruct(1).peak(find(clustIDs==i)),tetstruct(4).peak(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,4);hold on;plot(tetstruct(2).peak(find(clustIDs==i)),tetstruct(3).peak(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,5);hold on;plot(tetstruct(2).peak(find(clustIDs==i)),tetstruct(4).peak(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,6);hold on;plot(tetstruct(3).peak(find(clustIDs==i)),tetstruct(4).peak(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
hold off;
tightfig(gcf);

% troughs
h=figure();hold on;title('trough vs trough')
for i=1:1:numclusts
    subplot(3,2,1);hold on;plot(tetstruct(1).trough(find(clustIDs==i)),tetstruct(2).trough(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,2);hold on;plot(tetstruct(1).trough(find(clustIDs==i)),tetstruct(3).trough(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,3);hold on;plot(tetstruct(1).trough(find(clustIDs==i)),tetstruct(4).trough(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,4);hold on;plot(tetstruct(2).trough(find(clustIDs==i)),tetstruct(3).trough(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,5);hold on;plot(tetstruct(2).trough(find(clustIDs==i)),tetstruct(4).trough(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
for i=1:1:numclusts
    subplot(3,2,6);hold on;plot(tetstruct(3).trough(find(clustIDs==i)),tetstruct(4).trough(find(clustIDs==i)),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end
hold off;
tightfig(gcf);

% widths
% h=figure();hold on;title('width vs width')
% for i=1:1:numclusts
%     subplot(3,2,1);hold on;plot(abs(tetstruct(1).width(find(clustIDs==i))),abs(tetstruct(2).width(find(clustIDs==i))),'o','Color',colorvect(i,:),'MarkerSize',3);
%     hold off;
% end
% for i=1:1:numclusts
%     subplot(3,2,2);hold on;plot(abs(tetstruct(1).width(find(clustIDs==i))),abs(tetstruct(3).width(find(clustIDs==i))),'o','Color',colorvect(i,:),'MarkerSize',3);
%     hold off;
% end
% for i=1:1:numclusts
%     subplot(3,2,3);hold on;plot(abs(tetstruct(1).width(find(clustIDs==i))),abs(tetstruct(4).width(find(clustIDs==i))),'o','Color',colorvect(i,:),'MarkerSize',3);
%     hold off;
% end
% for i=1:1:numclusts
%     subplot(3,2,4);hold on;plot(abs(tetstruct(2).width(find(clustIDs==i))),abs(tetstruct(3).width(find(clustIDs==i))),'o','Color',colorvect(i,:),'MarkerSize',3);
%     hold off;
% end
% for i=1:1:numclusts
%     subplot(3,2,5);hold on;plot(abs(tetstruct(2).width(find(clustIDs==i))),abs(tetstruct(4).width(find(clustIDs==i))),'o','Color',colorvect(i,:),'MarkerSize',3);
%     hold off;
% end
% for i=1:1:numclusts
%     subplot(3,2,6);hold on;plot(abs(tetstruct(3).width(find(clustIDs==i))),abs(tetstruct(4).width(find(clustIDs==i))),'o','Color',colorvect(i,:),'MarkerSize',3);
%     hold off;
% end
% hold off;
% tightfig(gcf);

% PCA
h=figure();hold on;title('PCA')
for i=1:1:numclusts
    hold on;plot(PCAmtx(find(clustIDs==i),1),PCAmtx(find(clustIDs==i),2),'o','Color',colorvect(i,:),'MarkerSize',4);
    hold off;
end

tightfig(gcf);

if(plotspikes)
    structsize = size(tetstruct);
    structsize = structsize(2); % number of channels
    timebase = maketimebase(length(tetstruct(1).waveform(1,:)),fs);
    figure();hold on;
    for i=1:1:structsize % each channel
        subplot(2,2,i);hold on;
        for clust=1:1:numclusts % each cluster
            spikenums = find(clustIDs==clust);
            %mTetrode_plotsomespikes2(tetstruct,i,fs,spikenums,colorvect(clust,:));
            mTetrode_plotavgspikes(tetstruct,i,fs,spikenums,colorvect(clust,:));  
        end
        hold off
    end
    hold off;
    tightfig(gcf);
end

ymax=0;ymin=0;

if(plotspikes)
    structsize = size(tetstruct);
    structsize = structsize(2); % number of channels
    timebase = maketimebase(length(tetstruct(1).waveform(1,:)),fs);
    figure();hold on;
    for i=1:1:(structsize) % each channel
        for clust=1:1:numclusts; % each cluster
           plotnum = clust+((i-1)*numclusts);
           subplot(structsize,numclusts,plotnum);
           spikenums = find(clustIDs==clust);
           [miny maxy] = mTetrode_plotsomespikes2(tetstruct,i,fs,spikenums,colorvect(clust,:));
           if(miny < ymin)
               ymin = miny;
           end
           if(maxy > ymax)
               ymax = maxy;
           end
           set(gca,'XTickLabel',[],'XTick',[]);set(gca,'YTickLabel',[],'YTick',[]);xlim([0,max(timebase)]);
        end
    end
    for i=1:1:(structsize) % each channel, set y axis limits
        for clust=1:1:numclusts; % each cluster
            plotnum = clust+((i-1)*numclusts);
            subplot(structsize,numclusts,plotnum);
            ylim([ymin,ymax]);
        end
    end
    hold off;
    tightfig(gcf);
end
