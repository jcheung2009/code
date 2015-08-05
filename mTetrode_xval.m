function [metaclusts clustIDs gmmodel] = mTetrode_xval(dataMtx,maxclusts,plotit)
%
% function [] = mTetrode_xval(dataMtx,maxclusts,plotit)
%
% uses n-fold cross-validation to estimate proper number of clusters between 2 and maxclusts in
% dataMtx. Clustering is via gaussian-mixture-modeling in matlab's stat
% toolbox, accuracy is measured with mahalanobis distance.
%
% dataMtx is NxM multidimensional data, where M is number of observations
% and N is Different measurements. For example, with tetrode data, N=4 and
% M=number of spikes if you are clustering based on spike height across
% channels.
%

metaiter = 100; %
metaclusts = zeros(1,metaiter);
metahi = zeros(metaiter,maxclusts-2);
metalow = zeros(metaiter,maxclusts-2);

datasize = size(dataMtx);
datasize = datasize(1);

%maxiter = datasize; % iterations of each cluster value
trainprop = 1-(1/datasize); % proportion of dataMtx to use for model training vs testing
maxiter = 50;
% trainprop = 0.95;

if(plotit)
    figh = figure();
    hold on;
end

for metai=1:1:metaiter;
    
    mahalvect = zeros((maxclusts-1),maxiter);    
    
    gmmodel = cell(1,maxclusts);
    
    for theclust=2:1:maxclusts
        [traindata testdata] = mSubdivideMtx(dataMtx,trainprop);        
        gmmodel{theclust} = gmdistribution.fit(traindata,theclust,'Replicates',25,'CovType','Full','SharedCov',logical(1));
        for iter=1:1:maxiter % cross-validate 
            [traindata testdata] = mSubdivideMtx(dataMtx,trainprop);
            %mahalvect(theclust,iter) = mean(min(mahal(gmmodel{theclust},testdata)'));
            mahalvect(theclust,iter) = mean(mTetrode_clustDist(testdata,gmmodel{theclust},theclust)); % euclidean distance            
        end
    end
    mahalvect(1,:) =[];
    %[themin minloc] = min(mean(mahalvect'));
    %numclusts = minloc+1;
    thediff = diff(mean(mahalvect'));
    [hiconf loconf] = mBootstrapCI_mtx(diff(mahalvect),.95); % bootstrapped confidence intervals around derivative of distance
    metahi(metai,:) = smooth(hiconf,5);
    metalow(metai,:) = smooth(loconf,5); 
    numclusts = find(metahi(metai,:)>=0,1) + 1;
    metaclusts(metai) = numclusts; 
    
    %finalmahalvect = mahal(gmmodel{numclusts},dataMtx);
    % [mahalmin clustIDs] = min(finalmahalvect');
    clustIDs = cluster(gmmodel{numclusts},dataMtx);
    
    %dispstr = ['estimated number of clusters is ' num2str(numclusts)];
    %disp(dispstr);          
    
    if(plotit)
        %xaxis = [2:1:maxclusts];
        %figure();errorbar(xaxis,mean(mahalvect'),std(mahalvect'),'bo','MarkerFaceColor','b');        
        %xlabel('number of clusters');ylabel('Mean Mahalanobis Distance to Nearest Cluster');
        xaxis = [2:1:maxclusts-1];
        plot(hiconf,'b-');
        plot(loconf,'r-');
        smoothvect = smooth(diff(mean(mahalvect')),5);
        plot(smoothvect,'ko-');
        xlabel('number of clusters');ylabel('mean distance reduction for each additional cluster');
    end
end
hold off;
