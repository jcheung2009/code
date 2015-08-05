%rewritten extensively 4.16.09,
%to incorporate new figure requirements.

%takes sumdyn,
%and a ps (plotstruct).
%ps.minx - minimum x value to include
%ps.maxx - maximum x value to include.
%ps.col,  col={ 'k' 'r','c'}
%ps.colvec
%ps.type, (pct or off or dis)
%ps.addx
%ps.excludebs
%ps.plotavg=1
%ps.comb
%ps.normeff=0
%ps.plot_type, 1 is for shift, 2 is for asymp, 3 is for rev.


function [ctinds,ctindsin,meanmu,meanac]=plotcombdynamics5_pharm(sumdynin,sumbs,ps)
% tm_matrix=1:.2:ps.maxx
% if(ps.plotsum)
% axes(ps.ax);
% end
if(isfield(ps,'runtype'))
   if(ps.runtype=='rev')
       REV=1;
   else
       REV=0;
   
   end
else
    REV=0;
end

if(isfield(ps,'asymp_pct'))
    if(ps.asymp_pct)
        ASYMP_PCT=1;
    else
        ASYMP_PCT=0;
    end
else
    ASYMP_PCT=0;
end
    

if(isfield(ps,'addbas'))
    if(ps.addbas)
        ADDBAS=1;
    else
        ADDBAS=0;
    end
else
        ADDBAS=0
    end

axis(ps.plotbnds);
if(isfield(ps,'maxsd'))
    maxsd=ps.maxsd;
else
    maxsd=100
end
    sdynln=length(sumdynin)
    bsindcomb=[];
    sumdyncomb=[];
    ctinds=[];
    ctindsin=[];
    outstruct=[];   
    fixct=0;
   
    ct=1;
    ln=ps.maxx
    if(ps.roundtimes)
            tmdiff=1;
             
            outvlaczcomb=zeros(sdynln,ln);
            outvlmuzcomb=zeros(sdynln,ln);
        
    else
        
            tmdiff=.1;
            outvlaczcomb=zeros(sdynln,(ln+1)*tmdiff);
            outvlmuzcomb=zeros(sdynln,(ln+1)*tmdiff);
    end
    
    
    for ii=1:length(sumdynin) 
        smcr=sumdynin(ii);
        shiftind=find(smcr.exadjtms>0)
            shiftind2=find(abs(smcr.acz)>1);
            shiftind=intersect(shiftind,shiftind2);
%         aczvl(basind)=0;
%         muzvl(basind)=0;
        crsumbs=sumbs(smcr.bsnum);
        
        %series of if statements to exclude runs where mu concentration
        %changed.
        if(isfield(ps,'excludebs'))
            if(smcr.bsnum==ps.excludebs)
                if(intersect(smcr.shnum,ps.excludeshnum))
                    keep=0
                else
                    keep=1;
                end
            else
                    keep=1;
            end
        else
            keep=1;
        end

    if(keep)
            if(~isempty(smcr.acz))
                if(REV)
                   acpctvl=smcr.mu_pct;
                   mupctvl=smcr.ac_pct;
                   actpctvl(1)=0;
                   mupctvl(1)=0;
                   ptvl=smcr.acz;
                   inactvl=smcr.muz;
                   aczvl=smcr.lmansize;
                   muzvl=smcr.motsize;
                else
                    if(~ASYMP_PCT)
                        acpctvl=smcr.pct(shiftind);
                        mupctvl=100-smcr.pct(shiftind);
                    else
                        acpctvl=smcr.asympmotpct(shiftind);
                        mupctvl=100-acpctvl
                    end
                    ptvl=smcr.acz(shiftind);
                    inactvl=smcr.muz(shiftind);
                    aczvl=smcr.acz(shiftind);
                    muzvl=smcr.muz(shiftind);
                end
                    
            end    
           if(ADDBAS)
                [acbaszvl,mubaszvl]=calcbas(smcr,sumbs)
                aczvl=[acbaszvl aczvl]
                ptvl=[acbaszvl aczvl]
                muzvl=[mubaszvl muzvl]
                acpctvl=[NaN acpctvl]
                mupctvl=[NaN mupctvl]
                inactvl=[NaN inactvl]
            end
    
           
            if(ps.flip)
                if(smcr.drxn=='do')
