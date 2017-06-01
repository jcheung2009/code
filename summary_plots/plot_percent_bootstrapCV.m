function [mn3 hi lo] = plot_percent_bootstrapCV(ax,x,distr1,distr2,marker,linecolor,conditions);
%plots bootstrapped means and confidence intervals for CV in percent change
%from baseline comparison for summary plots

numcond = length(conditions);
axes(ax);hold on;
mn1 = mBootstrapCI_CV(distr1);
[mn2 hi lo] = mBootstrapCI_CV(distr2);
mn3 = 100*(mn2-mn1)/mn1;
hi = 100*(hi-mn1)/mn1;
lo = 100*(lo-mn1)/mn1;
plot(x,mn3,marker,[x x],[hi lo],linecolor,'linewidth',1,'markersize',12);hold on;
plot([0.5 numcond+0.5],[0 0],'color',[0.5 0.5 0.5]);hold on;
set(ax,'fontweight','bold','xlim',[0.5 numcond+0.5],'xtick',1:numcond,...
    'xticklabel',conditions);
ylabel('percent change');