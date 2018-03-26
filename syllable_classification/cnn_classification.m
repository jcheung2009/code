%testing use of convolutional neural network to classify syllables

%% extract and process spectrograms for training and test data
%PCA whitening, no downsampling, log spectrograms are smoothed and min max normalized

%segmentation and audio params
fs = 32000;
dur = 0.1;%100 ms duration
onbuffer = 0.008*fs;%8 ms before onset
offbuffer = 0.092*fs-1;%92 ms after onset 
freq1 = 300;%lower freq thresh 
freq2 = 10000;%high freq thresh

%spectrogram params
NFFT = 512;%62.5 Hz resolution
overlap = NFFT-10;%269 frames, 0.37 ms resolution
w = NFFT;
f = (fs*(0:(NFFT/2))/NFFT);
indf = find(f>=freq1 & f <= freq2);
spsz = floor([length(indf) (dur*fs-overlap)/(w-overlap)]);
convwin = [3 6];%smoothing window 

songfiles = load_batchf('batch.keep.rand');xlabels = [];spdata = [];
for m = 1:63%1:length(songfiles)
    load([songfiles(m).name,'.not.mat']);
    [dat fs] = evsoundin('',songfiles(m).name,'obs0');
    dat = bandpass(dat,fs,300,10000,'hanningffir');
     ind = 1:length(labels);%find(isletter(labels));
    if ~isempty(ind)
        labels = labels(ind);onsets=onsets(ind);offsets=offsets(ind);
        sylldat = arrayfun(@(y) dat(floor(y*1e-3*fs)-onbuffer:...
            floor(y*1e-3*fs)+offbuffer),onsets,'un',0);
        [sp f] = cellfun(@(x) spectrogram(x,w,overlap,NFFT,fs),sylldat,'un',0);
        indf = cellfun(@(x) find(x>=freq1 & x<=freq2),f,'un',0);
        sp = cellfun(@(x,y) mat2gray(log(abs(x(y,:)))),sp,indf,'un',0);
        sp = cellfun(@(x) conv2(x,ones(convwin)./...
            (convwin(1)*convwin(2)),'same'),sp,'un',0);
        sp = cellfun(@(x) (x-min(x(:)))./max(x(:)),sp,'un',0);
        sigma = cellfun(@(x) x*x'/size(x,2),sp,'un',0);
        [U S] = cellfun(@(x) svd(x),sigma,'un',0);
        R = cellfun(@(x,y) x'*y,U,sp,'un',0);
        Rd = cellfun(@(x,y,z) x*diag(1./sqrt(diag(y)+1e-1))*z,U,S,R,'un',0);
        sp = cell2mat(cellfun(@(x) reshape(x,[],1),Rd,'un',0)');
        spdata = [spdata sp];
        xlabels = [xlabels labels];
    end
end


%% extract and process spectrograms for training and test data
% PCA whitening and regularization, no downsampling, spectrograms are smoothed
epsilon = 1e-1;
       sigma = spdata*spdata'/size(spdata,2);
        [U S] = svd(sigma);
        spRot = U'*spdata; 
        compvar = cumsum(diag(S))/sum(diag(S));
        numk = find(compvar >= 0.99);
        k = numk(1);
        spZCAWhite = U*diag(1./sqrt(diag(S)+epsilon))*spRot;

%         spPCAWhite = diag(1./sqrt(diag(S)+epsilon))*spRot;
%         spPCAWhite = spPCAWhite(1:k,:);
        %spHat = U(:,1:k)*spPCAWhite;
%% split data into train and test set
data = spdata;
datalabels = xlabels;
ind = randperm(size(data,2));
data = data(:,ind);
datalabels = datalabels(ind);
ind1 = floor(size(data,2)*0.7);

dataTrain = data(:,1:ind1);
dataTrain = reshape(dataTrain,spsz(1),spsz(2),1,size(dataTrain,2));
dataTest = data(:,ind1+1:end);
dataTest = reshape(dataTest,spsz(1),spsz(2),1,size(dataTest,2));

TrainLabels = datalabels(1:ind1);
TrainLabels = categorical(arrayfun(@(x) x,TrainLabels,'un',0))';
TestLabels = datalabels(ind1+1:end);
TestLabels = categorical(arrayfun(@(x) x,TestLabels,'un',0))';
numClasses = length(unique(datalabels));

%% inspired by alexnet
layers = [
    imageInputLayer([spsz 1]);
    
    convolution2dLayer(5,16,'Stride',3,'Padding',[1 0]);
    reluLayer();
    crossChannelNormalizationLayer(2)
    maxPooling2dLayer(3,'Stride',3,'Padding',[1 2]);
    
    convolution2dLayer(3,16,'Stride',1,'Padding','same');
    reluLayer();
    crossChannelNormalizationLayer(2)
    maxPooling2dLayer(3,'Stride',3,'Padding',[1 2]);
    
    convolution2dLayer(3,16,'Stride',1,'Padding','same');
    reluLayer();
    
    convolution2dLayer(3,16,'Stride',1,'Padding','same');
    reluLayer();
    
    convolution2dLayer(3,16,'Stride',1,'Padding','same');
    reluLayer();
    maxPooling2dLayer(3,'Stride',3,'Padding',[1 2]);
    
    fullyConnectedLayer(240);
    reluLayer();
    dropoutLayer;
    
    fullyConnectedLayer(240);
    reluLayer();
    dropoutLayer;
    
    fullyConnectedLayer(numClasses);
    softmaxLayer;
    classificationLayer];

%% 
layers = [
    imageInputLayer([spsz 1]);
    
    convolution2dLayer(5,16,'Stride',3,'Padding',[1 0]);
    batchNormalizationLayer
    reluLayer();
    dropoutLayer;
    maxPooling2dLayer(3,'Stride',3,'Padding',[1 2]);
    
    convolution2dLayer(3,16,'Stride',1,'Padding','same');
    batchNormalizationLayer
    reluLayer();
    dropoutLayer;
    maxPooling2dLayer(3,'Stride',3,'Padding',[1 2]);
    
    convolution2dLayer(3,16,'Stride',1,'Padding','same');
    batchNormalizationLayer
    reluLayer();
    dropoutLayer;
    maxPooling2dLayer(3,'Stride',3,'Padding',[1 2]);
    
    fullyConnectedLayer(240);
    reluLayer();
    dropoutLayer;
    
    fullyConnectedLayer(numClasses);
    softmaxLayer;
    classificationLayer];

%% training options
miniBatchSize = 100;
numIterationsPerEpoch = 5;
options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',10,...
    'InitialLearnRate',0.01,...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',5,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',{dataTest TestLabels},...
    'ValidationFrequency',numIterationsPerEpoch,...
    'ValidationPatience',Inf,...
    'L2Regularization',0.001);

netTransfer = trainNetwork(dataTrain,TrainLabels,layers,options);

%% extract and split data for autoencoder
data = spdata;
datalabels = xlabels;
ind = randperm(size(data,2));
data = data(:,ind);
datalabels = datalabels(ind);
ind1 = floor(size(data,2)*0.7);

dataTrain = data(:,1:ind1);
dataTrain = reshape(dataTrain,spsz(1),spsz(2),size(dataTrain,2));
dataTest = data(:,ind1+1:end);
dataTest = reshape(dataTest,spsz(1),spsz(2),size(dataTest,2));

TrainLabels = datalabels(1:ind1);
TrainLabels = categorical(arrayfun(@(x) x,TrainLabels,'un',0))';
TestLabels = datalabels(ind1+1:end);
TestLabels = categorical(arrayfun(@(x) x,TestLabels,'un',0))';
numClasses = length(unique(datalabels));

%% autoencoder 
hiddensize = 240;
autoenc1 = trainAutoencoder(num2cell(dataTrain,[1 2]),hiddensize,'L2WeightRegularization',0.004,...
    'SparsityRegularization',4,'SparsityProportion',0.15,'MaxEpochs',400);



