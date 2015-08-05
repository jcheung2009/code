%rewritten 12.10.09
%so as to plot acsf and muscimol including all aclist runs.
%(even days when no muscimol)

% plot_timecourse2.m

%THis version explicitly includes beginning and end of day in different
%colors

function [] = plot_tmcourse2revaconly(crbs, plotind,ps)
    

    ps=setplotvls(ps);
    ps.plotruns=0;
    ps.FILL=1
    ps.plotwn=0;
    if(isfield(ps,'adjx'))
        ps.adjx=ps.adjx;
    else
        ps.adjx=0;
    end
    ppf=ps.ppf
    plotcount=3;
    
     %if this is the last plot
%      if(~exist('axin'))
%          if(pn==0)
%             pn=ppf;
%          end
%         if(pn==1)
%             figure;
%         end
%         ax(pn)=subplot(ppf,1,pn)
%      else
%          axes(axin);
%          ax=axin
%      end
    
   
    [vls]=getvals(crbs,plotind,ps);
    
    if(isfield(ps,'STIM'))
        ps.mucol='r'
    else
        ps.mucol=[0.4 0.4 1]
    end
    ps.mucol=[0.4 0.4 1]
    plotvals(vls,ps);


    
    function [ps] = setplotvls(ps)
    
        ps.lw=2
        ps.ntind=1;
        ps.msize=6
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
  
  %this version is rewritten to calculate beginning and endvls
        function   [vls]=getvals(crbs,plotind,ps)
      vls.ntind=ps.ntind;
      ntind=ps.ntind;
%       vls.subvl=floor(avls.tmvc(1,1));
      acindvl=ps.acindvl
      muindvl=ps.muindvl
        for ii=1:length(acindvl)
                crind=acindvl(ii)
                crinitvls=crbs.initptvls{crind};
                crendvls=crbs.endptvls{crind};
                vls.acinitmean(ii)=mean(crinitvls);
                vls.acendmean(ii)=mean(crendvls);
                 vls.acinitsd(ii)=std(crinitvls);
                 vls.acendsd(ii)=std(crendvls);
%             else
%                 runvl=avls.aclist(ind,1);
%                 vls.acmean(ii)=avls.acz(ntind,runvl);
%                  vls.aczerr(ii)=avls.acerracz(ntind,runvl);
%                  vls.mumean(ii)=0
%                  vls.muzerr(ii)=0
%             end
%                 vls.aczerr(ii)=avls.acerracz(ntind,ind)
%             vls.acstdv(ii)=avls.stdv{ntind}(ind)/3000;  
       
     
            vls.initrwtms(ii)=mean(crbs.init_tms{crind});
            vls.endrwtms(ii)=mean(crbs.end_tms{crind});
        end
        
        for ii=1:length(muindvl)
            
            crind=muindvl(ii)
            cr_run=crbs.murun(crind);
                
            vls.mumean(ii)=crbs.mumean(1,cr_run);
            vls.mutms(ii)=mean(crbs.mutms{crind});
                 
        end
%             else
%                 runvl=avls.aclist(ind,1);
%                 vls.acmean(ii)=avls.acz(ntind,runvl);
%                  vls.aczerr(ii)=avls.acerracz(ntind,runvl);
%                  vls.mumean(ii)=0
%                  vls.muzerr(ii)=0
%             end
%                 vls.aczerr(ii)=avls.acerracz(ntind,ind)
%             vls.acstdv(ii)=avls.stdv{ntind}(ind)/3000;  
       
     
%             vls.initrwtms(ii)=mean(crbs.init_tms{crind});
%             vls.endrwtms(ii)=mean(crbs.end_tms{crind});
%     vls.rawtmsall=avls.rawtimes(:,1);
   
%     vls.initmean=avls.initmean{ntind};
%     vls.mulist=avls.mulist;
%     vls.bname=avls.bname;
%     vls.wnon=sumbs.flr_wnon
%     vls.wnoff=sumbs.flr_wnoff
    
    vls.combactms=[makerow(vls.initrwtms) makerow(vls.endrwtms)] ;
    [vls.combactms,sortind]=sort(vls.combactms);
    vls.combacvls=[makerow(vls.acinitmean) makerow(vls.acendmean)];
    vls.combacvls=vls.combacvls(sortind);
    vls.zerotime=crbs.tmvc(ps.startind,1);
    vls.combactms=vls.combactms-vls.zerotime;
    vls.mutms=vls.mutms-vls.zerotime;
    vls.init_tms=vls.initrwtms-vls.zerotime;
    vls.end_tms=vls.endrwtms-vls.zerotime;
    vls.basmean=crbs.initmean./3000;
%     plotind=avls.aclist(plotind(sortind));
%     vls.rwtms=avls.tmvc(plotind,1);
% %     vls.acmean=avls.mnvl{ntind}(plotind)/3000;
%     for ii=1:length(plotind)
%         vls.adjvls{ii}=avls.adjvls{ntind}{plotind(ii)}
%     end
%     vls.plotind=plotind;
%     vls.acstdv=avls.stdv{ntind}(plotind)/3000;  
%   
            
            
            function []=plotvals(vls,ps)
  %this function has to plot muscimol vals
  %this function has to plot muscimol line
  %this function has to plot ac vls (two colors)
  %this function has to plot acline
  %this function has to plot two fills.
