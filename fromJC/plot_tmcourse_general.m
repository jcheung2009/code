%rewritten 7.29.09
%instead of taking sumbs format
%just takes 1.rawtms (vector), 2. mnvalsmat (2*n vector), and an optional
%vertical hashmark matrix
%times.

% plot_timecourse2.m

function [ax] = plot_tmcourse_general(rawtms, mnvlsfb, mnvlsct, vertvlsfb, vertvlsct)

    ps=setplotvls;
    ps.plotruns=0;
    ps.plotwn=0;
    
    plotcount=3;
    
     figure;
    if (~exist('vertvlsfb'))
        vertvlsfb=[]
        vertvlsct=[]
    end
     plotvls(rawtms, mnvlsfb, mnvlsct, vertvlsfb, vertvlsct,ps);

    function [ps] = setplotvls()
    
        ps.lw=3
        ps.msize=9
        ps.errlw=2
        ps.mucol=[0.4 0.4 1]
        ps.mufillcol=[0.82 0.82 0.82]
        ps.acfillcol=[0.92 0.96 0.98]
        ps.accol='k'
        ps.meanlw=2
        ps.errht=50
        ps.acmark='o'
        ps.mumark='o'
        ps.ppf=3;
        ps.muinds=[1 4 9:19 21:25]
  
  function []=plotvls(rawtms,mnvlsfb,mnvlsct,vertvlsfb, vertvlsct,ps)
    
    rwtm=rawtms
    mntm=mean(rwtm,2);
    
    [out,ind]=sort(mntm);
    
    sbval=rwtm(1,1);
    acz=mnvlsct(1,:);
%     initmean=vls.initmean;
%     bname=vls.bname
    muz=mnvlsfb(1,:);
    if(~isempty(vertvlsfb))
       aczer=vertvlsct(1,:);
        muzer=vertvlsfb(1,:);
    end
        plot(mntm(ind)-sbval,acz(ind),'Color',ps.accol,'Linewidth',ps.lw);
    hold on;
     plot(mntm(ind)-sbval,acz(ind),'Marker',ps.acmark,'Color',ps.accol,'Markersize',ps.msize,'MarkerFaceColor',ps.accol); 
    plot(mntm(ind)-sbval,muz(ind),'Color',ps.mucol,'Linewidth',ps.lw);
    plot(mntm(ind)-sbval,muz(ind),'Marker',ps.mumark,'Color',ps.mucol,'Markersize',ps.msize,'MarkerFaceColor',ps.mucol);
    
    %plot vertical lines as error bars
    if(~isempty(vertvlsfb))
        plot([(mntm(ind)-sbval)'; (mntm(ind)-sbval)'],[(acz(ind)-aczer); (acz(ind)+aczer)],'k','Linewidth',ps.errlw);
        plot([(mntm(ind)-sbval)' ;(mntm(ind)-sbval)'],[(muz(ind)-muzer); (muz(ind)+muzer)],'Color',ps.mucol,'Linewidth', ps.errlw);
    end
    hold on;
%     plot([0 max(rwtm-sbval)],[0,0],'k--','Linewidth',2)
%     
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
          
          
          