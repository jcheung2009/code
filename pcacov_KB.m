function [eigvects,eigvals,explvar] = pcacov_KB(data1,data2,doplot)
 
%[eigvects,eigvals,explvar] = pcacov_KB(data1,data2,doplot)
% calculates: 1) cov(data1,data2) or cov(data1)
% also has an option to plot the results
% outputs: 1) eigenvectors, 2) eigenvals, 2) explvar
 
if ~isempty(data2)
    C = cov(data1,data2);
else
    C = cov(data1);
end
 
%use pcacov
[eigvects,eigvals,explvar] = pcacov(C);
 
if doplot
    %plot results
    figure; subplot(2,2,1); imagesc(C); xlabel('data1');ylabel('data2');title('Covariance Matrix');
    subplot(2,2,3);title('Normalized Eigen Values and Cumulative Explained variance');
    h1 = line([1:length(eigvals)],eigvals,'Color','k');   ax1 = gca;
    ax2 = axes('Position', get(ax1,'Position'),...
        'XAxisLocation','bottom',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
    h2 = line([1:length(eigvals)],cumsum(explvar),'Color','k','Parent',ax2); set(h1,'LineW',2); axis('tight')
 
    subplot(2,2,2);
    h3 = plot(eigvects(:,1),'k'); set(h3,'LineW',2); hold on;
    title(['Principle Component, Variance Explained: ',  num2str(explvar(1))]);
    axis([1 length(eigvects(:,1)) min(min(eigvects)) max(max(eigvects))]);
    subplot(2,2,4);
    clrvect = 'rgb';
    for i =1:3
        h3 = plot(eigvects(:,i+1),clrvect(i)); set(h3,'LineW',2); hold on;
    end
    axis([1 length(eigvects(:,1)) min(min(eigvects)) max(max(eigvects))]);
    title(['Principle Component, Variance Explained: ',  num2str(sum(explvar(1:4)))]);
    %legend('EigVect2','EigVect3','EigVect4','Location','NorthEastOutside');
end