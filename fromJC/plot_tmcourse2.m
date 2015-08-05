%rewritten 11.21.08

% plot_timecourse2.m

function [ax] = plot_tmcourse2(sumbs, ps)

for ii=1:length(sumbs)
    ps=setplotvls(ps);
    ps.plotruns=0;
   
    ps.FILL=1
    ps.plotwn=0;
    if(~isfield(ps,'ploterr'))
        ps.ploterr=1;
    end
     if(~isfield(ps,'flip'))
        ps.flip=0;
    end
    if(~isfield(ps,'plotz'))
        ps.plotz=0
    end
    if(~isfield(ps,'plotind'))
        plotind=1:length(sumbs.aclist)
    else
        plotind=ps.plotind
    end
    
    if(exist('adjx'))
        ps.adjx=adjx;
    else
        ps.adjx=0;
    end
    if(exist('addrev'))
        ps.addrev=addrev;
    else
       ps.addrev=0;
    end
        
 end
    ppf=ps.ppf
    plotcount=3;
    
    pn=mod(ii,ppf)
    %if this is the last plot
     if(isfield(ps,'axin'))
         
         axes(ps.axin);
         ax=ps.axin
     else
         figure
         ax=gca();
     end
     if(exist('STIM'))
        ps.mucol='r'
        ps.STIM=1;
    else
        ps.mucol=[0.4 0.4 1]
        ps.STIM=0;
    end
    
        [vls]=getvals(sumbs(ii),ps,plotind);
    
   
    plotvals(vls,ax(pn),ps);



    
    function [ps] = setplotvls(ps)
    
        ps.lw=1
        ps.msize=4
        ps.errlw=2
        
%         ps.mucol=[0.4 0.4 1]
%         if(exist('STIM'))
%             ps.mucol='r'
%         end
        
        ps.mufillcol=[0.82 0.82 0.82]
        ps.acfillcol=[0.92 0.96 0.98]
        ps.accol='k'
        ps.meanlw=2
        ps.errht=50
        ps.acmark='o'
        ps.mumark='o'
        ps.ppf=3;
  
  function   [vls]=getvals(sumbs,ps,plotind)
      vls.ntind=sumbs.ntind;
     
      ntind=sumbs.ntind;
     
      if(isfield(sumbs,'rawtimes'))
          vls.subvl=floor(sumbs.rawtimes(1,1));
      else
          vls.subvl=floor(sumbs.tmvc(1,1));
      end


      %sumbs.mulist means not stim  
      
      if(ps.STIM==0)
        indvl=1:length(sumbs.mulist);
%         acindvl=find(sumbs.mulist==0)
        if(exist('plotind'))
            indvl=plotind
        end
      
        for ii=1:length(indvl)
            ind=indvl(ii)
                if(~isempty(sumbs.mulist(ind)))
                    indvl2=sumbs.mulist(ind);
                    if(indvl2==0)
                            acind=sumbs.aclist(ind,1);
                            vls.acz(ii)=sumbs.acz(ntind,acind);
                            vls.acmean(ii)=sumbs.acmean(ntind,acind)/3000;
                            vls.aczerr(ii)=sumbs.acerrz(ntind,acind);
                            vls.acstdv(ii)=sumbs.acstdv(ntind,acind)/3000;
                            vls.mumean(ii)=NaN;
                            vls.muz(ii)=NaN;
                            vls.muzerr(ii)=NaN;
                            vls.mustdv(ii)=NaN;
                            vls.rwtms(ii)=sumbs.tmvc(acind,1);
                    else
                        vls.acz(ii)=sumbs.acz(ntind,indvl2);
                        vls.acmean(ii)=sumbs.acmean(ntind,indvl2)/3000;
%                         vls.aczerr(ii)=sumbs.acerrz(ntind,indvl2)
                        vls.acstdv(ii)=sumbs.acstdv(ntind,indvl2)/3000;
                        vls.muz(ii)=sumbs.muz(ntind,indvl2);
                        vls.mumean(ii)=sumbs.mumean(ntind,indvl2)'/3000
%                         vls.muzerr(ii)=sumbs.muerrz(ntind,indvl2)
                        vls.mustdv(ii)=sumbs.mustdv(ntind,indvl2)/3000;
                        vls.rwtms(ii)=sumbs.tmvc(sumbs.mulist(ind),1);
                    end
        end
        end
    vls.rawtmsall=sumbs.tmvc(:,1);
    vls.basruns=sumbs.basruns;
