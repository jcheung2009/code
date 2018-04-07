salseq = [];
ff = load_batchf('batch.keep');
for i = 1:length(ff)
    load([ff(i).name,'.not.mat']);
    salseq = [salseq labels];
end

nseq = [];
ff = load_batchf('batch.keep');
for i = 106:length(ff)
    load([ff(i).name,'.not.mat']);
    nseq = [nseq labels];
end

seq = seq(find(isletter(seq)));
sylls = unique(seq);
numseq = NaN(1,length(seq));
for i = 1:length(sylls)
    numseq(strfind(seq,sylls(i))) = i;
end

[tmat st] = getTransitionMatrix(numseq,1);

naspmmat = naspmmat./sum(naspmmat,2)
salmat = salmat./sum(salmat,2);

df = sum(sum((naspmmat-salmat).^2));

salseq = {};
ff = load_batchf('batch.keep');
for i = 1:length(ff)
    load([ff(i).name,'.not.mat']);
    salseq = [salseq; labels];
end

nseq = {};
ff = load_batchf('batch.keep');
for i = 106:length(ff)
    load([ff(i).name,'.not.mat']);
    nseq = [nseq; labels];
end


ntrials = 1000;
pooled = [salseq;nseq];
nsal = length(salseq);
ndrug = length(nseq);
for i = 1:ntrials
    shuffpool = pooled(randperm(length(pooled),length(pooled)));
    salsamp = shuffpool(1:nsal);
    drugsamp = shuffpool(nsal+1:end);
    salsamp = cell2mat(salsamp');
    drugsamp = cell2mat(drugsamp');
    salsamp(strfind(salsamp,'d')) = [];
    drugsamp(strfind(drugsamp,'d')) = [];
    sal = NaN(1,length(salsamp));
    drug = NaN(1,length(drugsamp));
    for i = 1:length(sylls)
        sal(i) = 
    