function []= rsmpl_trns_stats(batchlbld,syls,name)

ptn = '*$';
for i=1:9
    i
    ptn= ['*' ptn];
    patternstrct = get_pattern_fnx(batchlbld,ptn);
    [ptnprobstrct,uniqueptnsvect] = prob_of_patterns(patternstrct);
    %only use patterns ending in syls(ii)
    ptrnvect = [];cnts= 0;
    for ii=1:length(syls)
        idxs = strfind(uniqueptnsvect(i+1).vect,[syls(ii) '$']);
        for jj=1:length(idxs)
            cnts=cnts+1;
            probvect(cnts) = ptnprobstrct((idxs(jj)+1)/(i+2)).prob;
            ptrnvect = [ptrnvect uniqueptnsvect(i+1).vect(idxs(jj)-i:idxs(jj)+1) ];
        end
    end



    %calculate values that are repeatedly used below
    ttlsngs = length(patternstrct)-1; nrmv = floor(.5*ttlsngs); brks = strfind(ptrnvect,'$');
    for k=1:1000
        if mod(k,100) ==0
            k
        end
        cntn=0;
        %generate random seed and segregate data
        rndsd = randperm(ttlsngs); rndsd = rndsd(1:end-nrmv);
        for n=1:length(rndsd)
            ptnstrct_rsmpl1(n)=patternstrct(rndsd(n));
            totptn1(n) = patternstrct(rndsd(n)).totptnsng;
        end
        ptnstrct_rsmpl1(end+1).ptntot = sum(totptn1);
        [ptnprobstrctrs1,uniqueptnsvectrs1] = prob_of_patterns(ptnstrct_rsmpl1);
        for n=length(rndsd)+1:ttlsngs
            cntn=cntn+1;
            ptnstrct_rsmpl2(cntn)=patternstrct(n);
            totptn2(cntn) = patternstrct(n).totptnsng;
        end
        ptnstrct_rsmpl2(end+1).ptntot = sum(totptn1);
        [ptnprobstrctrs2,uniqueptnsvectrs2] = prob_of_patterns(ptnstrct_rsmpl2);

        %now, go through all the naturally occuring patterns and compaire
        %probability of full data set with that derived with subset.

        if length(uniqueptnsvectrs2(i+1).vect)>=length(uniqueptnsvectrs1(i+1).vect)
            brks=strfind(uniqueptnsvectrs2(i+1).vect,'$');
            for j=1:length(brks)
                ptrn = uniqueptnsvectrs2(i+1).vect(brks(j)-(i+1):brks(j)-1);
                idx_rs = strfind(uniqueptnsvectrs1(i+1).vect,ptrn);
                if ~isempty(idx_rs)
                    p_diff(j) =abs(ptnprobstrctrs1((idx_rs+i+1)/(i+2)).prob-ptnprobstrctrs2(j).prob);
                else
                    p_diff(j)=0;
                end
            end
        elseif length(uniqueptnsvectrs2(i+1).vect)<length(uniqueptnsvectrs1(i+1).vect)
            brks=strfind(uniqueptnsvectrs1(i+1).vect,'$');
            for j=1:length(brks)
                ptrn = uniqueptnsvectrs1(i+1).vect(brks(j)-(i+1):brks(j)-1);
                idx_rs = strfind(uniqueptnsvectrs2(i+1).vect,ptrn);
                if ~isempty(idx_rs)
                    p_diff(j) =abs(ptnprobstrctrs2((idx_rs+i+1)/(i+2)).prob-ptnprobstrctrs1(j).prob);
                else
                    p_diff(j)=0;
                end
            end
        end
        rsmpld_mudiff_vect(k) = mean(p_diff); %mean of square root squared error
        rsmpld_sumdiff_vect(k) = sum(p_diff); %sum of square root squared error
    end
    mu_err_est(i,1)= mean(rsmpld_mudiff_vect); mu_err_est(i,2)= std(rsmpld_mudiff_vect);
    sum_err_est(i,1)= mean(rsmpld_sumdiff_vect); sum_err_est(i,2)= std(rsmpld_sumdiff_vect);
end
figure;
errorbar(mu_err_est(:,1), mu_err_est(:,2));title('mean')
figure;
errorbar(sum_err_est(:,1), sum_err_est(:,2));title('sum')
save([name '.err_est.50_50.mat'],'mu_err_est','sum_err_est')