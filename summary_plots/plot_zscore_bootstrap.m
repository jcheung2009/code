function [hi mn lo] = plot_zscore_bootstrap(ax,x,distr,marker,linecolor,conditions,testtype);
%plots bootstrapped means and confidence intervals
numcond = length(conditions);
axes(ax);hold on;
if strcmp(testtype,'mn');
    [hi lo mn] = mBootstrapCI(distr);
elseif strcmp(testtype,'cv');
    [hi lo mn] = mBootstrapCI_CV(distr);
end
plot(x,mn,marker,[x x],[hi lo],linecolor,'linewidth',1,'markersize',12);hold on;
plot([0.5 numcond+0.5],[0 0],'color',[0.5 0.5 0.5]);hold on;
set(ax,'fontweight','bold','xlim',[0.5 numcond+0.5],'xtick',1:numcond,...
    'xticklabel',conditions);
ylabel('z-score');