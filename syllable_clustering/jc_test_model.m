function mdl = jc_test_model(feature_vecs,modeltype,featuretype,pca_features)
classes = fieldnames(feature_vecs);
dataset = [];
labels = [];
for i = 1:length(classes)
    dataset = [dataset; feature_vecs.(classes{i})];
    labels = [labels; i*ones(size(feature_vecs.(classes{i}),1),1)];
end
dataset = zscore(dataset);

if strcmp(featuretype,'distance')
    ind = randsample(size(dataset,1),size(dataset,1));
    dataset = dataset(ind,:);
    labels = labels(ind,:);
    basis_set = dataset(1:50,:);
    basis_labels = labels(1:50);
    dataset = squareform(pdist(dataset,'squaredeuclidean'));
    dataset = dataset(:,1:50);
end

if strcmp(pca_features,'yes')
    [~,dataset] = pca(dataset,'NumComponents',3);
    cmap = hsv(length(classes));
    figure;hold on;
    for i = 1:length(classes)
        plot3(dataset(labels==i,1),dataset(labels==i,2),dataset(labels==i,3),...
            '.','color',cmap(i,:));hold on;
        xlabel('principal component 1');ylabel('principal component 2');
        zlabel('principal component 3');
    end
end
   
if strcmp(modeltype,'knn')
    numneighbors = [1:10];
    dm = {'euclidean','cityblock','chebychev','correlation','cosine','spearman'};
    minmcr = [];
    figure;hold on;
    for p = 1:length(dm)
        mcr = [];
        for i = 1:length(numneighbors)
            knn = fitcknn(dataset,labels,'NumNeighbors',numneighbors(i),'BreakTies','nearest',...
            'CrossVal','on','KFold',3,'Distance',dm{p});
            mcr = [mcr; kfoldLoss(knn)];
        end
        [m,mind] = min(mcr);
        subplot(2,3,p);hold on;plot(numneighbors,mcr,'k','marker','o');
        xlabel('number of neighbors');ylabel('mis-classification error');
        set(gca,'fontweight','bold');
        title(['Nearest Neighbor,',dm{p},',k=',num2str(mind),';MCR=',num2str(m)]);
        minmcr = [minmcr; m mind];
    end
    
    [m ind] = min(minmcr(:,1));
    bestdm = dm{ind};
    bestmcr = m;
    bestk = minmcr(ind,2);
    disp(['best distance metric = ',bestdm]);
    disp(['best MCR = ',num2str(bestmcr)]);
    disp(['best num  neighbors = ',num2str(bestk)]);
    mdl{1} = fitcknn(dataset,labels,'NumNeighbors',bestk,'BreakTies','nearest',...
        'CrossVal','on','KFold',3,'Distance',bestdm)
    
    t = templateKNN('BreakTies','nearest','NumNeighbors',bestk,'Distance',bestdm);
    mdl{2} = fitcecoc(dataset,labels,'CrossVal','on','KFold',3,'Learners',t);
    mcr = kfoldLoss(mdl{2});
    disp(['MCR for multiclass KNN onevsone = ',num2str(mcr)]);
%     mdl{3} = fitcecoc(dataset,labels,'CrossVal','on','KFold',3,'Learners',t,'Coding','onevsall');
%     mcr = kfoldLoss(mdl{3});
%     disp(['MCR for multiclass KNN onevsall = ',num2str(mcr)]);
end

