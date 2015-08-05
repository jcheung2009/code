%need ps.pvltoplot



function [ax]=plotavn(ps, avls)
   figure
   nmaxes=length(ps.pvltoplot)
   ps.freqlimbound=[6000 8000]
   ps.freqspacing=62.5;
   for ii=1:nmaxes
       curpvl=ps.pvltoplot(ii);
       ax(ii)=subplot(1,nmaxes,ii);
       path=avls.pvls{curpvl};
       strcmd=['cd ' path]
       eval(strcmd);
       bt=avls.cvl{curpvl};
    if(isfield(ps,'lim'))
        if(ps.lim(ii))
            bt=[bt 'lim']
        end
    end
           
       % 'a' is the target note not context notes ('' '')
       [avna{ii},t,f,avsm,mat_sm]=get_avn3(bt,'a',0.2,0.2,'','','obs0'); 
   end
   colbnds=calcbndsavn(avna,ps)
   for ii=1:length(avna)
            axes(ax(ii));
            imagesc(t,f,log(avna{ii}));syn;ylim([0,1e4]);
            hold on;
            set(ax(ii),'CLim',log(colbnds));
            plot([0 1],[7054 7054],'c--')
            linkaxes(ax);
       end


    function [colbnds]=calcbndsavn(avna,ps)
       mnfrow=floor(ps.freqlimbound(1)/ps.freqspacing);
       mxrow=ceil(ps.freqlimbound(2)/ps.freqspacing);
       for ii=1:length(avna)
        maxvl(ii)=max(max(avna{ii}(mnfrow:mxrow,:)))
        minvl(ii)=min(min(avna{ii}(mnfrow:mxrow,:)))
       end
       colbnds=[min(minvl) max(maxvl)];


       
       
       
         
   