%                     if(ps.plot_type=='pct')
                        aczvl=-aczvl;
                        muzvl=-muzvl;
                        ptvl=-ptvl;
                        inactvl=-inactvl;
%                     end
                end
            end
            
          
                
            end
            if(ps.roundtimes)
            %this averages values on the same day
                if(~REV)
                    adjtms=ceil(smcr.exadjtms(shiftind));
                else
                    adjtms=ceil(smcr.exadjtms);
                end
                if(ADDBAS)
                    adjtms=[0 makerow(adjtms)]
                end

                if(~isempty(adjtms))
                [adjtms,acpctvl,mupctvl,aczvl]=adj_vls(adjtms,acpctvl,mupctvl,aczvl)
                end
            
                lncomb=ln;
                combvls=[0:tmdiff:lncomb]
            else
                adjtms=smcr.exadjtms(shiftind);
           
                lncomb=(ln)*tmdiff;
                combvls=[0:tmdiff:lncomb]
            end
        
            
        if(ps.plotfixedpoints)
           fixct=fixct+1;
           for crtmwin=1:length(ps.tmwins)
               crtms=ps.tmwins{crtmwin};
               [vls,matchinds]=intersect(adjtms,crtms);

               if(~isempty(matchinds))
               meanmupct(fixct,crtmwin)=mean(calcmeanstder2(mupctvl(matchinds)));
               meanacpct(fixct,crtmwin)=mean(calcmeanstder2(acpctvl(matchinds)));
               meanacz(fixct,crtmwin)=mean(calcmeanstder2(aczvl(matchinds)));
               meanptvl(fixct,crtmwin)=mean(calcmeanstder2(ptvl(matchinds)));
               meanmuz(fixct,crtmwin)=mean(calcmeanstder2(muzvl(matchinds)));
             meaninactvl(fixct,crtmwin)=mean(calcmeanstder2(inactvl(matchinds))); 
            
              else
                  meanmupct(fixct,crtmwin)=NaN;
                  meanacpct(fixct,crtmwin)=NaN;
                  meanacz(fixct,crtmwin)=NaN;
                  meanmuz(fixct,crtmwin)=NaN;
                  meanptvl(fixct,crtmwin)=NaN;
                  meaninactvl(fixct,crtmwin)=NaN;
              end
           end
            
           if(ps.plot_type=='pct')
               muplot=meanmupct;
               acplot=meanacpct;
           elseif(ps.plot_type=='mop')
               if(~REV)
                   
                   muplot=meanmuz;
                   acplot=meanacz-meanmuz;
               else
                   muplot=meanmuz;
                   acplot=meanacz;
                   inactplot=meaninactvl;
               end
           end
           notnaind=find(~isnan(muplot(fixct,:)));
           nomatchvlsin=find(~ismember([1 2], notnaind)); 
           nomatchvls=find(~ismember([1 length(ps.tmwins)],notnaind));
           
