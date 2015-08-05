function [snippets,trueIdx] = generatePrefabSpikes(numModels,numSpikes,noiseParameter)
%[snippets,trueIdx] = generatePrefabSpikes(numModels,numSpikes,noiseParameter)
% Generate up to three predetermined spikes waveforms in any number for
% testing purposes of spike sorting methods. Noise parameter controls
% gaussian noise options.

if(nargin == 0)
    noiseParameter = 2;
    numModels = 3;
    numSpikes = [5000,5000,5000]; %determines the mixture of spikes from the models
end

%make some waveforms to model
models = makeModels(numModels);  %currently supports up to 3 models, determine porportion below
numSpikes = numSpikes(1:numModels);
[samples,trueIdx] = makeSamples(models,numSpikes,noiseParameter);
%test scale, for experimental purposes only
scale =  1;
models = models*scale;
snippets = samples*scale;



function models = makeModels(numModels)
%creates up to three models
model1 = ...
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.5 .75 1 1.25 1.5 1.75 2 2.5 3 3.5 4 6 8 12 16 16 12 8 6 4 2 0 -2 -4 -5 -6 -7 -8 -7 -6 -5 -4 -3.5 -3 -2.5 -2 -1.75 -1.5 -1.25 -1 -.875 -.75 -.625 -.5 -.375 -.25 -.125 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
model2 = ...
    [ 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 .25 .5 .75 1 1.25 1.5 1.75 2 3 4 6 8 8 6 4 2 0 -2 -4 -6 -8 -6.5 -5 -3.5 -2 -1.75 -1.5 -1.25 -1 -0.875 -0.75 -0.625 -.5 -.25 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ];
model3 = ...
    [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 .5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 5.5 5 4.5 4 3.5 3 2.5 2 .5 -1 -2.5 -4 -7 -10 -13 -16 -16 -14 -12 -10 -8 -7 -6 -5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -.5 0 .5 1 1.5 2 1.75 1.5 1.25 1 0 0 0 0 0 0 0 0 0];
switch(numModels)
    case 1 
        models = model1;
    case 2
        models = [model1;model2];
    case 3
        models = [model1;model2;model3];
    otherwise
        error('An innappropriate number of models was selected');
end



function [samples,idx] = makeSamples(models,numInstances,noise)
%samples = makeSamples(models,numInstances,noise)
%given the models and the number of each to make, add gaussian noise with
%the given standard deviation
samples = zeros(sum(numInstances),size(models,2));
idx = zeros(sum(numInstances),1);
count = 0;
for i = 1:length(numInstances)
    for j = 1:numInstances(i);
        count = count+1;
        idx(count) = i;
        samples(count,:) = models(i,:)+noise*randn(1,size(models,2));
    end
end
%reorder them to avoid any dependency there
order = randperm(sum(numInstances));
idx = idx(order);
samples = samples(order,:);