%                 
%                 axes(ps.ax);
%     rwtm=floor(vls.rwtms)
%     acz=vls.acmean;
%      muz=vls.mumean
%      nzind=find(vls.mumean)
%      
%      initmean=vls.initmean;
%     if(isfield(vls,'rawtmsall'))
%         rwtmall=vls.rawtmsall;
%         sbval=vls.subvl;
%         bname=vls.bname
% %         aczer=vls.acstdv./sqrt(length(vls.acmean))
%         aczer=vls.aczerr
%         acstdv=vls.acstdv;
% %         muzer=vls.mustdv./sqrt(length(vls.mumean));
%     end
% if(~exist('sbval'))
%     sbval=rwtm(1);
%     aczer=0
%     muzer=0
% end

%  plotedge(ps.plotedgeybnds,ps.plotedgexbnds);
hold on;

combactms=vls.combactms;
combacvls=vls.combacvls/3000;
initactms=vls.init_tms;
initacvls=vls.acinitmean/3000;
endactms=vls.end_tms;
endacvls=vls.acendmean/3000;
mutms=vls.mutms;
muvls=vls.mumean/3000;


  if(ps.FILL)
        xvec=combactms;
%          if(ps.adjx)
%             xvec=xvec-xvec(ps.startind);
%         end
        xvecmu=makerow(mutms);
        xvec=makerow(xvec);
        fillxvecmu=[combactms(1) xvecmu combactms(end)]
        xvecbas=[min(fillxvecmu) max(fillxvecmu)]
        fillx=[xvec fillxvecmu(end:-1:1)]
        fillx2=[xvecmu  xvecmu(end) xvecmu(1)]

        muvec=[combacvls]
        muvec=makerow(muvec);
        %for fill against acsf
        muvectop=makerow([muvls(1) muvls muvls(end)])
        muvecbot=makerow(muvls);
      
        muvecbas=[0 0]
                
        
        filly=[muvec  muvectop(end:-1:1)]
        filly2=[muvecbot muvecbot(1) muvecbot(1) ];

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
    fill(fillx,filly,mufillcol,'edgecolor','none');
    fill(fillx2,filly2,acfillcol,'edgecolor','none');
%     
    end  

if(isfield(ps,'plotlman'))
   if(ps.plotlman)
       xvecmu=xvec(nzind);
       xvecac=xvec
      [diffx,diffy]=getdiff(xvecmu,xvecac,muz(nzind),acz)
      hold on;
      plot(diffx(nzind),diffy(nzind),'Marker',ps.acmark','Color','r','MarkerFaceColor','r','Linewidth',ps.lw)
   end
end


    plot(xvec,combacvls,'Color',ps.accol,'Linewidth',ps.lw);
    hold on;
     plot(initactms,initacvls,'Linestyle','none','Marker',ps.acmark,'Color',ps.accol,'Markersize',ps.msize,'MarkerFaceColor',ps.accol);
      plot(endactms,endacvls,'Linestyle','none','Marker',ps.acmark,'Color','r','Markersize',ps.msize,'MarkerFaceColor','r'); 
    plot(xvecmu,muvls,'Color',ps.mucol,'Linewidth',ps.lw);
    plot(xvecmu,muvecbot,'Linestyle','none','Marker',ps.mumark,'Color',ps.mucol,'Markersize',ps.msize,'MarkerFaceColor',ps.mucol);
    
    %plot vertical lines as error bars

%     plot([(xvec); (xvec)],[(acz-acstdv); (acz+acstdv)],'k','Linewidth',ps.errlw);
% %     plot([(xvec) ;(xvec)],[(muz-muzer); (muz+muzer)],'Color',ps.mucol,'Linewidth', ps.errlw);
%     
    hold on;
    plot([0 max(xvec)],[vls.basmean,vls.basmean],'k--','Linewidth',2)
    
    if ps.plotwn
         wnheight=1.1*abs(max(acz))+1.3;
        plotwnbnds(vls.wnon, vls.wnoff, vls.subvl, wnheight)
       
    
    end
    if(isfield(ps,'plotraw'))
        axes(ps.axraw);
        for ii=1:length(vls.plotind)
            indht=find(vls.adjvls{ii}(:,3)==1);
            indms=find(vls.adjvls{ii}(:,3)==0);
            lnht=length(indht);
            lnms=length(indms);
            plot(xvec(ii)*ones(lnht,1),vls.adjvls{ii}(indht,2),'r.');
            hold on;
            
            plot(xvec(ii)*ones(lnms,1),vls.adjvls{ii}(indms,2),'k.');
        end
    end
    
    if(isfield(ps,'wnind'))
        axes(ps.wnax);
        ind=find(ps.wnind>0)
        %make xvec
        %make yvec
        for ii=1:length(ind)
           xvecout(2*ii-1)=xvec(ind(ii))-.5
           xvecout(2*ii)=xvec(ind(ii))+.5
           wnout(2*ii-1)=ps.wnbnds(ii);
           wnout(2*ii)=ps.wnbnds(ii);
        end
        xcomb=[xvecout xvecout(end:-1:1)]
        yout=[wnout ps.wnbot*ones(1,length(wnout))];
        fill(xcomb,yout,'r','EdgeColor','none')
    end
        
   function [xdiff,ydiff]=getdiff(x1, x2, y1, y2)
       minvl=min([x1 x2])
       maxvl=max([x1 x2])
       tms=minvl:1:maxvl
       interpy1=interp1(x1,y1,tms);
       interpy2=interp1(x2,y2,tms);
       xdiff=tms;
       ydiff=interpy2-interpy1;
     
    
    
    
%        xvec=rwtmall(basruns)-sbval;
%        plot([xvec';xvec'],[bashtvc'-.1;bashtvc'+.1],'r');
%        
%        %plotshift
%        shiftruns=vls.shiftruns;
%        for ii=1:length(shiftruns)
%            if(~isempty(shiftruns{ii}))
%                 shftvls=shiftruns{ii};
%                 shifthtvc=shiftht*ones(length(shftvls),1);
%                 xvec=rwtmall(shftvls)-sbval;
%                 plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'c');
%            end
%        end
%            
%        
%        initruns=vls.initruns;
%        for ii=1:length(initruns)
%            if(~isempty(initruns{ii}))
%                 shftvls=initruns{ii};
%                 shifthtvc=initht*ones(length(shftvls),1);
%                 xvec=rwtmall(shftvls)-sbval;
%                 plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'k');
%            end
%        end
% 
%      subruns=vls.subruns;
%        for ii=1:length(subruns)
%            if(~isempty(subruns{ii}))
%                 shftvls=subruns{ii};
%                 shifthtvc=subht*ones(length(shftvls),1);
%                 xvec=rwtmall(shftvls)-sbval;
%                 plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'g');
%            
%        end
%        end
%       revruns=vls.revruns;
%        for ii=1:length(revruns)
%            if(~isempty(revruns{ii}))
%                 shftvls=revruns{ii};
%                 shifthtvc=revht*ones(length(shftvls),1);
%                 xvec=rwtmall(shftvls)-sbval;
%                 plot([xvec';xvec'],[shifthtvc'-.1;shifthtvc'+.1],'m');
%            end
%        end
% %         
%     end
   
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
          

    function []=plotarrows(origarrow,ps)
