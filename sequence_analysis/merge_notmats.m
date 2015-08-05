function [] = merge_notmats(batchnotmat,name)

fidb = fopen(batchnotmat,'r');


lbls = [];
while 1
    crntfile = fscanf(fidb,'%s',1);
    if isempty(crntfile), break; end
    load(crntfile)
    lbls = [lbls labels];
end

elms = elements(lbls);
alphs = 'abcdefghijklmnopqrstuvwxyz';
l = intersect(alphs,elms);
df = setdiff(elms,l);

idxcut = [];
for i = 1:length(df)
    op = strfind(lbls,df(i));
    idxcut = [op idxcut];
end

kpid = setdiff([1:length(lbls)],idxcut);
lbls = lbls(kpid);



labels = lbls;
onsets = [1:length(lbls)];
offsets = ones(size(onsets))+onsets;
    
save(char(name),'labels','onsets','offsets')