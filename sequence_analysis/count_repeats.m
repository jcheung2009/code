function rptstrct = count_repeats(ptnstrct,rptstrct,yn_plot,syl)
% rptstrct = count_repeats(ptnstrct,rptstrct,yn_plot,syl)
% counts the number of repeats of various lengths and outputs the
% probability distribution of seeing a repeat of a given length
% 
% should parse pattern searched for to make lengths of repeats for ptn lngth >1 are correct


ptntot = ptnstrct(length(ptnstrct)).ptntot;
repeat_dist = zeros(ptntot,1);
cntfnd = [];
	crnttot = 0;
	for i = 1:length(ptnstrct)-1
        for k = crnttot+1:crnttot+ptnstrct(i).totptnsng
            ons = ptnstrct(i).ptnons{k-crnttot};
            repeat_dist(k) = length(ons);
            if isempty(find(cntfnd ==length(ons)))
                cntfnd = [cntfnd length(ons)];
            end
        end
        crnttot = crnttot + ptnstrct(i).totptnsng;
	end
    
    prb_dist = zeros(length(cntfnd),1);
    for k = 1:length(cntfnd)
        prb_dist(cntfnd(k),1) = length(find(repeat_dist == cntfnd(k)))/ptntot;
    end

    cnts = sort(cntfnd);
    if yn_plot
        if length(cnts) == length(prb_dist)
            figure; plot(cnts,prb_dist,'r-.',cnts,prb_dist,'b*'); title('Repeat Count Probability'); ylabel('Prbability'); xlabel('# of Occuring Syllables'); grid on;
        else
            figure; plot(prb_dist,'r-.'); title('Repeat Count Probability'); ylabel('Prbability'); xlabel('# of Occuring Syllables'); grid on;
        end
    end
    
    if rptstrct.lbls{1} == 0
        rptstrct.lbls{1} = char(syl);
        rptstrct.prbdist{1} = prb_dist;
        rptstrct.rptdist{1} = repeat_dist;
        rptstrct.prms(1,:) = [mean(repeat_dist) sqrt(var(repeat_dist))];    
    else
        rptstrct.lbls{end+1} = char(syl);
        rptstrct.rptdist{end+1} = repeat_dist;
        rptstrct.prbdist{end+1} = prb_dist;
        rptstrct.prms(end+1,:) = [mean(repeat_dist) sqrt(var(repeat_dist))];
    end