%            if(isempty(nomatchvlsin))
%                 ctindsin=[ctindsin fixct];
%                 axes(ps.axmot)
%                 plotinds=ps.xvls;
%                 plot([plotinds(notnaind)],[meanmupct(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
%                 hold on;
% %             if(ps.plotlman)
% %             axes(ps.axlman);
% %             plot([plotinds(notnaind)],[meanacpct(fixct,notnaind)],'color','r','Marker','o','MarkerSize', 4);
% %             end
%                 hold on;
%                 if(ps.plotacz)
%                     axes(ps.axacz)
%                     plot([plotinds(notnaind)],[meanacz(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
%                     hold on;
%                 end
%            end
           if(isfield(ps,'addbas'))
               if(ps.addbas==1)
               [acbaszvl,mubaszvl]=calcbas(smcr,sumbs)
               
                    if(ps.flip)
                        if(smcr.drxn=='do')
%                     if(ps.plot_type=='pct')
                            acbaszvl=-acbaszvl;
                            mubaszvl=-mubaszvl;
%                     end
                        end
                    end
               end
           end


           if(isempty(nomatchvls)&muzvl<ps.maxsd)
                ctinds=[ctinds fixct];
                axes(ps.axmot)
                plotinds=ps.xvls;
                if(~ADDBAS)
                    if(ps.plotmot)
                        plot([plotinds(notnaind)],[muplot(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
                    end
                        hold on;
                    if(ps.plotlman)
                        axes(ps.axlman)
                        plot([plotinds(notnaind)],[acplot(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
                    end
                else
                    if(ps.plotmot)   
                    plot([1 plotinds(notnaind)],[mubaszvl muplot(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
                    end
                    hold on;
                    if(ps.plotlman)
                        axes(ps.axlman)
                        plot([1 plotinds(notnaind)],[acbaszvl-mubaszvl acplot(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
                    end
                end
                    %             
% if(ps.plotlman)
%             axes(ps.axlman);
%             plot([plotinds(notnaind)],[meanacpct(fixct,notnaind)],'color','r','Marker','o','MarkerSize', 4);
%             end
                hold on;
                if(ps.plotacz)
                     axes(ps.axacz)
                    if(~ADDBAS)
                       
                        plot([plotinds(notnaind)],[meanptvl(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
                        hold on;
                    else
                        plot([1 plotinds(notnaind)],[mubaszvl meanptvl(fixct,notnaind)],'Color','k','Marker','o','MarkerSize', 4);
                        hold on;
                    end
                end
           
     
       if(ps.interptozero)
            tm_matrix=[ps.minx:tmdiff:ps.maxx];
            startvl=1;
       else
           tm_matrix=[min(adjtms):tmdiff:ps.maxx]
           
       end
       
    if(~isempty(adjtms))
        if((max(adjtms)>=ps.minx)&(length(adjtms)>1))
    
            if(REV)
                ptvl=ptvl
            else
                ptvl=aczvl
            end
            
    [interpacvls]=interp_tw(adjtms,ptvl,tm_matrix);
    [interpmuvls]=interp_tw(adjtms,muzvl,tm_matrix);
        %which values to fill??
        %assume outvlaczcomb starts at 0 and each value is 
        %tmdiff, then to get the right value
        %if tm_matrix==0, then startvl=1,
        %if tm_matrix=.4/tmdiff=0.1, then startvl=5;
        %so formula is tm_matrix(1)/tmdiff+1;
        
%         startvl=tm_matrix(1)/tmdiff+1;
        outvlaczcomb(ct,startvl:length(interpacvls))=interpacvls
        outvlmuzcomb(ct,startvl:length(interpmuvls))=interpmuvls
        ct=ct+1;
            if(ps.plotraw)
%                 adjtms=smcr.exadjtms(shiftind);
%             plot([0:ln-1],outvlaczcomb(ct-1,:),'Color',ps.ac_col,'Linewidth',2)
                tmsind=find(adjtms<=ps.maxx);
                [out,sortind]=sort(adjtms(tmsind));
                tmsind=tmsind(sortind);
                plot(tm_matrix,interpacvls,'Color',ps.exacfillcol,'Linewidth',2)
                hold on;
                plot(tm_matrix,interpmuvls,'Color',ps.exmufillcol,'Linewidth',2)
%             plot([0:ln-1],outvlmuzcomb(ct-1,:),'Color',ps.mu_col,'Linewidth',2)
             end
%     end
        
        end
    end
    end
        end
    end
    
[outacmn]=calcmeanstder2(meanacpct(ctinds,:));
 [outmumn]=calcmeanstder2(meanmupct(ctinds,:));
 
  [outinactmn,outinactsd]=calcmeanstder2(meaninactvl(ctinds,:));
 plotinds=ps.xvls;
 for ii=1:length(plotinds)
     axes(ps.axmot)
 plot([plotinds(ii)-.2 ;plotinds(ii)+.2],[outmumn(ii);outmumn(ii)],'Color',ps.mu_col,'Linewidth',4);
  axes(ps.axlman)
 plotinds=ps.xvls;
 if(ps.plotlman)
 plot([plotinds(ii)-.2;plotinds(ii)+.2],[outacmn(ii);outacmn(ii)],'Color','r','Linewidth', 4);
 end
 end
 inds=[1:length(combvls)]
% figure
%this is a hack to fill in missing values





 [outacmn,outacstd]=calcmeanstder2(outvlaczcomb(inds,:));
[outmumn,outmustd]=calcmeanstder2(outvlmuzcomb(inds,:));

% figure
rvacmn=[outacmn]
rvmumn=[outmumn]
rvacer=[outacstd]
rvmuer=[outmustd]
% figure
if(ps.plotsum)
   axes(ps.sumax)
    plot(tm_matrix,outacmn);

    hold on;
%     plot(tm_matrix,outmumn,'r');
end
if(~isfield(ps,'mufillcol'))
    mufillcol=[0.82 0.82 0.82]
    acfillcol=[0.92 0.96 0.98]
else
    mufillcol=ps.mufillcol
    acfillcol=ps.acfillcol
end

%     xvec=combvls;
%     startind=find(combvls==ps.minx);
%     endind=find(combvls==ps.maxx);
%     inds=startind:tmdiff:endind;
    xvec=tm_matrix;
    fillx=[xvec xvec(end:-1:1)]

    muvec=[rvmumn+rvmuer]
    muvec2=[rvmumn-rvmuer]
    filly=[muvec muvec2(end:-1:1)]

    acvec=[rvacmn+rvacer]
acvec2=[rvacmn-rvacer]
filly2=[acvec acvec2(end:-1:1)]
if (ps.plotsum)
% fill(fillx,filly,'r');
fill(fillx,filly2,ps.acfillcol,'edgecolor','none');
plot(xvec, rvacmn,'k','Linewidth',1);
plot(ps.xvls,outinactmn,'ro','MarkerSize',1,'MarkerFaceColor','r','Linestyle','-','Linewidth',1)
plot([ps.xvls;ps.xvls],[outinactmn+outinactsd;outinactmn-outinactsd],'r');



end



    hold on;

    %ADD PLOT COMMANDS HERE
   
function [outvls]=interp_tw(tms,invl,inmatrix,endflag)
    if(exist('endflag'))
         [outinitvls]=interp1(tms,invl,inmatrix);
         if(isnan(outinitvls(1)))
             outinitvls(1)=outinitvls(2);
         end
          if(isnan(outinitvls(end)))
             outinitvls(end)=outinitvls(end-1);
          end
         outvls=outinitvls;
    else
         [outvls]=interp1(tms,invl,inmatrix);
    end
    
    
    function [aczvl,muzvl]=calcbas(smcr,sumbs)
        crbs=sumbs(smcr.bsnum);
        ntind=crbs.ntind;
        crshift=smcr.shnum;
        shrun=crbs.shiftruns{crshift}(1);
        basdiff=abs(crbs.flrtmvec(shrun)-crbs.flrtmvec(crbs.basruns));
        [mindiff,minind]=min(basdiff);
        basrun=crbs.basruns(minind);
        aczvl=crbs.acprez(ntind,basrun);
        muzvl=crbs.muz(ntind,basrun);
    
function [normout]=normvls(vls,norm)
    if(norm)
        normout=vls./vls(1);
    else
        normout=vls;
    end

function [yvl,yvl2,equalflag]=geteffvl(smcr,indx,ps);
     if(ps.comb&ps.normeff)
          %first normalize each
          normtargeff=norm_onevls(smcr.targeff(indx));
          normctrleff=norm_onevls(smcr.contreff(indx));
          yvl=mean([normtargeff;normctrleff]);
          yvl2=yvl;
          equalflag=1;
     elseif(~ps.comb&~ps.normeff)
            yvl=smcr.targeff(indx);
            yvl2=smcr.contreff(indx);
            equalflag=0;
     elseif(ps.comb&~ps.normeff)
            yvl=mean([smcr.targeff(indx); smcr.contreff(indx)]);
            yvl2=yvl;
            equalflag=1;
     elseif(~ps.comb&ps.normeff)
             yvl=norm_onevls(smcr.targeff(indx));
             yvl2=norm_onevls(smcr.contreff(indx));
             equalflag=0;
     end
                
function [yout]=norm_onevls(yin);
    yout=yin/mean(yin);
    
    
    function [slope]= calcslope(xin,yin);
        
        s=polyfit(xin,yin',1);
        slope=s(1);
     
 %find matching adjtms
 %say that adjtms input is 12334556
function[out_tms,outacpct,outmupct,outacz]=adj_vls(adjtms,acpct,mupct,inz)
     
     %uniquetms=123456
     %ind=123568
     [uniquetms,ind]=unique(adjtms);
     for ii=1:length(uniquetms)
         ind=find(adjtms==uniquetms(ii))
         out_tms(ii)=uniquetms(ii);
         outacpct(ii)=mean(acpct(ind));
         outmupct(ii)=mean(mupct(ind));
         outacz(ii)=mean(inz(ind));
         
      end
          
    
       
      
     
     