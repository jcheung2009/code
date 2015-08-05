function [ptnprobstrct,uniqueptnsvect] = prob_of_patterns2(ptnstrct,cndnt)

% function ptnprobstrct = prob_of_patterns(ptnstrct)
% 
% <ptnstrct>: a pattern structure from get_pattern
% <cndnt>: the note to condition the probabilities on;
%          either 'first' or 'last' are acceptable, dflts to 'last' 
% finds the number of occurances and probability of all 
% unique patterns in ptnstrct, conditioned on the last note

if nargin <2, cndnt = 'last'; end

szestrct = size(ptnstrct);
nmbofptns = ptnstrct(szestrct(2)).ptntot;
nmbofsngs = szestrct(2)-1;
for b = 1:50
    uniqueptnsvect(b).vect = [];
    index2(b) = 0;
end
lngthvect = [];
index1 = 0;

for i = 1:nmbofsngs
    ptnsinsng = ptnstrct(i).totptnsng;
    for j = 1:ptnsinsng
        crntptn = ptnstrct(i).ptnlbls(j);
        lngcrntptn = length(char(crntptn));
        if sum((isletter(char(crntptn))) == 0) == 0
            x = findstr(uniqueptnsvect(lngcrntptn).vect,char(crntptn)); 
			if isempty(x)
                if index2(lngcrntptn) ~= 0
                    uniqueptnsvect(lngcrntptn).vect = [uniqueptnsvect(lngcrntptn).vect '$' char(crntptn)];
                else
                    uniqueptnsvect(lngcrntptn).vect = [uniqueptnsvect(lngcrntptn).vect char(crntptn)];
                end
                
                index2(lngcrntptn) = index2(lngcrntptn)+1;
                index1 = index1+1;
                if isempty(find(lngthvect == lngcrntptn))
                   lngthvect = [lngthvect lngcrntptn];
                end
                ptnprobstrct_lng(lngcrntptn).ptn{index2(lngcrntptn)} = char(crntptn);
                ptnprobstrct_lng(lngcrntptn).cnt(index2(lngcrntptn)) = 1;
			else
                crntcnt = ptnprobstrct_lng(lngcrntptn).cnt(((x-1)/(lngcrntptn+1))+1);
                ptnprobstrct_lng(lngcrntptn).cnt(((x-1)/(lngcrntptn+1))+1) = crntcnt+1;
			end
        end
    end
end

uniqueptnsvect(lngcrntptn).vect = [uniqueptnsvect(lngcrntptn).vect '$'];

cnttmp = 0;
for w = 1:length(lngthvect)
    f = lngthvect(w);
    for r = 1:index2(f)
        cnttmp = cnttmp +1;
        ptnprobstrct(cnttmp).ptn = ptnprobstrct_lng(f).ptn{r};
        ptnprobstrct(cnttmp).cnt = ptnprobstrct_lng(f).cnt(r);
    end
end

ptnprobstrct(index1+1).ptn = []; ptnprobstrct(index1+1).nmbunqptns = index1;
ptnprobstrct(index1+1).nmbptnstot = nmbofptns;

%calculate appropriat conditional probabilities and counts per song

    %disp([char(cndnt)])
	cndnotevect = '';
	for k = 1:index1
        ptn = ptnprobstrct(k).ptn;
        if strcmp('last',char(cndnt))
            pos = length(ptn);
        else 
            pos = 1;
        end
        cndnte = ptn(pos);
        x = findstr(cndnotevect,char(cndnte));
        if isempty(x)
            cndnotevect = [cndnotevect cndnte]; cndntecnt(length(cndnotevect)) = ptnprobstrct(k).cnt;
        else
            cndntecnt(x) = cndntecnt(x)+ptnprobstrct(k).cnt;
        end    
	end
	
	for p = 1:index1
        ptn = ptnprobstrct(p).ptn;
        if strcmp('last',char(cndnt))
            pos = length(ptn);
        else 
            pos = 1;
        end
        cndnte = ptn(pos); x = findstr(cndnotevect,char(cndnte)); ptnprobstrct(p).cndnt = char(cndnte);
        ptnprobstrct(p).prob = ptnprobstrct(p).cnt/cndntecnt(x);
        ptnprobstrct(p).cntpersng = ptnprobstrct(p).cnt/nmbofsngs;
	end
     
%calculate entropy of sequences

S_tot = 0;
S_cnd = zeros(length(cndnotevect),1);
for s = 1:index1
        S_tot = -(ptnprobstrct(s).cnt/nmbofptns)*log2(ptnprobstrct(s).cnt/nmbofptns)+S_tot;
        cndnte = ptnprobstrct(s).cndnt; x = findstr(cndnotevect,char(cndnte));
        S_cnd(x) = (-ptnprobstrct(s).prob*log2(ptnprobstrct(s).prob))+S_cnd(x);
end

ptnprobstrct(index1+1).S_tot = S_tot;
ptnprobstrct(index1+1).cndnt_vect = cndnotevect;
ptnprobstrct(index1+1).S_cndvect = S_cnd;


