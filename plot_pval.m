function plot_pval(ax,distr1,distr2,x,y);
%plots pval in figures, good for bar plots

[p h] = signrank(distr1,distr2);
if p<=0.05
    if isempty(x)
        x = get(ax,'xlim');
    end
    if isempty(y)
        y=get(ax,'ylim');set(ax,'ylim',y);
    end
    text(ax,x(1),y(2),['p=',num2str(p)]);
end
