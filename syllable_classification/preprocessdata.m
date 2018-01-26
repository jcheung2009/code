
%% extract spectrograms and save as jpgs 
ff = load_batchf('batch');
buffer = 16;

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);
c = jet(64);
for i = 1%1:length(ff)
    if ~isempty(strfind(ff(i).name,'sal'))
        cd(ff(i).name)
        if ~exist('specdata')
            mkdir('specdata');
        end
        songfiles = load_batchf('batch.keep.rand');xlabels = {};
        for m = 1:length(songfiles)
            load([songfiles(m).name,'.not.mat']);
            [dat fs] = evsoundin('',songfiles(m).name,'obs0');
            dat = bandpass(dat,fs,300,10000,'hanningffir');
            ind = find(isletter(labels));
            if ~isempty(ind)
                labels = labels(ind);onsets=onsets(ind);offsets=offsets(ind);
                sylldat = arrayfun(@(y,z) dat(floor((y-buffer)*1e-3*fs):...
                    ceil((z+buffer)*1e-3*fs)),onsets,offsets,'un',0);
                [sp f] = cellfun(@(x) spectrogram(x,w,overlap,NFFT,fs),sylldat,'un',0);
                indf = cellfun(@(x) find(x>=300 & x<=10000),f,'un',0);
                sp = cellfun(@(x,y) log(abs(x(y,:))),sp,indf,'un',0);
                scale = cellfun(@(x) round(interp1(linspace(min(x(:)),max(x(:)),size(c,1)),1:size(c,1),x)),sp,'un',0);
                sprgb = cellfun(@(x) reshape(c(x,:),[size(x),3]),scale,'un',0);
                sprgb = cellfun(@(x) imresize(x,[28 28]),sprgb,'un',0);
                labels = mat2cell(labels,1,repmat(1,1,length(labels)));
                indices = mat2cell(1:length(labels),1,repmat(1,1,length(labels)));
                cellfun(@(x,y,z) imwrite(x,[songfiles(m).name,num2str(z),y,'.jpg']),...
                    sprgb,labels',indices');  
                xlabels = [xlabels labels];
                !mv *.jpg specdata/
            end
        end
        xlabels = categorical(xlabels);
        save('specdata/xlabels.mat','xlabels');
        cd ../
    end
end
%% transfer learning with convolutional network
load 1_18_2014_sal/specdata/xlabels.mat;
ds = imageDatastore('1_18_2014_sal/specdata');
ds.Labels = xlabels;
[XTrain XTest] = splitEachLabel(ds,0.7,'randomized');
net = alexnet;
layersTransfer = net.Layers(1:end-3);
numClasses = numel(unique(XTrain.Labels));

layers = [
    imageInputLayer([28 28 3]);
    convolution2dLayer(3,16);
    reluLayer();
    crossChannelNormalizationLayer(5);
    dropoutLayer;
    maxPooling2dLayer(2,'Stride',2);
    convolution2dLayer(3,32);
    reluLayer();
    crossChannelNormalizationLayer(5);
    dropoutLayer;
    maxPooling2dLayer(2,'Stride',2);
    fullyConnectedLayer(numClasses);
    softmaxLayer;
    classificationLayer];

miniBatchSize = 100;
numIterationsPerEpoch = 5;
options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',80,...
    'InitialLearnRate',0.01,...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',5,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',XTest,...
    'ValidationFrequency',numIterationsPerEpoch,...
    'ValidationPatience',Inf,...
    'L2Regularization',0.01);

netTransfer = trainNetwork(XTrain,layers,options);
