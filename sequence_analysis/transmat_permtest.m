salseq = [];
ff = load_batchf('batch.keep');
for i = 106:156
    load([ff(i).name,'.not.mat']);
    salseq = [salseq labels];
end

nseq = [];
ff = load_batchf('batch.keep');
for i = 157:length(ff)
    load([ff(i).name,'.not.mat']);
    nseq = [nseq labels];
end

salseq = salseq(find(isletter(salseq)));
nseq = nseq(find(isletter(nseq)));
salseq(strfind(salseq,'d')) = [];
nseq(strfind(nseq,'d')) = [];

sylls = unique(seq);
numseqsal = NaN(1,length(salseq));
for i = 1:length(sylls)
    numseqsal(strfind(salseq,sylls(i))) = i;
end
salmat = getTransitionMatrix(numseqsal,1);

numseqdrug = NaN(1,length(nseq));
for i = 1:length(sylls)
    numseqdrug(strfind(nseq,sylls(i))) = i;
end
naspmmat = getTransitionMatrix(numseqdrug,1);

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
difftest = NaN(ntrials,1);
for i = 1:ntrials
    shuffpool = pooled(randperm(length(pooled),length(pooled)));
    salsamp = shuffpool(1:nsal);
    drugsamp = shuffpool(nsal+1:end);
    salsamp = cell2mat(salsamp');
    drugsamp = cell2mat(drugsamp');
    salsamp(strfind(salsamp,'d')) = [];
    drugsamp(strfind(drugsamp,'d')) = [];
    salsamp  = salsamp(find(isletter(salsamp)));
    drugsamp = drugsamp(find(isletter(drugsamp)));
    sal = NaN(1,length(salsamp));
    drug = NaN(1,length(drugsamp));
    for n = 1:length(sylls)
        sal(strfind(salsamp,sylls(n))) = n;
        drug(strfind(drugsamp,sylls(n))) = n;
    end
    sal = getTransitionMatrix(sal,1);
    drug = getTransitionMatrix(drug,1);
    drug = drug./sum(drug,2);
    sal = sal./sum(sal,2);
    difftest(i) = sum(sum((drug-sal).^2));
end

    