function [mtf_strct] = read_fanmod_outfile(batchout,name)

%close all;
fidb = fopen(batchout,'r');
b_cnt = 0; cnt_id = 0; adjcnt = 0;

while 1
    crntbrd = fscanf(fidb,'%s',1);
    if isempty(crntbrd), break; end
    b_cnt = b_cnt+1;
    cnt = 0;
    %store data about brd
    fid = fopen(crntbrd,'r');
    mtf_strct.brd{b_cnt} = fscanf(fid,'%s',108);
    if b_cnt ==1
        L_id = strfind(mtf_strct.brd(b_cnt),'Subgraphsize:');
        n = str2num(mtf_strct.brd{1}(L_id{1}+length('Subgraphsize:')));
    end
    %%extract data into matrix
    while 1
        if feof(fid), break; end
        val = fscanf(fid,'%s',1);cnt=cnt+1;
        if mod(cnt,n+6) == 1 && ~isempty(val)
            cnt_id = cnt_id+1;
            mtf_strct.mtrx_id(cnt_id) = round(str2num(val)); %subgraph id
        elseif mod(cnt,n+6) == 3 && ~isempty(val)
            mtf_strct.mtrx_freq(cnt_id) = str2num(val(1:end-1)); %subgraph freq
        end
    end
end
mtf_strct.vals.n = n;
save([char(name) '.mtfr_strct.' num2str(n) '.mat'],'mtf_strct')

unq = unique(mtf_strct.mtrx_id);

for i=1:length(unq)
    id = find(mtf_strct.mtrx_id == unq(i));
    mtf_strct.cnt(i) = length(id);
    mtf_strct.mu(i) = mean(mtf_strct.mtrx_freq(id));
    mtf_strct.std(i) = mean(bootstrp(100,@std,mtf_strct.mtrx_freq(id)));
    %mtf_strct.std(i) = std(mtf_strct.mtrx_freq(id));
end
[vlscm,idcm] =  find(mtf_strct.cnt >= 1);

mtf_strct.mu_cm = mtf_strct.mu(idcm);
mtf_strct.cnt_cm = mtf_strct.cnt(idcm);
mtf_strct.std_cm = mtf_strct.std(idcm);

[maxmu,op] = max(mtf_strct.mu_cm);
maxy = maxmu+mtf_strct.std_cm(op)+.3*mtf_strct.std_cm(op);

[vls,ids] = sort(mtf_strct.mu_cm,'descend');

for i=1:length(ids)
    mtf_strct.unqid(i) = unq(ids(i));
    bn_rep = cnvbase(num2str(unq(ids(i))),'0123456789','01');
    for k = 1:n^2-length(bn_rep)
        zds(k) = '0';
    end
    bn_rep_str = [zds num2str(bn_rep)];
    for j=1:n
        mtf_strct.adj{i,j,:} = bn_rep_str(1+n*(j-1):n+n*(j-1));
    end
end


save([char(name) '.mtf_strct.' num2str(n) '.mat'],'mtf_strct')

figure; hold on; %bar(vls);
errorbar(vls,mtf_strct.std_cm(ids),'ks');
% for i =1:length(unq)
%     text(i,maxy,num2str(mtf_strct.vals.cnt(ids(i))));
% end

axis([-1 length(ids)+1 0 maxy+.05*maxy]);

figure;bar(mtf_strct.cnt_cm(ids),'b');
axis([-1 length(ids)+1 0 28]);

