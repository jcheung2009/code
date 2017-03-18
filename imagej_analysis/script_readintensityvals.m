%% parameters
%1 mm radius concentric circle roi, 15 divisions, each separation is ~66 microns
recordratio = 8;%image at every 3 seconds, the multiplying factor used to get the scene ratio when saving image sequence from vlc (3 seconds * 30 frames/second = ratio of 90)
numquads = 8;
numcircles = 15;
baseline_time = 1:5;%index from image sequence that correspond to time prior to ejection, establish baseline intensity vals

data = csvread('test_nanoject_03c_intmeas.csv',0,1);
data = data(:,[2:4:end]);
numslices = size(data,1);%number of images in sequence
intvals = struct();

%% normalize each quadrant by baseline and highest intensity val
for i = 1:numquads
    quaddat = data(:,i:numquads:end);
    meanbaseval = mean(mean(quaddat(baseline_time,:)));
    baseval = mean(quaddat(baseline_time,:));
    maxval = max(max(quaddat));
    quaddat = (quaddat-baseval)/(maxval-meanbaseval);
    intvals.(['quad',num2str(i)]) = quaddat;
end

%measure distance of spread and conc for each quadrant
dattable = NaN(numquads,4);
totalthresh = NaN(numquads,1);
for i = 1:numquads
    thresh = mean(mean(intvals.(['quad',num2str(i)])(baseline_time,:)))...
        +3*mean(std(intvals.(['quad',num2str(i)])(baseline_time,:)));
    [m ind] = max(max(intvals.(['quad',num2str(i)]),[],1));
    [m peaktime] = max(intvals.(['quad',num2str(i)])(:,ind));
    dist = find(intvals.(['quad',num2str(i)])(peaktime,:)>thresh);
    dist1 = dist(end)*0.066;%furthest distance of spread at peak intensity
    conc1 = intvals.(['quad',num2str(i)])(peaktime,dist(end));%conc at furthest distance at peak intensity
    for ii = 1:numcircles
        maxconc = find(intvals.(['quad',num2str(i)])(:,ii)>thresh);
        if ~isempty(maxconc) & ii ~=numcircles
            continue
        elseif ~isempty(maxconc) & ii==numcircles
            dist2 = (ii)*0.066;%furthest distance that sees conc above thresh
            conc2 = max(intvals.(['quad',num2str(i)])(:,ii));%highest conc at this distance
        elseif isempty(maxconc) 
            dist2 = (ii-1)*0.066;
            conc2 = max(intvals.(['quad',num2str(i)])(:,ii-1));
        end
    end
    dattable(i,:) = [dist1,conc1,dist2,conc2];
    totalthresh(i) = thresh;
end


%measure max relative concentration at each distance 
dist_vs_maxconc = NaN(numquads,numcircles);
for i = 1:numquads
    dist_vs_maxconc(i,:) = max(intvals.(['quad',num2str(i)]),[],1);
end
dist = [1:numcircles]*0.066;
dorsal_maxconc = mean(dist_vs_maxconc([6:7],:));
rightlateral_maxconc = mean(dist_vs_maxconc([1,8],:));
leftlateral_maxconc = mean(dist_vs_maxconc([4:5],:));
ventral_maxconc = mean(dist_vs_maxconc([2:3],:));

%fit with logistic regression and find spatial constant
[b1 dev stats] = glmfit(x,dorsal_maxconc,'normal','link','logit');
[b2 dev stats] = glmfit(x,rightlateral_maxconc,'normal','link','logit');
[b3 dev stats] = glmfit(x,leftlateral_maxconc,'normal','link','logit');
[b4 dev stats] = glmfit(x,ventral_maxconc,'normal','link','logit');


%% plot results
%spectrogram showing intensity values/diffusion over time for quadrant1
%(right lateral)
figure;subtightplot(1,2,1,0.07,[0.1 0.05],0.1);
thresh = mean(mean(intvals.quad1(baseline_time,:)))...
        +3*mean(std(intvals.quad1(baseline_time,:)));
[m ind] = max(max(intvals.quad1,[],1));
[m peaktime] = max(intvals.quad1(:,ind));
dist = find(intvals.quad1(peaktime,:)>thresh);
imagesc(intvals.quad1');hold on;
plot([peaktime peaktime],[1 dist(end)],'r','linewidth',2);
xlabel('seconds');ylabel('distance (mm)');
set(gca,'fontweight','bold','xtick',[1:8:numslices],'xticklabel',num2str([1:8:numslices]'*recordratio),...
    'ytick',[1:numcircles],'yticklabel',num2str([1:numcircles]'*0.066));
%figure showing max rel concentration at each distance for each quadrant 
%quad6/7 = dorsal, quad1/8 = right lateral, quad4/5 = left lateral, quad2/3
%= ventral
subtightplot(1,2,2,0.07,[0.1 0.05],0.1);
plot([1:numcircles]*0.066,mean(dist_vs_maxconc([6:7],:)),'linewidth',2);hold on;
plot([1:numcircles]*0.066,mean(dist_vs_maxconc([1,8],:)),'linewidth',2);hold on;
plot([1:numcircles]*0.066,mean(dist_vs_maxconc([4:5],:)),'linewidth',2);hold on;
plot([1:numcircles]*0.066,mean(dist_vs_maxconc([2:3],:)),'linewidth',2);hold on;
legend({'dorsal','right lateral','left lateral','ventral'});
plot([1 numcircles]*0.066,[mean(totalthresh) mean(totalthresh)],'--','color',[0.8 0.8 0.8],'linewidth',2);
xlabel('distance (mm)');ylabel('max concentration');
set(gca,'fontweight','bold');

%table showing for each quadrant, the furthest distance at peak intensity,
%concentration at that distance at peak intensity, furthest distance that
%experienced intensity greater than threshold, and concentration at that
%intensity
figure;
t = uitable('data',dattable);
t.ColumnName = {'peak distance','conc','furthest distance','conc'};
t.RowName = fieldnames(intvals);
t.Position(3:4) = t.Extent(3:4);