%stability_analysis
%takes input from ~/ml/seqbirdmfiles/synbirdstruct
function [sumout]=stabil_anal(ss)

%first find the indices which have stability analysis.

stabinds=[];
for ii=1:length(ss)
    if(ss(ii).stab)
       stabinds=[stabinds ii]; 
    end
end

%now for all these indices and not others,
%extract outnotectvls over the stability_window.
indnum=1;

for crind=stabinds
   cmd=['cd ' ss(crind).pth ';load sumdata.mat']
   eval(cmd);
   stab_bnds=datenum(avls.stabwin);
   dayinds=find(dayout>=stab_bnds(1)&dayout<=stab_bnds(2));
   sumout(indnum).days=dayout(dayinds)-dayout(dayinds(1))+1;
   sumout(indnum).targn=sum(outnotect(dayinds,avls.SEQTRGNT{1}),2);
   sumout(indnum).alln=sum(outnotect(dayinds,avls.ALLSEQNT),2);
   sumout(indnum).sqvls=sumout(indnum).targn./sumout(indnum).alln;
  
   sumout(indnum).ssind=crind;
   
   indnum=indnum+1;
end
    