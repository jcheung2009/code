function seqsummary = seqtransmtx

config;

pathname = fileparts([pwd,'/analysis/data_structures/']);
trials = params.trial;
nshufftrials = 10000;
seqsummary = struct();
for i = 1:length(trials)
    cond = trials(i).name;
    base = trials(i).baseline;
    
    cd(base);
    ff = load_batchf(params.batchfile);
    datenm = [];seqfiles = {};
    for m = 1:length(ff)
        load([ff(m).name,'.not.mat']);
        datenm = [datenm; fn2datenm(ff(m).name,params.filetype)];
        seqfiles = [seqfiles; labels];
    end

    cd(['../',cond])
    ff = load_batchf(params.batchfile);
    ndatenm = [];nseqfiles = {};
    for m = 1:length(ff)
        load([ff(m).name,'.not.mat']);
        ndatenm = [ndatenm; fn2datenm(ff(m).name,params.filetype)];
        nseqfiles = [nseqfiles; labels];
    end
    
    [ind1 ind2 tb_sal tb_cond] = restricttimewindow(datenm,ndatenm,trials(i).treattime,...
        params.baseepoch,trials(i).condition);
    
    seqfiles = seqfiles(ind1);
    nseqfiles = nseqfiles(ind2);
    
    seq = cell2mat(seqfiles');
    nseq = cell2mat(nseqfiles');
    
    sylls = unique([seq nseq]);
    numseq = NaN(1,length(seq));
    numnseq = NaN(1,length(nseq));
    for m = 1:length(sylls)
        numseq(strfind(seq,sylls(m))) = m;
        numnseq(strfind(nseq,sylls(m))) = m;
    end
    seqmat = getTransitionMatrix(numseq,1);
    nseqmat = getTransitionMatrix(numnseq,1);
    
    ix = strfind(sylls,'-');
    seqmat(ix,:) = [];
    seqmat(:,ix) = [];
    nseqmat(ix,:) = [];
    nseqmat(:,ix) = [];
    
    seqmat = seqmat./sum(seqmat,2);
    nseqmat = nseqmat./sum(nseqmat,2);
    
    pooled = [seqfiles;nseqfiles];
    seq_samp = length(seqfiles);
    nseq_samp = length(nseqfiles);
    enttest = NaN(size(seqmat,1),nshufftrials);
    diffprob = NaN(size(seqmat,1),nshufftrials);
    for rep = 1:nshufftrials
        shuffpool = pooled(randperm(length(pooled),length(pooled)));
        seqsamp = shuffpool(1:seq_samp);
        nseqsamp = shuffpool(seq_samp+1:end);
        seqsamp = cell2mat(seqsamp');
        nseqsamp = cell2mat(nseqsamp');
        numseqsamp = NaN(1,length(seqsamp));
        numnseqsamp = NaN(1,length(nseqsamp));
        for n = 1:length(sylls)
            numseqsamp(strfind(seqsamp,sylls(n))) = n;
            numnseqsamp(strfind(nseqsamp,sylls(n))) = n;
        end
        seqsampmat = getTransitionMatrix(numseqsamp,1);
        nseqsampmat = getTransitionMatrix(numnseqsamp,1);
        
        seqsampmat(ix,:) = [];
        seqsampmat(:,ix) = [];
        nseqsampmat(ix,:) = [];
        nseqsampmat(:,ix) = [];
        
        seqsampmat = seqsampmat./sum(seqsampmat,2);
        nseqsampmat = nseqsampmat./sum(nseqsampmat,2);
        
        diffprob(:,rep) = sum((seqsampmat-nseqsampmat).^2,2);
        
        salent = (seqsampmat.*log2(seqsampmat))./log2(length(sylls));
        salent(find(isnan(salent))) = 0;
        salent = -sum(salent,2);
        drugent = (nseqsampmat.*log2(nseqsampmat))./log2(length(sylls));
        drugent(find(isnan(drugent))) = 0;
        drugent = -sum(drugent,2);
        enttest(:,rep) =sum((salent-drugent).^2,2);
    end
    naspment = (nseqmat.*log2(nseqmat))./log2(length(sylls));
    naspment(find(isnan(naspment))) = 0;
    naspment = -sum(naspment,2);
    salent = (seqmat.*log2(seqmat))./log2(length(sylls));
    salent(find(isnan(salent))) = 0;
    salent = -sum(salent,2);
    dfent = sum((naspment-salent).^2,2);
    dfprob = sum((seqmat-nseqmat).^2,2);
    
    p_ent= NaN(size(nseqmat,1),1);
    p_prob = NaN(size(nseqmat,1),1);
    for ii = 1:size(nseqmat,1)
        p_ent(ii) = length(find(enttest(ii,:)>dfent(ii)))/nshufftrials;
        p_prob(ii) = length(find(diffprob(ii,:)>dfprob(ii)))/nshufftrials;
    end
    
    seqsummary(i).trialname = trials(i).name;
    seqsummary(i).condition = trials(i).condition;
    seqsummary(i).basemat = seqmat;
    seqsummary(i).condmat = nseqmat;
    seqsummary(i).diffprob = dfprob;
    seqsummary(i).diffent = dfent;
    seqsummary(i).pValent = p_ent;
    seqsummary(i).pValprob = p_prob;
    
    cd ../
end

function [ind1 ind2 tb_sal tb_cond] = restricttimewindow(tb_sal,tb_cond,...
    treattime,base,condition);
%restrict and match the time window of analysis between conditions
%outputs the indices for data and time vectors 
    %get time vector for data in seconds relative to 7 AM 
    tb_sal = jc_tb(tb_sal,7,0);
    tb_cond = jc_tb(tb_cond,7,0);
    if isempty(treattime)
        start_time = tb_cond(1)+3600;
    else
        start_time = time2datenum(treattime) + 3600;%1 hr buffer
    end

    if ~strcmp(base,'morn') & isempty(strfind(condition,'saline'))%comparing drug in afternoon to saline in afternoon 
        ind2 = find(tb_cond > start_time);
        ind1 = find(tb_sal >= tb_cond(1));
    elseif ~strcmp(base,'morn') & ~isempty(strfind(condition,'saline'))%comparing saline to saline between days 
        ind2 = find(tb_cond > start_time);
        ind1 = find(tb_sal >= tb_cond(1));
    elseif strcmp(base,'morn') & isempty(strfind(condition,'saline'))%comparing drug in afternoon to saline in morning
        ind2 = find(tb_cond > start_time);
        ind1 = 1:length(tb_sal);
    elseif strcmp(base,'morn') & ~isempty(strfind(condition,'saline'))%comparing saline in afternoon to saline in morning
        ind2 = find(tb_cond >= 5*3600);
        ind1 = find(tb_sal < 5*3600);
    end
    tb_sal = tb_sal(ind1);
    tb_cond = tb_cond(ind2);