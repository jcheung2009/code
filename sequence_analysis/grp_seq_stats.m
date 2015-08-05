function [syltrns,introtrns] = grp_seq_stats(batch)

batch

fidb = fopen(char(batch),'r')

alltrns =[]
syltrns = []
introtrns = []
while 1
    crntfile = fscanf(fidb,'%s',1);
    if isempty(crntfile), break;end
    load(crntfile)
    alltrns = [alltrns;reshape(trns_strct.mtrx,length(trns_strct.mtrx)^2,1)];
    intros = intersect(trns_strct.lbls,'ijkl');introid = [];
    for i=1:length(intros)
        introid(i) = strfind(trns_strct.lbls,intros(i));
    end
    sylids = setdiff([1:length(trns_strct.lbls)],introid);
    syltrns = [syltrns;reshape(trns_strct.mtrx(sylids,sylids),length(sylids)^2,1)];
    introtrns = [introtrns;reshape(trns_strct.mtrx(introid,introid),length(introid)^2,1)];
end
fclose(fidb);


[na,x] = hist(alltrns,40);
[ns,x] = hist(syltrns,40);
[ni,x] = hist(introtrns,40);
nssmth=conv(normpdf([0:.2:1],.5,.5),ns);
nsimth=conv(normpdf([0:.2:1],.5,.5),ni);
naimth=conv(normpdf([0:.2:1],.5,.5),na);



[h,p] = kstest2(syltrns,introtrns)



figure; semilogy(1,1);hold on;
%semilogy(naimth(4:end-2)./sum(naimth(4:end-2)),'k');
semilogy(nssmth(4:end-2)./sum(nssmth(4:end-2)),'b'); 
%semilogy(nsimth(4:end-2)./sum(nsimth(4:end-2)),'r');
lp=1;

% 
%         rster_smth=conv(normpdf([0:.2:1],.5,.5),ns);
%         offset=round((length(rster_smth)-length(rster_raw))/2); if offset ==0, offset =1; end %get rid of convolution induced offset
%         rster_smth=rster_smth(offset:length(rster_raw)+offset-1);
% 
%         