% %         axes(axhist);
% %         if(shiftdrxn==0)
% %             arrow_col=[1 .6 .6]
% %         else
% %             arrow_col=[.6 .6 1]
% %         end
if(isfield(ps,'arrow_col'))
    arrow_col=ps.arrow_col;
    
else
    if(origarrow(4)-origarrow(2)<0)
        arrow_col=[1 .6 .6]
    else
        arrow_col=[.6 .6 1]
    end
    
end
        origlen=origarrow(4)-origarrow(2);
        if(origlen<0)
            y1=origarrow(2);
            
        else
            y1=origarrow(2);
            
        end
        y2=origarrow(4);
%         shiftlen=shiftarrow(3)-shiftarrow(1);
%         headwidth(1)=.8/abs(origlen);
% %         headwidth(2)=.01/abs(shiftlen);
%         headht(1)=.01/abs(origlen)
%         headht(2)=.01/abs(shiftlen)
axis square
hold on;
if (isfield(ps,'axbnds'))
    axis(ps.axbnds)
end
    
%             global ColorOrder, ColorOrder=[];
%             set(gca,'ColorOrder',arrow_col)
%                global LineWidthOrder, LineWidthOrder=[2];
            
            h=arrow([origarrow(1) y1],[origarrow(3) y2],'Length',3);
            set(h,'FaceColor',arrow_col);
            set(h,'EdgeColor','none');
            set(h,'Linewidth',2)
%         arrowh([origarrow(1) origarrow(3)],[y1 y2],arrow_col,[100 100]);
%         plot([origarrow(1) origarrow(3)],[origarrow(2) origarrow(4)],'Color',arrow_col,'Linewidth',2)
        
%         plot_arrow(shiftarrow(1),shiftarrow(2),shiftarrow(3),shiftarrow(4),'Color',arrow_col,'Linewidth',3,'headwidth',headwidth(2),'headheight',headht(2),'facecolor',arrow_col,'edgecolor',arrow_col)
        
%         axis equal;
        
 function []=plotedge(ybnds,xvecin)
%            minx=min([makerow(initxvls) makerow(xvls) makerow(enxvls)]);
%            maxx=max([makerow(initxvls) makerow(xvls) makerow(enxvls)]);
%            st_x=floor(minx);
%            max_x=ceil(maxx);
           
           for ii=1:length(xvecin)
               crx=xvecin(ii);
              xbnds(1)=crx-9/24;
              xbnds(2)=crx;
              xvec=[xbnds xbnds(end:-1:1)]
              yvec=[ybnds(1) ybnds(1) ybnds(2) ybnds(2)]
              fill(xvec,yvec,[0.7 0.7 0.7],'edgecolor','none');
              hold on;
               
               
           end       
                  
          