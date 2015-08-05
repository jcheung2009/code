%ST.days N rows (number of days)
%ST.colors V rows (number of transitions)
%ST.prob N rows and V columns
%ST.err N rows and V columns

function [outmat,ss]=plotseqtm(instruct)

    plot(crdt.days,100*crdt.sqvls,'k');
    hold on;
    plot(crdt.days,100*crdt.sqvls,'ko');
    plot(crdt.days,100*ones(1,6)*mean(crdt.sqvls),'k--');
    plot(crdt.days,100*(1-crdt.sqvls),'r');
    hold on;
    plot(crdt.days,100*(1-crdt.sqvls),'ro');
    plot(crdt.days,100*ones(1,6)*(1-mean(crdt.sqvls)),'r--');
    for ii=1:length(crdt.days)
        text(crdt.days(ii),80, num2str(crdt.targn(ii)),'Color','k');
        hold on;
        text(crdt.days(ii),40,num2str(crdt.alln(ii)-crdt.targn(ii)),'Color','r')
    end