if strcmp(modeltype,'binarysvm')
    c = 10.^([-5:5]);
    rng(1);%reproducibility
    svmm = cell(length(classes),1);
    figure;hold on;
    totalmcr = [];
    for m = 1:length(c)
        scores = [];
        for i = 1:length(classes)
            newlabels = labels == i;
            md = fitcsvm(dataset,newlabels,'KernelFunction','rbf','BoxConstraint',c(m),...
                'CrossVal','on','KFold',3,'OutlierFraction',0.05,'KernelScale','auto');
            svmm{i} = [svmm{i}; {md}];
            [~,score] = kfoldPredict(md);
            scores = [scores score(:,2)];
        end
        [~,cvpredict] = max(scores,[],2);
        mcr = sum(cvpredict~=labels)/length(labels);
        totalmcr = [totalmcr;mcr];
    end
    semilogx(c,totalmcr,'k','marker','o');hold on;
    xlabel('box constraint');ylabel('mis-classification error');
    [m2,mind] = min(totalmcr);
    title(['SVM,','MCR=',num2str(m2),' ,BC=',num2str(c(mind))]);
    
    ks = [];
    for i = 1:length(svmm)
        classmdl = svmm{i};
        for ii = 1:length(classmdl)
            bcmdl = classmdl{ii};
            ks = [ks; cell2mat(cellfun(@(x) x.KernelParameters.Scale,bcmdl.Trained,'unif',0))];
        end
    end
    disp(['kernel scale=',num2str(mean(ks))]);
    
    c = c(mind);
    ks = mean(ks)*(1.2.^([0:10]));
    rng(1);%reproducibility
    svmm = cell(length(classes),1);
    figure;hold on;
    totalmcr = [];
    for m = 1:length(ks)
        scores = [];
        for i = 1:length(classes)
            newlabels = labels == i;
            md = fitcsvm(dataset,newlabels,'KernelFunction','rbf','BoxConstraint',c,...
                'CrossVal','on','KFold',3,'OutlierFraction',0.05,'KernelScale',ks(m));
            svmm{i} = [svmm{i}; {md}];
            [~,score] = kfoldPredict(md);
            scores = [scores score(:,2)];
        end
        [~,cvpredict] = max(scores,[],2);
        mcr = sum(cvpredict~=labels)/length(labels);
        totalmcr = [totalmcr;mcr];
    end
    plot(ks,totalmcr,'k','marker','o');hold on;
    xlabel('kernel scale');ylabel('mis-classification error');
    [m,mind] = min(totalmcr);
    title(['SVM,','MCR=',num2str(m),' ,KS=',num2str(ks(mind))]);
    mdl = svmm;
end

if strcmp(modeltype,'multisvm')
    t = templateSVM('KernelScale','auto','BoxConstraint',10);
    svmm = fitcecoc(dataset,labels,'CrossVal','on','KFold',3,'Learners',t);
    mcr = kfoldLoss(svmm);
    disp(['mis-classification error for multiclass SVM, onevsone = ',num2str(mcr)]);
    mdl{1} = svmm;
%     svmm = fitcecoc(dataset,labels,'CrossVal','on','KFold',3,'Coding','onevsall','Learners',t);
%     mcr = kfoldLoss(svmm);
%     disp(['mis-classification error for multiclass SVM, onevsall = ',num2str(mcr)]);
%     mdl{2} = svmm;
end

if strcmp(modeltype,'gmm')    
    predfun = @(XTRAIN,YTRAIN,XTEST,YTEST)(sum(cluster(fitgmdist(XTRAIN,6,...
        'Start',YTRAIN,'RegularizationValue',10,'CovarianceType',...
        'diagonal'),XTEST)~=YTEST)/length(YTEST));
    mcr = crossval(predfun,dataset,labels,'kfold',3);
    disp(['mis-classification error for GMM = ',num2str(mean(mcr))]);
end

if strcmp(modeltype,'naivebayes')
    mdl{1} = fitcnb(dataset,labels,'CrossVal','on','KFold',3);
    mcr = kfoldLoss(mdl{1});
    disp(['mis-classification error for naivebayes = ',num2str(mcr)]);
    t = templateNaiveBayes();
    mdl{2} = fitcecoc(dataset,labels,'CrossVal','on','KFold',3,'Learners',t);
    mcr = kfoldLoss(mdl{2});
    disp(['mis-classification error for naivebayes multiclass onevsone= ',num2str(mcr)]);
%     mdl{3} = fitcecoc(dataset,labels,'CrossVal','on','KFold',3,'Learners',t,'Coding','onevsall');
%     mcr = kfoldLoss(mdl{3});
%     disp(['mis-classification error for naivebayes multiclass onevsall= ',num2str(mcr)]);
end

    

    
   
