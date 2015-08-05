function [kidx] = mTetrode_kmeans(tetstruct,numclusts,maxclusts,fs,plotit)
% [] = mTetrode_kmeans(tetstruct,numclusts,fs,plotit)
%
% kmeans clustering of extracted spike data (peak, trough, width) in
% tetstruct
%
% set numclusts to 0 if you want kmeans to estimate number of clusters,
% fewer than maxclust. Setting maxclusts > 1000 will make this take
% forever, unless you don't have many spikes in tetstruct
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds. all elements of struct are scalar except {}.waveform, which is a
% vector
% 
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc

disttype = 'sqEuclidean';
nummeasures = 3; % number of measurements in tetstruct, default is 3 (peak, trough, width)

structsize = size(tetstruct);
structsize = structsize(2); % number of channels
spikecount = length(tetstruct(1).peak); % number of spikes/measurements 

% assemble data matrix for clustering
dataMtx = zeros(spikecount,structsize*nummeasures);
for i=1:1:structsize % each channel
    dataMtx(:,i) = tetstruct(i).peak;
    dataMtx(:,i+structsize) = tetstruct(i).trough;
    dataMtx(:,i+(structsize*2)) = tetstruct(i).width;    
end

if(numclusts)
    [kidx kc ksumd kd] = kmeans(dataMtx,numclusts,'distance',disttype);
else
    sumvect=zeros(maxclusts,1);sumvect(:,1) = inf;
        figure();hold on;
        for i=1:1:maxclusts % find best number of clusters by maximizing mean silhouette scores
           [kidx kc ksumd kd] = kmeans(dataMtx,i,'distance',disttype,'replicates',3,'emptyaction','drop');
           subplot(2,ceil(maxclusts/2),i);[silvals silfig] = silhouette(dataMtx,kidx,disttype);
           set(get(gca,'Children'),'FaceColor',[1 .75 .75])
           sumvect(i) = mean(silvals);
           title(num2str(sumvect(i)));
        end
        hold off
    [maxsum numclusts] = max(sumvect);
    dispstr = [num2str(numclusts) ' optimal clusters'];
    disp(dispstr);
    [kidx kc ksumd kd] = kmeans(dataMtx,numclusts,'distance',disttype);
end

% silhouette value plotting
figure();
[silhvals silfig] = silhouette(dataMtx,kidx,disttype);
set(get(gca,'Children'),'FaceColor',[1 .75 .75]);

if(plotit)
   mTetrode_plotKmeans(tetstruct,kidx,fs,1);    
end