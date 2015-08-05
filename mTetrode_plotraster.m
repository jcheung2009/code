function [] = mTetrode_plotraster(tetstruct,cbin,clustids,cluststoplot)
%
% [] = mTetrode_plotraster(tetstruct,cbin,clustids,cluststoplot)
%
% plots rasters of spikes detected from tetstruct and clustered via
% something like mTetrode_gmm() that specifies cluster identities for each
% spike in clustids. Only plots cluters specified in cluststoplot. cbin is a cbin file. Plots
% audio in cbin above rasters.
%

numclusts = max(clustids);

% generate distinct colors for each cluster
cmap = brighten(colormap(jet),.5);
colorvect = zeros(numclusts,3);
colorvect(1,:) = cmap(1,:);
for i=2:1:length(colorvect);
   coloridx = i*floor(length(cmap)/length(colorvect));
   colorvect(i,:) = cmap(coloridx,:);   
end

figh = figure();
stimh = subplot(3,1,[1:2]);mplotcbin(cbin,[]); % plots spectrogram of audio, change this if you want to plot raw audio/stim

for clustnum=1:length(cluststoplot)
    theclust = cluststoplot(clustnum);
    rasth = subplot(3,1,3);hold on;plot(tetstruct(1).times(find(clustids==theclust)),clustnum,'.','Color',colorvect(theclust,:))    
end
subplot(3,1,3);ylim([0 length(cluststoplot)+1]);
linkaxes([stimh rasth],'x');
set(rasth,'YTick',[]);
zoom xon;
hold off;
