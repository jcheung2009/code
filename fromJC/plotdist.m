function plotdist(datarray,edges,ind2plot,normplot,normfactor)
    figure
    
    if normplot
        for ii=1:length(ind2plot)
           datarray{ind2plot(ii)}=datarray{ind2plot(ii)}/normfactor(ind2plot(ii)) 
        end
    end
    for ii=1:length(ind2plot)
        if ii==1
            stairs(edges,datarray{ind2plot(ii)},'k')
            hold on;
        else
            stairs(edges,datarray{ind2plot(ii)},'k--')
        end
    end
    