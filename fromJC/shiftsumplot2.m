%written 11.11.08, meant to compare offset runs across birds, input is a
%ps, a plot struct, and shfts, which is outputted by shiftanal2.
function [ax]=shiftsumplot2(shfts,ps)
   
 
 %find which values are targeted and which values are controls.
 for ii=1:length(shfts)
     if(shfts(ii).ntype=='targ')
         targvec(ii)=1
     else
         targvec(ii)=0;
     end
 end     
%get ind to plot.
[indtoplot]=getindtoplot(shfts,ps, targvec);
[ax]=plotoffset(shfts,ps,indtoplot)

function [indtoplot]=getindtoplot(shfts,ps,targvec)
    %indtoplot is a cell array of form
    %which takes shfts(ii)
    %and turns it into indtoplot{ii}(jj), where subruns(jj)
    %ps. exclude takes form
    %improvising the following backward approach
    %indtoplot{ii}{jj}=0 if to be excluded
    %=1 if target
    %=2 if control
    
    for ii=1:length(shfts)
        for jj=1:length(shfts(ii).subruns)
            if (ps.exclude{ii}(jj))
                indtoplot{ii}(jj)=0;
            else 
                if(shfts(ii).ntype=='targ')
                    indtoplot{ii}(jj)=1;
                else
                    indtoplot{ii}(jj)=2;
                end
            end
        end
    end
    
 function [axtrg]=plotoffset(shfts,ps,indtoplot)
     nrows=20
     ncol=2;
     hold on;
     targcnt=1;
     ctrlcnt=1;
     for ii=1:length(indtoplot)
        for jj=1:length(indtoplot{ii})
            if(indtoplot{ii}(jj))
                [shs,subx, subrns]=getshsvls(shfts,ii,jj);
                
                
                [diff, differ]=calcdiff(shs, subrns,jj)
                
                if(indtoplot{ii}(jj)==1)
                    axtrg(targcnt)=subplot(nrows,ncol,targcnt*2-1);
                    plot(subx',diff,'k-')
                    plot([subx' ;subx'],[diff+differ;diff-differ],'k');
                    if(shs.contrind)
                        axctrl(ctrlcnt)=subplot(nrows,ncol,ctrlcnt*2-1);
                        [shs,subx,subrns]=getshsvls(shfts,shs.contrind,jj);
                        if(indtoplot{shs.contrind+1}(jj))
                           plot(subx',diff,'k-')
                           plot([subx';subx'],[diff+differ;diff-differ],'k.');
                        end
                    end
                
                    ctrlcnt=ctrlcnt+1;
                    targcnt=targcnt+1;
                 end
                    end
        end
%         linkaxes(axctrl);
        linkaxes(axtrg);
     end

function [diff, differ]=calcdiff(shs,subrns,subrnind)
    diff=-shs.acz(subrns)+shs.muz(subrns);
    differ=(shs.acerrz(subrns)+shs.muerrz(subrns))/2;
    if(shs.mxshift(subrnind)>0)
        diff=-diff;
    end
    
function [shs, subx,subrns]=getshsvls(shfts,shsind,runind)
                shs=shfts(shsind)
                flrtmvc=shs.flrtmvec
                flrwnon=shs.flr_wnon{runind}(end);
                ofst_tm=flrtmvc-flrwnon;
                subrns=shs.subruns{runind};
                subx=ofst_tm(subrns);
    
    