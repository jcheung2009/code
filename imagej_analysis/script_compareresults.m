%comparing spatial constants for test_nanoject_08 to test_nanoject_15

%place all data from different conditions into single structure
ff = load_batchf('batch');
data = struct();
for i = 1:length(ff)
    vars = who([ff(i).name,'*']);
    vars = ['fieldNames';vars];
    data.(ff(i).name) = v2struct(vars);
end

%extract separately spatial constants for dorsal quadrant and all other quadrants 
fn = fieldnames(data);
dorsal = {};sides = {};
for i = 1:length(fn);
    dorsal = [dorsal;structfun(@(x) x(1),data.(fn{i}))];
    sides = [sides;cell2mat(struct2cell(structfun(@(x) x(2:end), data.(fn{i}),'unif',0))')];
end
sides = cellfun(@(x) x(:),sides,'unif',0);


figure;hold on;
bar([cellfun(@mean,dorsal) cellfun(@(x) mean(x(:)),sides)]);
ylabel('distance (mm)');set(gca,'xtick',[1:length(ff)],'xticklabel',cellfun(@(x) x(end-1:end),fn,'unif',0));

g1 = {};g2 = {};
len1 = cellfun(@length,dorsal);
len2 = cellfun(@length,sides);
for i = 1:length(fn)
    g1 = [g1;repmat(fn(i),len1(i),1)];
    g2 = [g2;repmat(fn(i),len2(i),1)];
end

dorsal = cell2mat(dorsal);
sides = cell2mat(sides);
[p,~,stats] = anova1(dorsal,g1)
[p,~,stats] = anova1(sides,g2)