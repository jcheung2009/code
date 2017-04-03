%% parameters
%1 mm radius concentric circle roi, 15 divisions, each separation is ~66 microns
% recordratio = 4;%number of seconds between frames, the multiplying factor used to get the scene ratio when saving image sequence from vlc (3 seconds * 30 frames/second = ratio of 90)
% numquads = 8;
% numcircles = 15;
config
recordratio = params.recordratio;
numquads = params.numquads;
numcircles = params.numcircles;
baseline_time = 1:5;%index from image sequence that correspond to time prior to ejection, establish baseline intensity vals
dist_int = params.radius/numcircles;%distance interval between each concentric radius

fn = ls('*.csv');fn = fn(1:end-1);
data = csvread(fn,0,1);
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
%measure average baseline threshold im all quadrants
totalthresh = NaN(numquads,1);
for i = 1:numquads
    thresh = mean(mean(intvals.(['quad',num2str(i)])(baseline_time,:)))...
        +3*mean(std(intvals.(['quad',num2str(i)])(baseline_time,:)));
    totalthresh(i) = thresh;
end

%measure max relative concentration at each distance 
dist_vs_maxconc = NaN(numquads,numcircles);
for i = 1:numquads
    dist_vs_maxconc(i,:) = max(intvals.(['quad',num2str(i)]),[],1);
end
dist = round([1:numcircles]*dist_int,2);
dorsal_maxconc = mean(dist_vs_maxconc([6:7],:));
rightlateral_maxconc = mean(dist_vs_maxconc([1,8],:));
leftlateral_maxconc = mean(dist_vs_maxconc([4:5],:));
ventral_maxconc = mean(dist_vs_maxconc([2:3],:));

%fit with logistic regression and find spatial constants
f1 = fit(dist',dorsal_maxconc','exp1');b1 = coeffvalues(f1);
f2 = fit(dist',rightlateral_maxconc','exp1');b2 = coeffvalues(f2);
f3 = fit(dist',leftlateral_maxconc','exp1');b3 = coeffvalues(f3);
f4 = fit(dist',ventral_maxconc','exp1');b4 = coeffvalues(f4);
rc = -1*[b1(2);b2(2);b3(2);b4(2)].^-1; 
eval([fn(1:end-4),'_rc = rc;']);

%% plot results
%spectrogram showing intensity values/diffusion over time for quadrant1
%(right lateral)
figure;subtightplot(1,2,1,0.07,[0.1 0.05],0.1);
imagesc(intvals.quad1');hold on;
xlabel('seconds');ylabel('distance (mm)');
title('right lateral')
set(gca,'fontweight','bold','xtick',[1:8:numslices],'xticklabel',num2str([1:8:numslices]'*recordratio),...
    'ytick',[1:numcircles],'yticklabel',arrayfun(@num2str, dist,'unif',0));
%figure showing max rel concentration at each distance for each quadrant 
%quad6/7 = dorsal, quad1/8 = right lateral, quad4/5 = left lateral, quad2/3
%= ventral
subtightplot(1,2,2,0.07,[0.1 0.05],0.1);
plot(dist,feval(f1,dist),'linewidth',2);hold on;
plot(dist,feval(f2,dist),'linewidth',2);hold on;
plot(dist,feval(f3,dist),'linewidth',2);hold on;
plot(dist,feval(f4,dist),'linewidth',2);hold on;
legend({'dorsal','right lateral','left lateral','ventral'});
plot([dist(1) dist(end)],[mean(totalthresh) mean(totalthresh)],'--','color',[0.8 0.8 0.8],'linewidth',2);
xlabel('distance (mm)');ylabel('max concentration');
title(fn,'interpreter','none');
set(gca,'fontweight','bold');

clearvars -except *_rc
