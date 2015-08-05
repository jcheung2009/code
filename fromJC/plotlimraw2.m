function []=plotlimraw(avls,ps)
    if(ps.flip)
        FC=-1;
    else
        FC=1;
    end
    ps.divfac=ps.divfac*FC;
    for ii=1:length(ps.runstoplot)
       crind=ps.runstoplot(ii);
       crvl=avls.aclist(crind,1);
       
       crmuvl=avls.mulist(crind);
        if(ii==1)
           floorvl=floor(avls.adjvls{1}{crvl}(1,1));
        end
        mdac=(median(avls.adjvls{1}{crvl}(:,2))-avls.initmean{1})./ps.divfac;
        if(crmuvl)
        mdmu=(median(avls.adjvls{1}{crmuvl}(:,2))-avls.initmean{1})./ps.divfac;
        end
        if (ps.plot_triangles)
            xvl=0.9;
            plot(xvl,mdac,'<','MarkerFaceColor','k','MarkerEdgeColor','k');
            hold on;
            if(crmuvl)
            plot(xvl,mdmu,'<','MarkerFaceColor','r','MarkerEdgeColor','r');
            end
            end

        if(crvl)
           
           
           plot(avls.adjvls{1}{crvl}(:,1)-floorvl,(avls.adjvls{1}{crvl}(:,2)-avls.initmean{1})./ps.divfac,'o','MarkerSize',1,'MarkerFaceColor','none','MarkerEdgeColor','k');
           hold on;
       end
       crvl=avls.aclist(crind,2);
       if(crvl)
           [vl]=setdiff(avls.rawvls{1}{crvl}(:,1),avls.adjvls{1}{crvl}(:,1));
           [rwind]=find(ismember(avls.rawvls{1}{crvl}(:,1),vl));
           if(ps.plotALL)
                     plot(avls.rawvls{1}{crvl}(rwind,1)-floorvl,(avls.rawvls{1}{crvl}(rwind,2)-avls.initmean{1})./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor','k')
           end
           plot(avls.adjvls{1}{crvl}(:,1)-floorvl,(avls.adjvls{1}{crvl}(:,2)-avls.initmean{1})./ps.divfac,'o','MarkerSize',1,'MarkerFaceColor','none','MarkerEdgeColor','k');
       end
       
       if(crmuvl)
          [vl]=setdiff(avls.rawvls{1}{crmuvl}(:,1),avls.adjvls{1}{crmuvl}(:,1));
          [rwind]=find(ismember(avls.rawvls{1}{crmuvl}(:,1),vl)); 
        if(ps.plotALL)
                     plot(avls.rawvls{1}{crmuvl}(rwind,1)-floorvl,(avls.rawvls{1}{crmuvl}(rwind,2)-avls.initmean{1})./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor','r')
        end
                     plot(avls.adjvls{1}{crmuvl}(:,1)-floorvl,(avls.adjvls{1}{crmuvl}(:,2)-avls.initmean{1})./ps.divfac,'o','MarkerSize',1,'MarkerFaceColor','none','MarkerEdgeColor','r');
       end
        hold on; 
    end

