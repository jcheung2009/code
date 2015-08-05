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




function [outvlaczcomb,outvlmuzcomb]=plotrevdynamics(sumdyn,ps)
tm_matrix=1:.2:ps.maxx

sdynln=length(sumdyn)

bsindcomb=[];
sumdyncomb=[];
 outstruct=[];   
% 
% % first find the number of traces
% for ii=1:length(sumdyn)
%     if((max(sumdyn(ii).tms))>=ps.minx&ii~=ps.excludeind)
%         bsindcomb=[bsindcomb sumdyn(ii).bsnum];
%         sumdyncomb=[sumdyncomb ii];
%         cnt=cnt+1;
%     end
% end



outvlaczcomb=zeros(sdynln,ps.maxx+1);
outvlmuzcomb=zeros(sdynln,ps.maxx+1);
for ii=1:length(sumdyn)
    
    smcr=sumdyn(ii);
    if(~isempty(smcr.acz))
        if(ps.aligntimes)
            if(ps.subdayinterp)
               smcr.tms=smcr.adjtms;
            else
                smcr.tms=[smcr.adjtms-smcr.adjtms(1)+1]
            end
            if(ps.plotpct==0)
                aczvl=[smcr.acz]
                muzvl=[smcr.muz]
            else
            aczvl=smcr.acz/smcr.acz(1);
            muzvl=smcr.muz/smcr.acz(1);
            end
        else
            smcr.tms=[0;smcr.adjtms];
            aczvl=[0 smcr.acz]
            muzvl=[0 smcr.muz]
        
        end
    
    
        if(smcr.acz(1)>0)
            smcr.drxn=1;
        else
            smcr.drxn=0;
        end
%     if(exist('ps.addx'))
%         smcr.tms=smcr.tms+addx;
%               
        if(ps.flip)
            if(smcr.drxn==0)&(ps.plotpct==0)
                aczvl=-aczvl
                muzvl=-muzvl
            end
        end
        if(ps.subdayinterp)   
            [acvls]=interp1(smcr.tms,aczvl,1:.2:ps.maxx);
            [muvls]=interp1(smcr.tms,muzvl,1:.2:ps.maxx);
            
        else
            [int_tms,acvls]=interpvls3(smcr.tms,aczvl);
            [int_tms,muvls]=interpvls3(smcr.tms,muzvl);
        end
            if(ps.plotraw)
                if(max(smcr.tms)>ps.minx)
                    plot(smcr.tms,aczvl,'.','Color',ps.ac_col)
                    hold on;
                    plot(smcr.tms,aczvl,'Color',ps.ac_col)
                    plot(smcr.tms,muzvl,'.','Color',ps.mu_col)
                    hold on;
                    plot(smcr.tms,muzvl,'Color',ps.mu_col)
                end
        end
%                 slope=calcslope(smcr.tms(indx),yvl(indx));
%                 equalflag=1;
  
        
            ln=length(tm_matrix);
        if(max(smcr.tms)>ps.minx)
            outvlaczcomb(ii,1:ln)=acvls(1:ln)
            outvlmuzcomb(ii,1:ln)=muvls(1:ln)
        end

    end
end
            
 inds=[1:length(outvlaczcomb(:,1))]

 [outacmn,outacstd]=calcmeanstder2(outvlaczcomb(inds,:));
[outmumn,outmustd]=calcmeanstder2(outvlmuzcomb(inds,:));


% rvacmn=[0 outacmn(2:12)]
% rvmumn=[0 outmumn(2:12)]
% rvacer=[0 outacstd(2:12)]
% rvmuer=[0 outmustd(2:12)]

% 
xvec=tm_matrix
maxind=find(tm_matrix==ps.maxx);
fillx=[xvec(1:maxind) xvec(maxind:-1:1)]

muvec=[outmumn(1:maxind)+outmustd(1:maxind)]
muvec2=[outmumn(1:maxind)-outmustd(1:maxind)]
filly=[muvec(1:maxind) muvec2(maxind:-1:1)]

acvec=[outacmn(1:maxind)+outacstd(1:maxind)]
acvec2=[outacmn(1:maxind)-outacstd(1:maxind)]
filly2=[acvec acvec2(end:-1:1)]
% 
mufillcol=[0.82 0.82 0.82]
acfillcol=[0.92 0.96 0.98]
% 
% % %     mupts=mumean(1:length(indvl))
% %     acpts=acmean(1:length(indvl))
% %     yvec=[avls.initmean{notevl}*ones(length(mupts),1);mupts(end:-1:1)']
    
% figure

    hold on;
%     fill(xvec,yvec,acfillcol);
    fill(fillx,filly,acfillcol,'edgecolor','w');
    fill(fillx,filly2,mufillcol,'edgecolor','w');
plot(tm_matrix, outacmn,'Color',ps.ac_col,'Linewidth',3)
hold on;
plot(tm_matrix,outmumn,'Color',ps.mu_col,'Linewidth',3)

ps.arrowind=find(mod(tm_matrix,1)==0)

ps.col=[1 .6 .6]
ps.pct=[200]
if(ps.plotarrow)
    plotarrows2(xvec,outacmn,outmumn,ps);
end

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