%ST.days N rows (number of days)
%ST.colors V rows (number of transitions)
%ST.prob N rows and V columns
%ST.err N rows and V columns

function [sqout,rpout]=plotscatter(sqout,rpout)
 plot([0 100], [0 100],'k--')
 hold on;
for ii=1:length(sqout)
   
    
    plot(sqout(ii).BAS*100,sqout(ii).REC*100,'ko');
       hold on;
    

end


for ii=1:length(rpout)
    crtrns=rpout(ii);
    numvl=crtrns.MIN;
    pre=crtrns.pstay(1,numvl);
    wn=crtrns.pstay(2,numvl);
    if(length(crtrns.pstay(:,1))>2)
        pst=crtrns.pstay(3,numvl);
        hold on;
        plot(100*pre,100*pst,'go');
    end
end    
axis([0 100 0 100])