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

%NEED TO CREATE AN OUTPUT




function [outvlaczcomb,outvlmuzcomb,sdindcomb]=plotasympstimdynamics(sumdyn,ps)
tm_matrix=1:.2:ps.maxx
sdynln=length(sumdyn)
sdindcomb=[]

bsindcomb=[];
sumdyncomb=[];
 outstruct=[];   



outvlaczcomb=zeros(sdynln,ps.maxx);
outvlmuzcomb=zeros(sdynln,ps.maxx);
ct=1
for ii=1:length(sumdyn)
    
    smcr=sumdyn(ii);
    if(ps.aligntimes)
        if(ps.subdayinterp)
            smcr.tms=smcr.exadjtms-smcr.exadjtms(1)+1;
        else
            smcr.tms=[smcr.adjtms-smcr.adjtms(1)+1]
        end
        if(ps.usepct==0)
            aczvl=[smcr.acz]
            muzvl=[smcr.muz]
        else
            aczvl=[smcr.asympacpct]
            muzvl=[smcr.asympmupct]
        end
        
    else
        smcr.tms=[0;smcr.adjtms];
        if(ps.usepct==0)
            aczvl=[0 smcr.acz]
            muzvl=[0 smcr.muz]
        else
            aczvl=[smcr.asympacpct]
            muzvl=[smcr.asympmupct]
        end
    end
    
    
    if(smcr.acz(1)>0)
        smcr.drxn=1;
    else
        smcr.drxn=0;
    end
%     if(exist('ps.addx'))
%         smcr.tms=smcr.tms+addx;
%               
    if(ps.flip)&(ps.usepct==0)
        if(smcr.drxn==0)
            aczvl=-aczvl
            muzvl=-muzvl
        end
    end
    if(ps.subdayinterp)
       [acvls]=interp1(smcr.tms,aczvl,1:.2:ps.maxx);
       [muvls]=interp1(smcr.tms,muzvl,1:.2:ps.maxx);
       ln=length(tm_matrix);
    else
        [int_tms,acvls]=interpvls3(smcr.tms,aczvl);
        [int_tms,muvls]=interpvls3(smcr.tms,muzvl);
        ln=length(acvls);
    end
  
%                 slope=calcslope(smcr.tms(indx),yvl(indx));
%                 equalflag=1;
  
    if(max(smcr.tms)>=ps.minx)
        outvlaczcomb(ct,1:ln)=acvls(1:ln)
        sdindcomb=[sdindcomb ii]
        outvlmuzcomb(ct,1:ln)=muvls(1:ln)
        ct=ct+1;
       if(ps.plotraw)
        plot(smcr.tms,aczvl,'.','Color',ps.ac_col,'MarkerSize',5)
        hold on;
        plot(tm_matrix,outvlaczcomb(ct-1,:),'Color',ps.ac_col,'Linewidth',2)
        plot(smcr.tms,muzvl,'.','Color',ps.mu_col,'MarkerSize',5)
        hold on;
        plot(tm_matrix,outvlmuzcomb(ct-1,:),'Color',ps.mu_col,'Linewidth',2)
        end
    end

end


inds=1:length(outvlaczcomb(:,1))

[outacmn,outacstd]=calcmeanstder2(outvlaczcomb(inds,:));
[outmumn,outmustd]=calcmeanstder2(outvlmuzcomb(inds,:));
figure
if(ps.subdayinterp)
    xvec=[tm_matrix]
end
fillx=[xvec xvec(end:-1:1)]
muvec=[outmumn+outmustd]
muvec2=[outmumn-outmustd]
filly=[muvec muvec2(end:-1:1)]
acvec=[outacmn+outacstd]
acvec2=[outacmn-outacstd]
filly2=[acvec acvec2(end:-1:1)]
mufillcol=[0.82 0.82 0.82]
acfillcol=[0.92 0.96 0.98]


    hold on;
%     fill(xvec,yvec,acfillcol);
    fill(fillx,filly,acfillcol);
    fill(fillx,filly2,mufillcol);
plot(xvec, outacmn,'Color',ps.ac_col,'Linewidth',3)
hold on;
plot(xvec,outmumn,'Color',ps.mu_col,'Linewidth',3)
% 
% subplot(121)
% plot([1:ps.maxx],outpctmn,'Color','g','Linewidth',4);
% plot([1:ps.maxx;1:ps.maxx],[outpctmn-outpctstd;outpctmn+outpctstd],'g')
% subplot(122)
% plot([1:ps.maxx],outeffmn,'Color','g','Linewidth',4);
% plot([1:ps.maxx;1:ps.maxx],[outeffmn-outeffstd;outeffmn+outeffstd],'g')
% 
% 
% outstruct.effvls=outvleffcomb;
% outstruct.yvls=outvlcomb;
% outstruct.effmn=outeffmn;
% outstruct.effsd=outeffstd;
% outstruct.yvlmn=outpctmn;
% outstruct.yvlsd=outpctstd;
% outstruct.bsvls=bsindcomb;
% outstruct.dynind=sumdyncomb;
% outstruct.yslope=yslope;
% outstruct.effslope=effslope;

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