function entrpy_strct = cndentropy_lngth_2rev(batchnotmats,maxlng,syls,dosave,name,doplot)
    
if (nargin == 3), dosave = 0; name = 'null'; doplot = 1;
elseif (nargin == 5), doplot = 0; end
    tic
    for strlng = 1:maxlng
        strlng
        ptn(1:strlng) = '*';
        ptn = [ptn '$'];
        ptnstrct_prdcd = get_pattern_fnx_2(batchnotmats,ptn,1,name);
        [probstrct_prdcd, ptnvectprdcd] = prob_of_patterns(ptnstrct_prdcd);
        prbstrct.prbs = probstrct_prdcd; prbstrct.ptns = ptnvectprdcd(strlng).vect;
        
        save([name '.rev.prb_strct.L' num2str(strlng) '.mat'],'prbstrct')
        
        for i = 1:length(probstrct_prdcd(end).cndnt_vect)
            crntsyl = probstrct_prdcd(end).cndnt_vect(i);
            x = strfind(char(syls),char(crntsyl));
            entrpymtrx(x,strlng) = probstrct_prdcd(end).S_cndvect(i);
            totentrpvect(strlng) = probstrct_prdcd(end).S_tot;
        end
    end
    toc
    %offsetvect = [0 totentrpvect(1:end-1)];
    %offsetmtrex = [zeros(length(syls),1) entrpymtrx(:,1:end-1)];
    diffentrpymtrx = diff(entrpymtrx);
    diffentrpyvect = diff(totentrpvect);
    
    if doplot
        figure(666); imagesc(entrpymtrx); title(['Conditional Entropy vs. String Length for: ' char(name)]); 
        colorbar; xlabel('String Length'); ylabel('H');   
        for i = 1:length(syls)
                text(-.75,i-.1,char(syls2plt(i)));
        end
        figure(667); plot(totentrpvect); title(['Entropy (H) of Entire Song for: ' char(name)]); 
        xlabel('String Length'); ylabel('H');
        
        figure(668); imagesc(diffentrpymtrx); title(['Conditional Entropy Gradient vs. String Length for: ' char(name)]); 
        colorbar; xlabel('String Length'); ylabel('H');
        for i = 1:length(syls)
                text(-.75,i-.1,char(syls(i)));
        end
        figure(669); plot(diffentrpyvect); title(['Entropy Gradient of Entire Song for: ' char(name)]); 
        xlabel('String Length'); ylabel('H');
    end
        entrpy_strct.cnd_mtrx = entrpymtrx;
        entrpy_strct.syls = syls;
        entrpy_strct.tot_vect = totentrpvect;
        entrpy_strct.grd_mtrx = diffentrpymtrx;
        entrpy_strct.grd_vect = diffentrpyvect;
        savename = [char(name) '.entrpstrct_rev.mat'];
        save(char(savename),'entrpy_strct');
