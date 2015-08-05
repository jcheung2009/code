%plotscatterxy3
function [sumstats]=plotscatterbas3(sumbs,ps)
figure

for kk=ps.plotind
    ax(kk)=ps.ax(kk);
    
end
colvec={'b' 'k' 'c'}

cvcomb=[];
ptcomb=[];

mncvcomb=[];
mnptcomb=[];
bsvls_all=[];
bsvls_mn=[];
msize=6;

for ii=1:length(sumbs)
   ntinds=sumbs(ii).allnote;
   for jj=1:length(ntinds)
        [ac_cvls, mu_cvls,acpt,mupt]=calc_cv(sumbs(ii),jj);
        clear vls;
        
        if(~isempty(acpt)&~isempty(mupt))
            vls.cv(:,1)=ac_cvls;
            vls.cv(:,2)=mu_cvls;
        
            vls.pt(:,1)=acpt;
            vls.pt(:,2)=mupt;
        
            vls.cvmean=mean(vls.cv,1);
            vls.ptmean=mean(vls.pt,1);
        
            cvcomb=[cvcomb;vls.cv]
            ptcomb=[ptcomb;vls.pt]
        
            mncvcomb=[mncvcomb ;vls.cvmean]
            mnptcomb=[mnptcomb ;vls.ptmean]
        
            bsvls_all=[bsvls_all ii*ones(1,length(vls.cv(:,1)))]
            bsvls_mn=[bsvls_mn ii]
        %i.e. example
       
            if(jj==1)
                sumplot(1).col='k'
                sumplot(2).col='k'
            else
                sumplot(1).col='r'
                sumplot(2).col='r'
            end
        
            if ps.plotsum
                sumplot(1).xvls=vls.cvmean(:,1);
                sumplot(1).yvls=vls.cvmean(:,2);
                sumplot(2).xvls=vls.ptmean(:,1);
                sumplot(2).yvls=vls.ptmean(:,2);
            else
                sumplot(1).xvls=vls.cv(:,1);
                sumplot(1).yvls=vls.cv(:,2);
                sumplot(2).xvls=vls.pt(:,1);
                sumplot(2).yvls=vls.pt(:,2);   
            end
        for kk=ps.plotind
            sumplot(kk).msize=msize;
            sumplot(kk).ax=ax(kk);
            plotscatter(sumplot(kk));
        end
        hold on;
   end
   end
end
for kk=ps.plotind
    axes(ax(kk))
    axis equal
    
    if(kk==1)
        axis([0 0.05 0 0.05])
        plot([0 0.05],[0 0.05],'k--')
    else
        axis([1.5 3.5 1.5 3.5])
        plot([1.5 3.5],[1.5 3.5],'k--')
    end
end

sumstats.cvcomb=cvcomb;
sumstats.ptcomb=ptcomb;
sumstats.bsvls_all=bsvls_all;
sumstats.bsvls_mn=bsvls_mn;
sumstats.mncvcomb=mncvcomb;
sumstats.mnptcomb=mnptcomb;

% figure
% for ii=1:length(sumbs)
%    [ac_cvls, mu_cvls,acmn,mumn]=calc_cv(sumbs(ii));
%    acmncomb=[acmncomb acmn]
%    mumncomb=[mumncomb mumn]
%    bsvls=[bsvls ii*ones(1,length(acmn))]
%    %i.e. example
%    if ii==2 
%     plot(acmn, mumn, 'ro');
%    else
%        plot(acmn,mumn,'ko');
%    end
%           hold on;
%             
% plot([-10 10],[-10 10],'k-')
% 
% sumstats.acmn=acmncomb;
% sumstats.mmumn=mumncomb;
% sumstats.bsvls=bsvls
% end
function [ac_cvls, mu_cvls,sc_acmean,sc_mumean]=calc_cv(sumbs,ntvl);
  
        
        ntind=sumbs.allnote(ntvl);
        
        if(sumbs.acn(ntind,sumbs.basruns)>10)
            acmean=sumbs.acmean(ntind,sumbs.basruns)
            sc_acmean=acmean./sumbs.sfact(ntvl);
            acstdv=sumbs.acstdv(ntind,sumbs.basruns);
            ac_cvls=acstdv./acmean;
        else
            ac_cvls=[];
            sc_acmean=[];
        end
        if(sumbs.mun(ntind,sumbs.basruns)>10)
            mumean=sumbs.mumean(ntind,sumbs.basruns)
            sc_mumean=mumean./sumbs.sfact(ntvl);
            mustdv=sumbs.mustdv(ntind,sumbs.basruns);
            mu_cvls=mustdv./mumean;
        else
            mu_cvls=[];
            sc_mumean=[];
        end
   
 

function [ac_cvls, mu_cvls,sc_acmean,sc_mumean]=plotscatter(sumplot);
    axes(sumplot.ax);
    plot(sumplot.xvls,sumplot.yvls,'o','Color', sumplot.col,'MarkerSize',sumplot.msize); 
    hold on;
%     plot([-10 10],[-10 10],'k--');





    
