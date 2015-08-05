function [] = repeat_cmpr_dists(batchall,name,do_plot_all,do_plot_diff)

%
brostrct{1}.id = [1 2]; brostrct{2}.id= [3 4]; brostrct{3}.id = [6 8];
brostrct{4}.id = [9 10]; brostrct{5}.id = [17 18 19];  brostrct{6}.id = [21 22]; brostrct{7}.id = [23:26];


brostrct{1}.sylcmprs(1,:) = [1 1];
brostrct{1}.sylcmprs(2,:) = [3 3];
brostrct{2}.sylcmprs(1,:) = [];
brostrct{3}.sylcmprs(1,:) = [];
brostrct{4}.sylcmprs(1,:) =[1 3];
brostrct{5}.sylcmprs(1,:) = [2 3 nan];
brostrct{6}.sylcmprs =[];
brostrct{7}.sylcmprs(1,:) = [1 3 5 6];
brostrct{7}.sylcmprs(2,:) = [2 4 nan nan];
brovect = [1 2 3 4 6 8 9 10 17 18 19 21 22 23 24 25 26];
uniqvect = [5 7 11:16];

fidb = fopen(char(batchall),'r');
%
% sylvect =

cnt = 0;
bcnt = 0;

while 1
    crntfile = fscanf(fidb,'%s',1);
    if isempty(crntfile), break; end
    load(crntfile); bcnt = bcnt+1; brks = strfind(crntfile,'.');
    grp_rptstrct.brd(bcnt).name = crntfile(1:brks(1)-1);
    sylcnt = 0;
    for i  = 1:length(rptstrct.lbls)
        isrpt = strfind('ijkl',rptstrct.lbls{i});
        if isempty(isrpt)
            cnt = cnt+1; sylcnt = sylcnt+1;
            grp_rptstrct.brd(bcnt).cntid(sylcnt) = cnt;
            grp_rptstrct.brd(bcnt).syl(sylcnt) = rptstrct.lbls{i};
            grp_rptstrct.prbdist{cnt} = rptstrct.prbdist{i};
            grp_rptstrct.prms(cnt,:) = rptstrct.prms(i,:);
            grp_rptstrct.cv(cnt) = rptstrct.prms(i,2)/rptstrct.prms(i,1);
            grp_rptstrct.fano(cnt) = rptstrct.prms(i,2)^2/rptstrct.prms(i,1);
        end
    end
end

brocnt = 0;
for o = 1:length(brostrct)
    for i = 1:length(brostrct.id)
        if ~isempty(length(brostrct{o}.sylcmprs))
            for k = 1:length(brostrct{o}.sylcmprs)

            end
        end
    end
end



shrtcnt = 0; lngcnt = 0;
for i = 1:length(grp_rptstrct.prms)
    if grp_rptstrct.prms(i,1) >2
        lngcnt = lngcnt+1;
        lng.prms(lngcnt,:) = grp_rptstrct.prms(i,:);
        lng.fano(lngcnt) =  grp_rptstrct.fano(i);
        lng.cv(lngcnt) =  grp_rptstrct.cv(i);
        lng.prbdist{lngcnt} = grp_rptstrct.prbdist{i};
        lng.maxlng(lngcnt) = length(lng.prbdist{lngcnt});

    else
        shrtcnt = shrtcnt+1;
        shrt.prms(shrtcnt,:) = grp_rptstrct.prms(i,:);
        shrt.fano(shrtcnt) =  grp_rptstrct.fano(i);
        shrt.cv(shrtcnt) =  grp_rptstrct.cv(i);
        shrt.prbdist{shrtcnt} = grp_rptstrct.prbdist{i};
        shrt.maxlng(shrtcnt) = length(shrt.prbdist{shrtcnt});
    end
end


%figure; hold on;
shrt.prbmtrx = zeros(length(shrt.fano),max(shrt.maxlng));
for i=1:length(shrt.fano)
    % stairs(shrt.prbdist{i},'k');
    eval(['shrt.prbdistmtrx(i,1:shrt.maxlng(i)) = shrt.prbdist{i};']);
    %zds = find(shrt.prbdistmtrx(i,:) ==0);
    %shrt.prbdistmtrx(i,zds) = .000001;
