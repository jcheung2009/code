%hs struct returned has mnvl and marked.
function [hs]=gethstcomb(hs,avlsin,fields);

for ii=1:length(hs)
   if(exist('fields'))
       
      avls=avlsin{hs(ii).avlsind};
  end
    
    
    if(hs(ii).acmuvec)
        hs(ii).hst=avls.hstac_comb{hs(ii).ntvec}{hs(ii).muvec}
    else
        hs(ii).hst=avls.hstmu_comb{hs(ii).ntvec}{hs(ii).muvec}
    end
    hs(ii).edges=avls.edges{hs(ii).ntvec};
end
    
