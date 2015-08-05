function cmpr_rpt_prb_dists(strct1,strct2)
%strct1 and strct2 must be the same length and the order of analyzed repeats must be the same
%(i.e.  if strct1 contains the syllables 'a b c' then strct2 must also
%contain 'a b c', in that order
%
name1 = input('What is the name of the first dist? ');
name2 = input('What is the name of the second dist? ');
for i = 1:length(strct1.rptdist)
    dist1 = strct1.rptdist{i}';
	dist2 = strct2.rptdist{i}';
	p_dist1 = strct1.prbdist{i};
	p_dist2 = strct2.prbdist{i};
	lng1 = length(p_dist1);
	lng2 = length(p_dist2);
	
	if lng1 < lng2
        p_dist1 = [p_dist1' zeros(1,lng2-lng1)];
        cnts = [1:lng2];
        p_dist2 = p_dist2';
	elseif lng2 < lng1
        p_dist2 = [p_dist2' zeros(1,lng1-lng2)];
        cnts = [1:lng1];
        p_dist1 = p_dist1';
	else
        p_dist1 = p_dist1';
        p_dist2 = p_dist2';
        cnts = [1:lng1];
	end
	
	roc_val = abs(.5-roc(dist1,dist2,0))+.5; 
	p = ranksum(dist1,dist2);

	maxprb = max(max(p_dist1,p_dist2));
	syl = char(strct1.lbls{i});
	figure; plot(cnts,p_dist1,'r-.',cnts,p_dist2,'k--'); hold on;
	legend(char(name1), char(name2),2);
	title(['Repeat Count Probability for syllable: ' char(syl)]); ylabel('Prbability'); xlabel('# of Occuring Syllables'); 
	grid on; text(length(cnts)-2,maxprb+.06*maxprb,['rocval = ' num2str(roc_val)]);
	text(length(cnts)-2,maxprb+.1*maxprb,['Rank-sum P = ' num2str(p)]);
end