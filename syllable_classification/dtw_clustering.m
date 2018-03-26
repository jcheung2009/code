%test dtw method for syllable classification using gmm

ff = load_batchf('batch.keep');

ons = []; offs = []; lbls = []; filtsong = [];
tm = 0; 
for i = 1:20%1:length(ff)
    load([ff(i).name,'.not.mat']);
    ons = [ons;onsets+tm];
    offs = [offs;offsets+tm];
    lbls = [lbls labels];
    [dat fs] = evsoundin('',ff(i).name,'obs0');
    filtsong = [filtsong; bandpass(dat,fs,300,10000,'hanningffir')];
    tm = tm+(length(dat)*1000)/fs;
end

buff = 0.016*fs;
NFFT = 512;
overlap = NFFT-32;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

sylls = unique(lbls);
sylls = sylls(isletter(sylls));

templates = {};
for i = 1:length(sylls)
    ind = strfind(lbls,sylls(i));
    ix = ind(randsample(length(ind),10));
    for m = 1:length(ix)
        dat = filtsong(floor(ons(ix(m))*fs/1000)-buff:ceil(offs(ix(m))*fs/1000)+buff);
        sp = spectrogram(dat,w,overlap,NFFT,fs);
        sp = abs(sp);
        sp = sp./sum(sp,2);
        templates = [templates; sp];
    end
end

dist = NaN(length(lbls),length(templates));
for i = 1:length(templates)
    for ii = 1:length(lbls)
        dat = filtsong(floor(ons(ii)*fs/1000)-buff:ceil(offs(ii)*fs/1000)+buff);
        sp = spectrogram(dat,w,overlap,NFFT,fs);
        sp = abs(sp);
        sp = sp./sum(sp,2);
        dist(ii,i) = dtw(templates{i},sp);
    end
end


dist2 = dist;

[c,s,~,~,explained] = pca(dist2);
ind_comp = find(cumsum(explained)<99);
dist2 = dist2*c(:,ind_comp);

% dist2 = dist(:,randsample(size(dist,2),50));
% m1 = min(dist2,[],2);
% m2 = max(dist2,[],2);
% dist2 = (dist2-m1)./(m2-m1);


nrow = size(dist2,1);
n = floor(nrow/3);%three sets
lens = floor(nrow/n);
subset = cell(3,1);
for i = 1:3
    subset{i} = dist2((i-1)*n+1:i*n,:);
end


models = 2:16;
options = statset('MaxIter',10000);
aic=[];bic=[];
for m = 1:length(models)
    bics = [];aics = [];
    for y = 1:3
        testset = cell2mat(subset(y));
        trainset = cell2mat(subset(setdiff([1:3],y)));
        gmm = fitgmdist(trainset,models(m),'Options',options,'Replicates',5,'SharedCovariance',true,'CovarianceType','full','RegularizationValue',0.01);
        bics = [bics;gmm.BIC];
        aics = [aics; gmm.AIC];
    end
    aic=[aic;mean(aics)];
    bic=[bic;mean(bics)];
end

figure;plot(models,aic,'k.');title('aic');
figure;plot(models,bic,'k.');title('bic');
[~,ind] = min(bic);
numcomponents = models(ind)+2;

options = statset('MaxIter',100000);
gmm = fitgmdist(trainset,numcomponents,'Options',options,'Replicates',10,'SharedCovariance',true,'CovarianceType','full','RegularizationValue',0.01);
idx = cluster(gmm,dist2);

%validation
ons = []; offs = []; lbls = []; filtsong = [];
tm = 0; 
for i = 20:40%1:length(ff)
    load([ff(i).name,'.not.mat']);
    ons = [ons;onsets+tm];
    offs = [offs;offsets+tm];
    lbls = [lbls labels];
    [dat fs] = evsoundin('',ff(i).name,'obs0');
    filtsong = [filtsong; bandpass(dat,fs,300,10000,'hanningffir')];
    tm = tm+(length(dat)*1000)/fs;
end

dist = NaN(length(lbls),length(templates));
for i = 1:length(templates)
    for ii = 1:length(lbls)
        dat = filtsong(floor(ons(ii)*fs/1000)-buff:ceil(offs(ii)*fs/1000)+buff);
        sp = spectrogram(dat,w,overlap,NFFT,fs);
        sp = abs(sp);
        sp = sp./sum(sp,2);
        dist(ii,i) = dtw(templates{i},sp);
    end
end

dist2 = dist;
dist2 = dist2*c(:,ind_comp);%project into pca space 


idx = cluster(gmm,dist2);

for i = 1:numcomponents
    if ~isempty((find(idx==i)))
        figure;hold on;
        dat = cell2mat(arrayfun(@(x,y) filtsong(floor(x*fs/1000)-buff:ceil(y*fs/1000)+buff), ons(idx==i),offs(idx==i),'un',0));
        [sp f] = spectrogram(dat,w,overlap,NFFT,fs);
        ind = find(f>=300 & f<=10000);
        sp = abs(sp(ind,:));
        ind = find(abs(sp)<=mean(mean(abs(sp))));
        sp(ind)=mean(mean(abs(sp)))/2;
        imagesc(log(sp));axis('xy');;
    end
end