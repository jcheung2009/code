function [AIC obj weightedclusts unweightedclusts] = mTetrode_AIC(dataMtx,maxclusts)
%
% function [AIC obj] = mTetrode_AIC(dataMtx,maxclusts)
%
% Computes Akiake Information Criterian (AIC) or Bayes Information Criterian (BIC) for clusters = 1:maxclusts for
% dataMtx. Clustering is done via gaussian mixture modeling. Ideal number
% of clusters minimizes AIC. Iterates through cluster numbers 75 times and
% negatively weights values that don't converge. 
%
% Generally a good method for finding proper number of clusters in
% multidimensional data. dataMtx should be MxN matrix where M is number of
% observations and N is number of measurements or dimensions. Using
% tetrodes as an example, M might be peak of each spike and N would be each
% tetrode channel.
%


maxiter = 75; % maximum iterations
%AICdiffMtx = zeros(maxiter,maxclusts);

AIC = zeros(maxiter,maxclusts);
converged = zeros(1,maxclusts);
obj = cell(1,maxclusts);

figure();hold on
for iter = 1:maxiter
    for i=1:maxclusts
        obj{i} = gmdistribution.fit(dataMtx,i,'CovType','full','SharedCov',logical(1));
        if(obj{i}.Converged==1)
            AIC(iter,i) = obj{i}.AIC .* obj{i}.Converged; % obj{i}.BIC for Bayes info criterian; obj{i}.AIC for Akiake info crit.
        else
            converged(i) = converged(i)+1;            
        end
    end
    theAIC = AIC(iter,:);
    theAIC = theAIC(find(theAIC>0));
    AIC(iter,1:length(theAIC)) = theAIC;
    AIC(iter,:) = mzeros2nan(AIC(iter,:));
    plot(AIC(iter,:),'ro-');
    % AICdiffMtx(iter,:) = diff(AIC);    
end

meanaic = nanmean(AIC);
meanaic = meanaic .* (1+(converged/maxiter)); % negatively weighting failed convergences 
plot(nanmean(AIC),'ko-','MarkerFaceColor','k','MarkerSize',7);title('unweighted');
hold off;

figure();plot(meanaic,'bo-','MarkerFaceColor','b');title('convergence weighted')
[themin minloc] = min(meanaic);
weightedclusts = minloc;
dispstr = ['Number of Clusters using Convergence Weighting: ' num2str(minloc)];
disp(dispstr);
[themin minloc] = min(nanmean(AIC));
unweightedclusts = minloc;
dispstr = ['Number of Clusters (unweighted): ' num2str(minloc)];
disp(dispstr);

