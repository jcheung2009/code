%fit gmm to spike waveforms in each file and extract posterior
%probabilities for each spike 
%extract raw neural trace 
fn = 'combined_data_B53O71_SU_05_05_2006_1530_1604_PCA_CH0_TH_recommended.mat';
load(fn);

%% extract waveforms for each spiketime detected for all clusters, maintain
%separate spiketime/index for largest cluster 
ff = load_batchf('batch');
rawwaveforms = [];
rawneuraldat = [];
mainspiketimes = [];mainspikeind = [];
for i = 1:length(ff)
    [dat fs] = evsoundin('',ff(i).name,'obs2');
    load([ff(i).name,'.neuralnot_CH2.mat']);
    filespiketimes = round([Data.spiketimes{1:end-1}]*fs);
    filespiketimes = [filespiketimes round(Data.spiketimes_from_recommended_TH*fs)];
    nsamp = Data.nsamp_wave;
    x = arrayfun(@(x) dat(x-nsamp(1):x+nsamp(2))',filespiketimes,'un',0)';
    rawwaveforms = [rawwaveforms; cell2mat(x)];
    mainspikeind = [mainspikeind;zeros(length([Data.spiketimes{1:end-1}]),1);...
        ones(length(Data.spiketimes_from_recommended_TH),1)];
    mainspiketimes = [mainspiketimes;length(rawneuraldat)/fs + Data.spiketimes_from_recommended_TH'];
    rawneuraldat = [rawneuraldat;dat];
end
assert(length(mainspiketimes)==length(spiketimes))
assert(isempty(find(ismembertol(mainspiketimes,spiketimes')~=1)))
assert(length(mainspikeind)==size(rawwaveforms,1))

%% pca waveforms and use scores to fit gmm
mainspikeind = logical(mainspikeind);
numclusters = size(Data.spiketimes,2);
[coeff,score] = pca(rawwaveforms);

%plot clusters in first two pca components
figure;scatter(score(:,1),score(:,2));
mdl = fitgmdist(score(:,1:2),numclusters);
[classes,~,p] = cluster(mdl,score(:,1:2));

%plot posteriors in each class 
figure;hold on;
for i = 1:numclusters
    [n b] = hist(p(:,i),[0:0.01:1]);hold on;
    stairs(b,n/sum(n));
end

%plot average waveform in each class, sort clusters by size of waveform
figure;hold on;
maxwaveamp = NaN(numclusters,1);
for i = 1:numclusters
    plot(mean(rawwaveforms(classes==i,:),1));hold on;
    maxwaveamp(i) = max(abs(mean(rawwaveforms(classes==i,:),1)));
end
[~,sortid] = sort(maxwaveamp);
p = p(:,sortid);

%% extract average waveform for main cluster
mainwaveform = arrayfun(@(x) rawneuraldat(x-nsamp(1):x+nsamp(2))',round(spiketimes*fs),'un',0)';
mainwaveform = cell2mat(mainwaveform);
figure;plot(mean(mainwaveform,1));

%% extract posteriors for spikes classified within main cluster
spikeposterior = p(mainspikeind,:);
%plot posterior for main cluster for spikes classified under that cluster
figure;hold on;
[n b] = hist(spikeposterior(:,end),[0:0.01:1]);
stairs(b,n/sum(n));
assert(size(spikeposterior,1)==length(spiketimes));

%% 
save(fn,'spikeposterior','mainwaveform','-append')

