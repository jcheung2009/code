%written 11.07 in order to show data across birds/runs.
%takes shft_s struct, created with shiftanal2.

function [ax]=shiftplot2(shft_s,ppf,targ)
    %in first run, setting this up as a three column subplout
    %first column is raw zscore values for acsf/muscimol
    %second column only shows points beginning with first point which is
    %within one standard dev of maximum shift
    %2nd column is amount of actual pitchshift
    %3rd column is the percent recovery.
 figcount=1;
 ncol=5;
 
 %find which values are targeted and which values are controls.
 


for ii=1:length(shft_s)
     shs=shft_s(ii);
     rtyp=shs.ntype;
     %is this a target note or a control note.
     if rtyp=='targ'
        figure;
        rownum=1;
        %calculate total number of rows needed for this figurel
        if(ii<length(shft_s))
            if(shft_s(ii+1).ntype=='ctrl');
                nrows=length(shs.shiftruns)+1;
            else
                nrows=length(shs.shiftruns)+1;
            end
        else
            nrows=length(shs.shiftruns)+1
        end
     end
                
     axsum=plotsum(nrows,ncol,shs);
     axshift=plotshift(nrows,ncol,shs);
     axsub=plotsub(nrows,ncol,shs);
    axoff=plotoff(nrows,ncol,shs);
     axpct=plotpct(nrows,ncol,shs);
     axeff=ploteff(nrows,ncol,shft_s,ii);
     
     linkaxes(axpct);
  
    linkaxes(axshift,'x');
    linkaxes(axoff);
    axes(axpct(1));
    axis([0 8 -10 75])
    axes(axoff(1));
    axis([0 8 -0.2 2])
    axes(axsum)
    title(shs.bname)
    
    
end
return;

function [axvec]=plotsum(nrows,ncol,shs)
     %each ii is offset by ncols for total count.
     if shs.ntype=='targ'
        axvec=subplot(nrows,ncol,1:floor(ncol/2));
     else
         axvec=subplot(nrows,ncol,(ncol/2+1):ncol);
     end
    flrtmvc=shs.flrtmvec
    flr_wnon=shs.flr_wnon
    allruns=shs.allruns{1};
     ofst_tm=flrtmvc-flrtmvc(1);
     x=ofst_tm(allruns);
     yac=shs.acz(allruns);
     ymu=shs.muz(allruns);
     yacer=shs.acerrz(allruns);
     ymuer=shs.muerrz(allruns);
     plot(x,yac,'k-')
     hold on;
     plot(x,ymu,'r-');
     plot([x'; x'],[(yac+yacer); (yac-yacer)],'k');
     plot([x'; x'],[(ymu+ymuer); (ymu-ymuer)],'r');
     box off;
     return;
     
function [axvec]=plotshift(nrows,ncol,shs)   
    for ii=1:length(shs.shiftruns)
        
        axvec(ii)=subplot(nrows,ncol,ncol*(ii)+1);
        subrns=shs.shiftruns{ii}
        flrtmvc=shs.flrtmvec;
        flr_wnon=shs.flr_wnon{ii};
        ofst_tm=flrtmvc-flrtmvc(1);
        x=ofst_tm(subrns);
        
        yac=shs.acz(subrns);
        ymu=shs.muz(subrns);
        
        yacer=shs.acerrz(subrns);
        ymuer=shs.muerrz(subrns);
        plot(x,yac,'k-')
        hold on;
        plot(x,ymu,'r-');
        plot([x'; x'],[(yac+yacer); (yac-yacer)],'k');
        plot([x'; x'],[(ymu+ymuer); (ymu-ymuer)],'r');
        box off;
        
        %plot horizontal run for the subrun.
        xlintms=ofst_tm([shs.subruns{ii}(1) shs.subruns{ii}(end)])
%         plot([xlintms(1) xlintms(2)],[0 0],'k');
    end
function [axvec]=plotsub(nrows,ncol,shs)
    for ii=1:length(shs.subruns)
        axvec(ii)=subplot(nrows,ncol,ncol*(ii)+2); 
        subrns=shs.subruns{ii}
        flrtmvc=shs.flrtmvec;
        flr_wnon=shs.flr_wnon{ii};
        ofst_tm=flrtmvc-flrtmvc(subrns(1))+(flrtmvc(subrns(1))-flr_wnon(end));;
        x=ofst_tm(subrns);
        
        yac=shs.acz(subrns);
        ymu=shs.muz(subrns);
        
        yacer=shs.acerrz(subrns);
        ymuer=shs.muerrz(subrns);
        if (length(subrns)>1)
            plot(x,yac,'k-')
            hold on;
            plot(x,ymu,'r-');
            plot([x'; x'],[(yac+yacer); (yac-yacer)],'k');
            plot([x'; x'],[(ymu+ymuer); (ymu-ymuer)],'r');
            box off;
        end
    end

function [axvec]=plotoff(nrows,ncol,shs)
    for ii=1:length(shs.subruns)
        axvec(ii)=subplot(nrows,ncol,ncol*(ii)+3); 
        
        subrns=shs.subruns{ii}
        flrtmvc=shs.flrtmvec;
        
        ofst_tm=flrtmvc-flrtmvc(subrns(1));
        x=ofst_tm(subrns);
        
        ydiff=-shs.acz(subrns)+shs.muz(subrns);
        ydiffer=(shs.acerrz(subrns)+shs.muerrz(subrns))/2;
        
        if(shs.mxshift(ii)>0)
            ydiff=-ydiff;
            
        end
           
            plot(x,ydiff,'k-')
            hold on;
            plot([x'; x'],[(ydiff+ydiffer); (ydiff-ydiffer)],'k');
           
            box off;
    end

function [axvec]=plotpct(nrow,ncol,shs)
  
      for ii=1:length(shs.subruns)
        axvec(ii)=subplot(nrow,ncol,ncol*(ii)+4); 
        
        subrns=shs.subruns{ii}
        flrtmvc=shs.flrtmvec;
        
        ofst_tm=flrtmvc-flrtmvc(subrns(1));
        x=ofst_tm(subrns);
        yac=shs.acz(subrns);
        ymuc=shs.muz(subrns);
        yacer=shs.acerrz(subrns);
        ydiff=-shs.acz(subrns)+shs.muz(subrns);
        ydiffer=(shs.acerrz(subrns)+shs.muerrz(subrns))/2;
        if(shs.mxshift(ii))
            ydiff=-ydiff;
           
        end
        ypct=ydiff./yac*100;
       
        ypcter=ypct.*(ydiffer./(ymuc +ydiffer./yac))/2
        if(shs.ntype=='targ')    
            plot(x,ypct,'k-')
            hold on;
            plot([x'; x'],[(ypct+ypcter); (ypct-ypcter)],'k');
        end   
            box off;
        
      end
     
  function [axvec]=ploteff(nrow,ncol,shft_s,shind)
      shs=shft_s(shind);
      if(shs.contrshsind);
          ctrind=shs.contrntind;
          ctrl=1;
      
      
      for ii=1:length(shs.subruns)
        axvec(ii)=subplot(nrow,ncol,ncol*(ii)+5); 
        
        subrns=shs.subruns{ii}
        flrtmvc=shs.flrtmvec;
        
        ofst_tm=flrtmvc-flrtmvc(subrns(1));
        x=ofst_tm(subrns);
        if(ctrl)
            yeff=shs.effvls([shs.allnote],subrns);
        end
       
        if(shs.ntype=='targ')    
            plot(x,yeff,'k-')
            
        end   
            box off;
        
      end
      else
          axvec=[];
      end
 
    