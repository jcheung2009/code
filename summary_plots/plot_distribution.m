function p1 = plot_distribution(ax,distr1,distr2,linecolor,varargin);
%plots and tests pdfs
if isempty(varargin)
    nbins = 50;
else
    nbins = varargin{1};
end

if length(distr1) <= 20 | length(distr2) <= 20
    [p1 h1] = ranksum(distr1,distr2);
else
    
    minval = min([min(distr1);min(distr2)]);
    maxval = max([max(distr1);max(distr2)]);

    [h2 p2] = lillietest(distr1);
    [h3 p3] = lillietest(distr2);
    if (h2==0) & (h3==0)
        [h1 p1] = ttest2(distr1,distr2);
        str1 = ['ttest p=',num2str(p1)];
    else
        [p1 h1] = ranksum(distr1,distr2);
        str1=['ranksum p=',num2str(p1)];
    end
    
    if ~isempty(ax)
        axes(ax);hold on;
        str2=['normtest1 p=',num2str(p2)];
        str3=['normtest2 p=',num2str(p3)];
        [n b] = hist(distr1,linspace(minval,maxval,nbins));
        stairs(b,n/sum(n),'k');hold on;
        [n b] = hist(distr2,linspace(minval,maxval,nbins));
        stairs(b,n/sum(n),linecolor);hold on;
        y=get(ax,'ylim');x=get(ax,'xlim');
        set(ax,'ylim',y,'xlim',x);
        plot(mean(distr1),y(1),'marker','^','color','k');hold on;
        plot(mean(distr2),y(1),'marker','^','color',linecolor);hold on;
        text(x(1),y(end),{str1;str2;str3})
        set(gca,'fontweight','bold');
        ylabel('probability');
    end
end