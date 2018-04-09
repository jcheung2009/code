fileid = 35;
batch = 'batch.keep.rand.keep';

salseq = [];
ff = load_batchf(batch);
for i = 1:fileid%length(ff)
    load([ff(i).name,'.not.mat']);
    salseq = [salseq labels];
end

nseq = [];
ff = load_batchf(batch);
for i = fileid+1:length(ff)
    load([ff(i).name,'.not.mat']);
    nseq = [nseq labels];
end


sylls = unique(salseq);
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

ix = strfind(sylls,'-');
salmat(ix,:) = [];
salmat(:,ix) = [];
naspmmat(ix,:) = [];
naspmmat(:,ix) = [];

naspmmat = naspmmat./sum(naspmmat,2);
salmat = salmat./sum(salmat,2);

salseq2 = {};
ff = load_batchf(batch);
for i = 1:fileid%length(ff)
    load([ff(i).name,'.not.mat']);
    salseq2 = [salseq2; labels];
end

nseq2 = {};
ff = load_batchf(batch);
for i = fileid+1:length(ff)
    load([ff(i).name,'.not.mat']);
    nseq2 = [nseq2; labels];
end

ntrials = 10000;
pooled = [salseq2;nseq2];
nsal = length(salseq2);
ndrug = length(nseq2);
difftest = NaN(ntrials,1);
enttest = NaN(size(naspmmat,1),ntrials);
diffprob = NaN(size(naspmmat,1),ntrials);
for i = 1:ntrials
    shuffpool = pooled(randperm(length(pooled),length(pooled)));
    salsamp = shuffpool(1:nsal);
    drugsamp = shuffpool(nsal+1:end);
    salsamp = cell2mat(salsamp');
    drugsamp = cell2mat(drugsamp');
    sal = NaN(1,length(salsamp));
    drug = NaN(1,length(drugsamp));
    for n = 1:length(sylls)
        sal(strfind(salsamp,sylls(n))) = n;
        drug(strfind(drugsamp,sylls(n))) = n;
    end
    sal = getTransitionMatrix(sal,1);
    drug = getTransitionMatrix(drug,1);
    
    sal(ix,:) = [];
    sal(:,ix) = [];
    drug(ix,:) = [];
    drug(:,ix) = [];

    drug = drug./sum(drug,2);
    sal = sal./sum(sal,2);
    
    difftest(i) = sum(sum((drug-sal).^2));
    
    salent = (sal.*log2(sal))./log2(length(sylls));
    salent(find(isnan(salent))) = 0;
    salent = -sum(salent,2);
    drugent = (drug.*log2(drug))./log2(length(sylls));
    drugent(find(isnan(drugent))) = 0;
    drugent = -sum(drugent,2);
    enttest(:,i) =sum((salent-drugent).^2,2);
    
    diffprob(:,i) = sum((drug-sal).^2,2);
    
end

%sum squared difference of all transitions
df = sum(sum((naspmmat-salmat).^2));
%sum sq diff of entropy of each row (each syllable and its transitions)
naspment = (naspmmat.*log2(naspmmat))./log2(length(sylls));
naspment(find(isnan(naspment))) = 0;
naspment = -sum(naspment,2);
salent = (salmat.*log2(salmat))./log2(length(sylls));
salent(find(isnan(salent))) = 0;
salent = -sum(salent,2);
dfent = sum((naspment-salent).^2,2);
%sum sq difference in transition probability for each row (each syllable and its
%transitions)
dfprob = sum((naspmmat-salmat).^2,2);

p1 = length(find(difftest>df))/ntrials
p2 = NaN(size(naspmmat,1),1);
for i = 1:size(naspmmat,1)
    p2(i) = length(find(enttest(i,:)>dfent(i)))/ntrials;
end
p2
p3 = NaN(size(naspmmat,1),1);
for i = 1:size(naspmmat,1)
    p3(i) = length(find(diffprob(i,:)>dfprob(i)))/ntrials;
end
p3