%     vls.revruns=sumbs.revruns;
    vls.shiftruns=sumbs.shiftruns
    vls.initruns=sumbs.initind;
    vls.subruns=sumbs.subruns;
    vls.initmean=sumbs.initmean;
    vls.mulist=sumbs.mulist;
    vls.bname=sumbs.bname;
    vls.wnon=sumbs.flr_wnon
    vls.wnoff=sumbs.flr_wnoff
      
      %STIM
      else
        if(exist('plotind'))
            indvl=plotind
        else
            plotind=1:length(sumbs.tmvec(:,1))
        end

          vls.rwtms=sumbs.tmvec(plotind,1);
          [sortout,sortind]=sort(vls.rwtms);
          plotind=plotind(sortind);
          vls.rwtms=sumbs.tmvec(plotind,1);
          vls.rwtms=sumbs.tmvec(plotind);
          vls.muz=sumbs.muz(plotind);
          vls.acz=sumbs.acz(plotind);
          
          vls.acmean=sumbs.acmean(plotind)/3000;
          vls.mumean=sumbs.mumean(plotind)/3000
          vls.initmean=sumbs.initmean;
      end
     if(ps.addrev)
         revindcomb=[];
         revrunscomb=[];
         asyrevindcomb=[];
         asyrevrunscomb=[];
        for ii=1:length(sumbs.revruns)
            if(isfield(sumbs,'mulist'))
                
                [a,b,revind]=intersect(sumbs.revruns{ii},sumbs.mulist);
                [a,b,asyrevind]=intersect(sumbs.asymprevruns{ii},sumbs.mulist);
            else
                revind=sumbs.revruns{ii}
                asyrevind=sumbs.asymprevruns{ii}
            end
            
            revrunscomb=[revrunscomb sumbs.revruns{ii}']
            revindcomb=[revindcomb makerow(revind)];
            asyrevrunscomb=[asyrevrunscomb sumbs.asymprevruns{ii}']
            asyrevindcomb=[asyrevindcomb makerow(asyrevind)];
               
        end
        
        if(ps.STIM==0)
            vls.revtms=sumbs.rawtimes(revrunscomb,1);
            vls.revmuz=sumbs.mumean(1,revrunscomb)/3000;
        
            vls.asyrevtms=sumbs.rawtimes(asyrevrunscomb,1);
            vls.asyrevmuz=sumbs.mumean(1,asyrevrunscomb)/3000;
        else
            
            vls.revtms=sumbs.tmvec(revrunscomb,1);
            vls.revmuz=sumbs.mumean(revrunscomb)/3000;
        
            vls.asyrevtms=sumbs.tmvec(asyrevrunscomb,1);
            vls.asyrevmuz=sumbs.mumean(asyrevrunscomb)/3000;
            
        end
        
         
     end
      
      
  function []=plotvals(vls,ax,ps);
    axes(ax);
    rwtm=vls.rwtms
    if(ps.plotz)
        acz=vls.acz;
        muz=vls.muz;
        initmean=0;
        vls.initmean=0;
    else
        acz=vls.acmean;
     muz=vls.mumean
     initmean=vls.initmean;
    end
    
    if(ps.flip)
        acz=-acz;
        muz=-muz;
    end
    if(isfield(vls,'rawtmsall'))
        rwtmall=vls.rawtmsall;
        sbval=vls.subvl;
        bname=vls.bname
        aczer=vls.acstdv
        muzer=vls.mustdv
    end
if(~exist('sbval'))
    sbval=rwtm(1);
    aczer=0
    muzer=0
end
  if(ps.FILL)
        xvec=rwtm-sbval
        if(ps.adjx)
            xvec=xvec-xvec(1);
        end
        notnaind=find(~isnan(muz));
        xvec=makerow(xvec)
        muxvec=xvec(notnaind);
        fillx=[xvec muxvec(end:-1:1)]
    

        acvec=[acz]
        acvec=makerow(acvec);
        muvec=muz;
        muvec2=[muz(notnaind)]
        muvec2=makerow(muvec2);
        filly=[acvec  muvec2(end:-1:1)]

% acvec=[rvacmn+rvacer]
% acvec2=[rvacmn-rvacer]
% filly2=[acvec acvec2(end:-1:1)]

        mufillcol=[0.82 0.82 0.82]
acfillcol=[0.92 0.96 0.98]

% %     mupts=mumean(1:length(indvl))
%     acpts=acmean(1:length(indvl))
%     yvec=[avls.initmean{notevl}*ones(length(mupts),1);mupts(end:-1:1)']
    

    hold on;
%     fill(xvec,yvec,acfillcol);
% filly([1 end])=0
% filly2([1 end])=0
    fill(fillx,filly,mufillcol,'edgecolor','w');
%     fill(fillx,filly2,mufillcol);
%     
    if(isfield(ps,'plotasympind'))
        crvec=muvec(ps.plotasympind);
        crxvec=xvec(ps.plotasympind);
        
        motvec=[ps.asympvl ps.asympvl]
        combxvec=[crxvec(end) crxvec(1)]
        xcomb=[crxvec combxvec];
        ycomb=[crvec motvec];
         fill(xcomb,ycomb,acfillcol,'edgecolor','w'); 
    end
       if(isfield(ps,'plotbasind'))
        crvec=muvec(ps.plotbasind);
        crxvec=xvec(ps.plotbasind);
        
        motvec=[vls.initmean/3000 vls.initmean/3000]
        combxvec=[crxvec(end) crxvec(1)]
        xcomb=[crxvec combxvec];
        ycomb=[crvec motvec];
         fill(xcomb,ycomb,acfillcol,'edgecolor','w'); 
       end
    end  
        
    
  
 



   
    plot(xvec,acz,'Color',ps.accol,'Linewidth',ps.lw);
    hold on;
     plot(xvec,acz,'Marker',ps.acmark,'Color',ps.accol,'Markersize',ps.msize,'MarkerFaceColor',ps.accol); 
    plot(xvec(notnaind),muz(notnaind),'Color',ps.mucol,'Linewidth',ps.lw);
    plot(xvec(notnaind),muz(notnaind),'Marker',ps.mumark,'Color',ps.mucol,'Markersize',ps.msize,'MarkerFaceColor',ps.mucol);
    
    %plot vertical lines as error bars
    if(ps.ploterr)
    plot([(xvec); (xvec)],[(acz-aczer); (acz+aczer)],'k','Linewidth',ps.errlw);
    plot([(xvec) ;(xvec)],[(muz-muzer); (muz+muzer)],'Color',ps.mucol,'Linewidth', ps.errlw);
    end
    hold on;
    plot([0 max(xvec)],[initmean/3000,initmean/3000],'k--','Linewidth',2)
    
    if ps.plotwn
         wnheight=1.1*abs(max(acz))+1.3;
        plotwnbnds(vls.wnon, vls.wnoff, vls.subvl, wnheight)
       
    
    end
    if (ps.plotruns)
       basht=1.1*abs(max(acz));
       shiftht=basht+.3;
       subht=basht+.6;
       initht=basht+.9
       revht=basht+1.2;
       
       %plot bs
       basruns=vls.basruns;
       bashtvc=basht*ones(length(basruns),1);
       xvec=rwtmall(basruns)-sbval;
       plot([xvec';xvec'],[bashtvc'-.1;bashtvc'+.1],'r');
       
       %plotshift
       shiftruns=vls.shiftruns;
       for ii=1:length(shiftruns)
           if(~isempty(shiftruns{ii}))
                shftvls=shiftruns{ii};
                shifthtvc=shiftht*ones(length(shftvls),1);
                xvec=rwtmall(shftvls)-sbval;
                plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'c');
           end
       end
           
       
       initruns=vls.initruns;
       for ii=1:length(initruns)
           if(~isempty(initruns{ii}))
                shftvls=initruns{ii};
                shifthtvc=initht*ones(length(shftvls),1);
                xvec=rwtmall(shftvls)-sbval;
                plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'k');
           end
       end

     subruns=vls.subruns;
       for ii=1:length(subruns)
           if(~isempty(subruns{ii}))
                shftvls=subruns{ii};
                shifthtvc=subht*ones(length(shftvls),1);
                xvec=rwtmall(shftvls)-sbval;
                plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'g');
           
       end
       end
      revruns=vls.revruns;
       for ii=1:length(revruns)
           if(~isempty(revruns{ii}))
                shftvls=revruns{ii};
                shifthtvc=revht*ones(length(shftvls),1);
                xvec=rwtmall(shftvls)-sbval;
                plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'m');
           end
       end
        
    end
    
    if(ps.addrev)
        rev_vec=vls.revtms-sbval
        asyrev_vec=vls.asyrevtms-sbval;
        if(ps.adjx)
            rev_vec=rev_vec-xvec(1);
            asyrev_vec=vls.asyrevtms-sbval;
        end
        rev_vec=makerow(rev_vec)
        asyrev_vec=makerow(asyrev_vec);
          plot(rev_vec,vls.revmuz,'Marker',ps.mumark,'Color','c','Markersize',ps.msize,'MarkerFaceColor',ps.mucol);
          hold on;
          plot(asyrev_vec,vls.asyrevmuz,'Marker',ps.mumark,'Color','g','Markersize',ps.msize,'MarkerFaceColor',ps.mucol);
    end
    
   
    box off;
%     title(bname )
  
 function []=plotwnbnds(wnon, wnoff, subvl, wnheight)
     
     for ii=1:length(wnon)
         for jj=1:length(wnon{ii})
            xvec1=wnon{ii}(jj)-subvl
            xvec2=wnoff{ii}(jj)-subvl
            wnht=wnheight*ones(length(xvec1),1);
            plot([xvec1;xvec1],[wnht'-.1; wnht'+.1],'k')
            plot([xvec2;xvec2],[wnht'-.1;wnht'+.1],'k')
            plot([xvec1;xvec2],[wnht';wnht'],'k')
         end
     end
          
          
          