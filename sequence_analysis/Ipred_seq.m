function [Ipredstrct] = Ipred_seq(unqvctcnd,ptrnstrctpred,unqvctpred,prbstrctpred,dir)
% [Ipredstrct] =
% Ipred_seq(unqvctcnd,ptrnstrctpred,unqvctpred,prbstrcpred,dir)
%unqvctcnd: sequences to condition on (observations)
%ptrnstrctpred: data to predict (postdict)
%unqvctpred: the vector of unique sequences to predict (postdict)
%prbstrctpred: the probabilities of the unique sequences to predict (postdict)
%dir: direction of Ipred: (pred)iction or (post)diction

% 
% for l =1:50
%     if ~isempty(unqvctcnt(l).vect)
%         break;%# of points observed
%     end
%

l = find(unqvctcnd == '$'); 
nobs = length(l);
l = l(1)-1;

n = find(unqvctpred == '$'); n = n(1)-1; %# of points to predict
Ipredstrct(nobs+1).lng_pred = n; 
Ipredstrct(nobs+1).lng_obs = l;

Ipredstrct(nobs+1).dir = dir; %predict or postdict
Ipredstrct(1).Ipredvect = []; % initialize the ipredvect

for i =1:nobs % for each unique observation
    Ipredstrct(i).cndseq = unqvctcnd(1+(i-1)*(l+1):l+(i-1)*(l+1)); %the observation
    cnt = 0;
    for j=1:length(ptrnstrctpred)-1 %
        for k=1:ptrnstrctpred(j).totptnsng
            if dir == 'pred' %
                if strfind(ptrnstrctpred(j).ptnlbls{k},Ipredstrct(i).cndseq) == 1
                    cnt = cnt+1;
                    Ipredstrct(i).predseq.seq{cnt} = ptrnstrctpred(j).ptnlbls{k}(n-(n-l)+1:end);
                end
            elseif dir == 'post'
                if strfind(ptrnstrctpred(j).ptnlbls{k},Ipredstrct(i).cndseq) == n+1
                    cnt = cnt+1;
                    Ipredstrct(i).predseq.seq{cnt} = ptrnstrctpred(j).ptnlbls{k}(n+1:end);
                end
            else
                break;
            end
        end
    end
    [unqpred,loc,ids] = unique(Ipredstrct(i).predseq.seq);
    for p = 1:length(unqpred)
        Ipredstrct(i).predseq.unq(p) = unqpred{p};
        Ipredstrct(i).predseq.cnt(p) = length(find(ids == p));
        Ipredstrct(i).predseq.cndprb(p) = Ipredstrct(i).predseq.cnt(p)/length(ids);
        
        id = (1+strfind(unqvctpred,[Ipredstrct(i).predseq.unq(p)]))/(n+1)
        
        Ipredstrct(i).predseq.predprb(p) = prbstrctpred.prbs(id).cnt/prbstrctpred.prbs(end).nmbptnstot;
        Ipredstrct(i).Ipred(p) = log2(Ipredstrct(i).predseq.cndprb(p)/Ipredstrct(i).predseq.predprb(p));
        Ipredstrct(end).Ipredvect = [Ipredstrct(end).Ipredvect Ipredstrct(i).Ipred(p)];
    end
end
Ipredstrct(1).meanIpred = mean(Ipredstrct(1).Ipredvect);