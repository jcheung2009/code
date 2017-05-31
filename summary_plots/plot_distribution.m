function h1 = plot_distribution(ax,distr1,distr2,linecolor);
%plots and tests pdfs

axes(ax);hold on;
minval = min([min(distr1);min(distr2)]);
maxval = max([max(distr1);max(distr2)]);

[h1 p1] = ttest2(distr1,distr2);
[h2 p2] = lillietest(distr1);
[h3 p3] = lillietest(distr2);
str1=['ttest p=',num2str(p1)];
str2=['normtest1 p=',num2str(p2)];
str3=['normtest2 p=',num2str(p3)];
[n b] = hist(distr1,linspace(minval,maxval,50));
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(distr2,linspace(minval,maxval,50));
stairs(b,n/sum(n),linecolor);hold on;
y=get(ax,'ylim');x=get(ax,'xlim');
plot(mean(distr1),y(1),'marker','^','color','k');hold on;
plot(mean(distr2),y(1),'marker','^','color',linecolor);hold on;
text(x(1),y(end),{str1;str2;str3})
set(gca,'fontweight','bold');
ylabel('probability');