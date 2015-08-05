function jc_findsites(batchrhdkeep)

ff = load_batchf(batchrhdkeep);
dep = [];
for i = 1:length(ff)
    dep = [dep; str2num(ff(i).name(end-21:end-18))];
end

[sites,~,ind] = unique(dep);

for sitenum = 1:length(sites)
    fid(sitenum) = fopen(['batchrhd_site',num2str(sites(sitenum))],'w');
end

for i = 1:length(ind)
    fprintf(fid(ind(i)),'%s\n',ff(i).name);
end
fclose('all');