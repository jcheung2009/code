%fit gmm to spike waveforms in each file and extract posterior
%probabilities for each spike 
%extract raw neural trace 
fn = '';
load(fn);

%% extract waveforms for each spiketime detected for all clusters, maintain
%separate spiketime/index for largest cluster 
ff = load_batchf('batch');
rawwaveforms = [];
rawneuraldat = [];
mainspiketimes = [];mainspikeind = [];
for i = 1:length(ff)
    [dat fs] = evsoundin('',ff(i).name,'obs0');
    load([ff(i).name,'.neuralnot_CH0.mat']);
    filespiketimes = round([Data.spiketimes{:}]*fs);
    nsamp = Data.nsamp_wave;
    x = arrayfun(@(x) dat(x-nsamp(1):x+nsamp(2))',filespiketimes,'un',0)';
    rawwaveforms = [rawwaveforms; cell2mat(x)];
    [~,ia,ib] = intersect(filespiketimes,round(Data.spiketimes_from_recommended_TH*fs));
    mainspikeind = [mainspikeind;ia];
    mainspiketimes = [mainspiketimes;length(rawneuraldat)/fs + Data.spiketimes_from_recommended_TH'];
    rawneuraldat = [rawneuraldat;dat];
end

%% pca waveforms and use scores to fit gmm
numclusters = size(Data.spiketimes,2);
[classes,score] = pca(rawwaveforms);
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
%plot average waveform in each class
figure;hold on;
for i = 1:numclusters
    plot(mean(rawwaveforms(classes==i,:),1));hold on;
end

%extract average waveform for main cluster
mainwaveform = arrayfun(@(x) rawneuraldat(x-nsamp(1):x+nsamp(2))',round(mainspiketimes*fs),'un',0);
mainwaveform = cell2mat(mainwaveform);
mainwaveform = mean(mainwaveform,1);
figure;plot(mainwaveform);

%extract posteriors for spikes classified within main cluster
spikeposterior = p(mainspikeind,:);
figure;hold on;
[n b] = hist(spikeposterior(:,3),[0:0.01:1]);
stairs(b,n/sum(n));
assert(size(spikeposterior,1)==length(spiketimes));

save(fn,'spikeposterior','mainwaveform','-append')

