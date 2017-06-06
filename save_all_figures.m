function save_all_figures(fignums)



h = get(0,'children');
if ~isempty(fignums)
    ind = fignums;
else
    ind = 1:length(h);
end
for i = ind
    figind = find([h(:).Number]==i);
    saveas(h(figind),['figure',num2str(h(figind).Number)],'jpeg');
end