end

%figure; hold on;
lng.prbmtrx = zeros(length(lng.fano),max(lng.maxlng));
for i=1:length(lng.fano)
    % stairs(lng.prbdist{i},'k');
    eval(['lng.prbdistmtrx(i,1:lng.maxlng(i)) = lng.prbdist{i};']);
    %zds = find(lng.prbdistmtrx(i,:) ==0);
    %lng.prbdistmtrx(i,zds) = .000001;
end






%%%%%%%%%here sort


for i =1:length(lng.fano)
    for j = 1:length(lng.fano)
        lng.dif_fano(i,j) = abs(lng.fano(j)-lng.fano(j));
        lng.dif_cv(i,j) = abs(lng.cv(i)-lng.cv(j));
        lng.dif_std(i,j) = abs(lng.prms(i,1)-lng.prms(j,1));
        lng.dif_mean(i,j) = abs(lng.prms(i,2)-lng.prms(j,2));
        [H,P,lng.ksstat(i,j)] = kstest2(lng.prbdist{i},lng.prbdist{j});
    end
end

for i =1:length(shrt.fano)
    for j = 1:length(shrt.fano)
        shrt.dif_fano(i,j) = abs(shrt.fano(j)-shrt.fano(j));
        shrt.dif_cv(i,j) = abs(shrt.cv(j)-shrt.cv(j));
        shrt.dif_std(i,j) = abs(shrt.prms(i,1)-shrt.prms(j,1));
        shrt.dif_mean(i,j) = abs(shrt.prms(i,2)-shrt.prms(j,2));
        [H,P,shrt.ksstat(i,j)] = kstest2(shrt.prbdist{i},shrt.prbdist{j});
    end
end



if do_plot_all
    [k,o] = sort(lng.maxlng,'descend');
    %figure; imagesc(lng.prbdistmtrx(o,:));
    figure;surf(lng.prbdistmtrx(o,:));
    figure;hist(lng.prms(o,1))
    figure;hist(lng.fano(o))

    figure;hist(lng.cv(o))
    pause;
    [k,o] = sort(shrt.maxlng,'descend');
    figure;hist(shrt.fano(o))
    figure;hist(shrt.prms(o,1))
    figure;hist(shrt.cv(o))

    %figure; imagesc(shrt.prbdistmtrx(o,:));
    figure; surf(shrt.prbdistmtrx(o,:));
end

%%%need to use only upper triagnel


if do_plot_diff

    ks = reshape(triu(lng.ksstat,1),size(lng.ksstat,1)*size(lng.ksstat,2),1);
    zds = find(ks>0); ks = ks(zds);
    figure; hist(ks,10);
    muks = mean(ks)

    cv = reshape(triu(lng.dif_cv,1),size(lng.ksstat,1)*size(lng.ksstat,2),1);
    zds = find(cv>0); cv = cv(zds);
    figure; hist(cv,10);
    mucv = mean(cv)

    std = reshape(triu(lng.dif_std,1),size(lng.ksstat,1)*size(lng.ksstat,2),1);
    zds = find(std>0); std = std(zds);
    figure; hist(std,10);
    mustd = mean(std)

    mu = reshape(triu(lng.dif_mean,1),size(lng.ksstat,1)*size(lng.ksstat,2),1);
    zds = find(mu>0); mu = mu(zds);
    figure; hist(mu,10);
    mumu = mean(mu)




    lp = reshape(triu(shrt.ksstat),size(shrt.ksstat,1)*size(shrt.ksstat,2),1);
    figure; hist(lp,25);
    mean(lp)
    lp = reshape(triu(shrt.dif_cv),size(shrt.ksstat,1)*size(shrt.ksstat,2),1);
    figure; hist(lp,25);
    mean(lp)

    lp = reshape(triu(shrt.dif_std),size(shrt.ksstat,1)*size(shrt.ksstat,2),1);
    figure; hist(lp,25);
    mean(lp)

    lp = reshape(triu(shrt.dif_mean),size(shrt.ksstat,1)*size(shrt.ksstat,2),1);
    figure; hist(lp,25);
    mean(lp)

end

save([char(name) '.grp_rptstrct.mat'],'grp_rptstrct','lng','shrt');







