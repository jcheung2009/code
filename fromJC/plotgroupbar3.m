%written 4.1.10 to plot group data histograms
%input combvls takes the following form.
%combvls{1} - baseline runs
%combvls{2} - shift runs

% combvls{X}{1}-upshift
% combvls{X}{2}-downshift

%combvls{X}{X}{1}-shift
%combvls{X}{X}{2}-control.

%try to write compatible with stim and shift

%rewritten to output mean value if multiple shifts.

function [plotvls,offzout]=plotgroupbar3(combvls,ps)   
    
%     ax=ps.ax;
    ps.col={'k' 'r' 'k'}
    xvls=[1 3 5]
    if(ps.TYPE=='plotall')
        [sumdata,sumdatarev]=plotall(combvls,xvls,ps);
    elseif(ps.TYPE=='plotsum')
        axes(ps.axsum)
        [plotvls,offzout]=plotsum(combvls,xvls,ps);
        axes(ps.axpct)
%         plotpct(sumdatash(1));
    end
    
    function [plotvls,offzout]=plotsum(combvls,xvls,ps)
       %ps.runtypetoplot
       %1 is baseline runs, 
       %2 is shiftruns
       %3 is shiftruns rev
       
       for runtypeind=1:length(ps.runtypetoplot)
           crtype=ps.runtypetoplot(runtypeind);
           
               for ntvl=1:length(combvls{crtype}{1})
                   crvlsup=combvls{crtype}{1}{ntvl};
                   crvlsdn=combvls{crtype}{2}{ntvl};
                   crxvl=xvls(runtypeind)
                   if(~ps.STIM)
                       crvlsup.acanal=crvlsup.acpreshift;
                       crvlsdn.acanal=crvlsdn.acpreshift;
                   else
                       crvlsup.acanal=crvlsup.acshift;
                       crvlsdn.acanal=crvlsdn.acshift;
                   end
                   
                   if(~isempty(crxvl))
                       %determine net difference in crvls between ac and mu
                      
                           analvls.ac=[crvlsup.acanal crvlsdn.acanal];
                           analvls.mu=[crvlsup.mushift crvlsdn.mushift];
                           analvls.bsnm=[crvlsup.bsnm crvlsdn.bsnm]
                           analvls.shnm=[crvlsup.shnum crvlsdn.shnum]
                           analvls.pct=[crvlsup.pct crvlsdn.pct]
                           lnup=length(crvlsup.acanal);
                           lndn=length(crvlsdn.acanal);
                           for ii=1:lnup
                           analvls.drxnind(ii)=1;
                           end
                           for ii=lnup+1:lnup+lndn
                            analvls.drxnind(ii)=2;
                           end
                           if(isfield(crvlsup,'lidflag'))
                               analvls.lidind=find(crvlsup.lidflag==1)
                               analvls.lidind=[analvls.lidind lnup+find(crvlsdn.lidflag==1)];
                           else
                                analvls.lidind=[];
                           end
                       
                           
                                [duplicate_inds]=find_duplicates(analvls);
                           
                                 [plotvls{crtype}{ntvl},ps.lidindout]=average_duplicates(analvls,duplicate_inds,ps);
                   end
               end
       end
                    %THEN MAKE PLOT OF THIS PARTICULAR VALUE, WRITE VALUE
                    %OUT TO OUTVALUE   
                   %start with plotting in zscore units.  %then I can
                   %switch to other values.
        
                   %get notNAN bs/sh combinations.
                   
                   [indlist]=find(~isnan(plotvls{3}{1}.ac));
                   bslist=plotvls{3}{1}.bs(indlist);
                   shlist=plotvls{3}{1}.sh(indlist);
                   
                        ps.plotdiff=0;
                        [ps.offz ps.acz ps.muz]=plotrawpts(xvls,plotvls,ps,bslist,shlist);
                   offzout=ps.offz;
                    [mnvls,stervls]=plotsumbar(xvls,plotvls,ps);
                    
                    
%                         [sumdatash(ntvl)]=calcstats(analvls,plotvls{2},ps);
%                     
%                         [sumdatarev(ntvl)]=calcstats(analvls,plotvls{3},ps);
%                   
%                         [sumdatabas(ntvl)]=calcstats(analvls,plotvls{,ps);
%                       
               sumdatash=[];
               sumdatarev=[];
               sumdatabas=[];
                  
        function []=plotpct(sumdatash)
            crxvl=1;  
            for ii=1:2
                     if(ii==2)
                        plotxvl=crxvl
                        yvl=sumdatash.pctvlsup
                        
                     else
                        plotxvl=crxvl+1;
                        yvl=sumdatash.pctvlsdn;
                     end
                     
                     lnvls=length(find(~isnan(yvl)));
                     xvl=plotxvl*ones(lnvls,1);   
                        mnvls=nanmean(yvl)
                        stervls=nanstd(yvl)./sqrt(lnvls);
                        bar(plotxvl,mnvls,0.6,'FaceColor','none');
                        hold on;
                        plot([plotxvl plotxvl],[mnvls-stervls mnvls+stervls],'k')
                        plot(xvl,yvl,'k.','MarkerSize',1);
                        text(plotxvl,mnvls*1.5,['n=' num2str(lnvls)]);
                    end
        function [sumdata]=calcstats(analvls,plotvls,ps)
             offz=plotvls.ac-plotvls.mu
            inddn=find(plotvls.drxn==2)
            indup=find(plotvls.drxn==1);  
            if(~ps.splitupdown)
            offz(indup)=-offz(indup);
            end
            sumdata.offzall=offz;
            sumdata.offzup=offz(indup);
            sumdata.pctvlsall=plotvls.pct;
            sumdata.bs=plotvls.bs;
            sumdata.sh=plotvls.sh;
            sumdata.pctvlsup=plotvls.pct(indup);
            sumdata.pctvlsdn=plotvls.pct(inddn);

        %ps.offz has the reduced offset values
            function [mnvls,stervls]=plotsumbar(xvls,plotvls,ps)
       %calc sum stats
        for runvl=1:3
            offz=ps.offz{runvl}
            acz=ps.acz{runvl};
            muz=ps.muz{runvl};
            if(~ps.splitupdown)
                crxvl=xvls(runvl)
                lnvls=length(find(~isnan(offz)));
                mnvls=nanmean(offz)
                mnacvls=nanmean(acz);
                mnmuvls=nanmean(muz);
                 stervls=nanstd(offz)./sqrt(lnvls);
                 steracvls=nanstd(acz)./sqrt(lnvls);
                 stermuvls=nanstd(muz)./sqrt(lnvls);
                 if(ps.plotdiff)
                 bar(crxvl,mnvls,0.6,'FaceColor','none');
                 plot([crxvl crxvl],[mnvls-stervls mnvls+stervls],'k')
                 else
                 bar(crxvl,mnacvls,0.6,'FaceColor','none');
                 bar(crxvl+1,mnmuvls,0.6,'FaceColor','none');
                 plot([crxvl crxvl],[mnacvls-steracvls mnacvls+steracvls],'k')
                  plot([crxvl+1 crxvl+1],[mnmuvls-stermuvls mnmuvls+stermuvls],'k')   
                 end
                 
                 text(crxvl,mnvls*1.5,['n=' num2str(lnvls)]);
            else
               
                for runvl=1:2
                    for ntvl=length(plotvls{runvl})
                    crxvl=xvls(runvl) 
                    if(ii==2)
                        plotxvl=crxvl
                     else
                        plotxvl=crxvl+1;
                     end
                      crind=find(plotvls{runvl}.drxn==ii)  
                     lnvls=length(find(~isnan(ps.offz{runvl}(crind))));
                        
                        
                        if (ps.plotdiff)
                        mnvls=nanmean(ps.offz(crind))
                        stervls=nanstd(ps.offz(crind))./sqrt(lnvls);
                        bar(plotxvl,mnvls,0.6,'FaceColor','none');
                        plot([plotxvl plotxvl],[mnvls-stervls mnvls+stervls],'k')
                        text(plotxvl,mnvls*1.5,['n=' num2str(lnvls)]);
                        else
                         mnacvls=nanmean(ps.acz(crind))  
                            
                        end
                        end
                end
            end
       
        end
        
                   
        function  [offzout,aczout,muzout]=plotrawpts(crxvl,inplotvls,ps,bslist,shlist)
            %since this is sumplot...
            %plot all points, but plot different directions in different
            %color.
          for ii=1:length(inplotvls)
              crx=crxvl(ii)
              plotvls=inplotvls{ii}{1}
            if(~ps.splitupdown)
                crxvlup=crxvl
                
            else
                crxvlup=crxvl+1;
            end
            %get matching ind
            matchind=[];
            for bsvl=1:length(bslist)
                crbs=bslist(bsvl)
                crsh=shlist(bsvl);
                outind=find(plotvls.bs==crbs&plotvls.sh==crsh);    
                if(~isempty(outind))
                    matchind=[matchind outind]
                end
            end
            
            offz=plotvls.mu(matchind)-plotvls.ac(matchind)
            muz=plotvls.mu(matchind);
            acz=plotvls.ac(matchind);
            inddn=find(plotvls.drxn(matchind)==2)
            indup=find(plotvls.drxn(matchind)==1);  
            if(~ps.splitupdown)
            offz(inddn)=-offz(inddn);
            muz(inddn)=-muz(inddn);
            acz(inddn)=-acz(inddn);
            end
            crxdn=crx*ones(1,length(inddn));
            
                crxup=crx*ones(1,length(indup));
           if(ps.plotdiff)
                plot(crxdn-.2,offz(inddn),'o','Color','k','MarkerSize',3*ps.marksize);
%                 crlidind=find((ismember(indup,ps.lidindout)))
%                 plot(crxup(crlidind),offz(indup(crlidind)),'.','Color','c','MarkerSize',ps.marksize);
                
                hold on;
                plot(crxup-.2,offz(indup),'o','Color','k','MarkerSize',3*ps.marksize);
%                 crlidind=find((ismember(inddn,ps.lidindout)))
%                 plot(crxdn(crlidind),offz(inddn(crlidind)),'.','Color','c','MarkerSize',ps.marksize);
           else
               plot(crxdn-.2,acz(inddn),'o','Color','k','MarkerSize',3*ps.marksize);
               hold on;
               plot(crxdn-.2+1,muz(inddn),'o','Color','r','MarkerSize',3*ps.marksize);
               plot(crxup-.2,acz(indup),'o','Color','k','MarkerSize',3*ps.marksize);
               plot(crxup-.2+1,muz(indup),'o','Color','r','MarkerSize',3*ps.marksize);
               
           end
            offzout{ii}=offz;  
            muzout{ii}=muz;
            aczout{ii}=acz
          end
        
    function [sumdata,sumdatarev]=plotall(combvls,xvls,ps) 

    for typevl=1:length(combvls)
        for drxnvl=1:length(combvls{typevl})
%             for ntvl=1:length(combvls{typevl}{drxnvl})
              for ntvl=1
                crvls=combvls{typevl}{drxnvl}{ntvl}
                crxvl=xvls{typevl}{drxnvl}{ntvl}
                
                if(~isempty(crxvl))
                
                
                axes(ax)
                for ii=1:length(crxvl)
                    if(ii==1)
                        if(~ps.STIM)
                            axvls{1}=crvls.acpreshift;
                     
                             lidind=find(crvls.lidflag==1)
                        else
                            axvls{1}=crvls.acshift;
                            lidind=[];
                        end
                    elseif(ii==2)
                        axvls{2}=crvls.mushift;
                    else
                        axvls{3}=crvls.acpostshift;
                    end


                    [duplicate_inds]=find_duplicates(crvls);
                    [plotvls{ii},lidindout,pctvls_ave]=average_duplicates(crvls,axvls{ii},duplicate_inds,lidind)
                    
                        crx{ii}=crxvl(ii)*ones(1,length(plotvls{ii}));
                    
                    plot(crx{ii},plotvls{ii},'o','Color',ps.col{ii},'MarkerSize',2);
                    hold on;
                    if(ii>1)
                        plot([crx{ii-1} ;crx{ii}],[plotvls{ii-1}; plotvls{ii}],'Linewidth',0.8,'Color','k');
                        
                        if(~isempty(lidindout))
                            plot([makerow(crx{ii-1}(lidindout)) ;makerow(crx{ii}(lidindout))],[plotvls{ii-1}(lidindout); plotvls{ii}(lidindout)],'Linewidth',0.8,'Color','c');
                        end
                        if (ii==2)
                            text(crx{1}(1)-1,1,['n=' num2str(length(find(~isnan(plotvls{ii}))))]);
                        end
                    end
              
                %calcmean and ster of each value for bar plots
                    
                            mnoutpre_all=nanmean(axvls{ii})
                            sterpre_all=nanstd(axvls{ii})./sqrt(length(axvls{ii}));
                            mnoutpre_ave=nanmean(plotvls{ii});
                            sterpre_ave=nanstd(plotvls{ii})./sqrt(length(axvls{ii}));
                            bar(crxvl(ii),mnoutpre_ave,0.6,'FaceColor','none');
                            plot([crxvl(ii) crxvl(ii)],[mnoutpre_ave-sterpre_ave mnoutpre_ave+sterpre_ave],'k')
                    %shift_target notes
                     if(typevl==2)
                        if(ntvl==1)
                            if(ii==2)
                            sumdata(drxnvl).mnoutpre_all=mnoutpre_all;
                            sumdata(drxnvl).sterpre_all=sterpre_all;
                            sumdata(drxnvl).mnoutpre_ave=mnoutpre_ave;
                            sumdata(drxnvl).sterpre_ave=sterpre_ave;
                            sumdata(drxnvl).pctall=crvls.pct
                            sumdata(drxnvl).pctave=pctvls_ave;
                            sumdata(drxnvl).aveplotvls=plotvls{ii};
                            sumdata(drxnvl).aven=length(find(~isnan(plotvls{ii})));
                            sumdata(drxnvl).alln=length(mnoutpre_all);
                            sumdata(drxnvl).lidvls=length(lidindout);
                            sumdata(drxnvl).pctlid=pctvls_ave(lidindout);
                            end
                            end
                     end
                    if(typevl==3)
                        if(ntvl==1)
                            if(ii==2)
                            sumdatarev(drxnvl).mnoutpre_all=mnoutpre_all;
                            sumdatarev(drxnvl).sterpre_all=sterpre_all;
                            sumdatarev(drxnvl).mnoutpre_ave=mnoutpre_ave;
                            sumdatarev(drxnvl).sterpre_ave=sterpre_ave;
                            sumdatarev(drxnvl).pctall=crvls.pct
                            sumdatarev(drxnvl).pctave=pctvls_ave;
                            sumdatarev(drxnvl).aveplotvls=plotvls{ii};
                            sumdatarev(drxnvl).aven=length(find(~isnan(plotvls{ii})));
                            sumdatarev(drxnvl).alln=length(mnoutpre_all);
                            sumdatarev(drxnvl).lidvls=length(lidindout);
                            sumdatarev(drxnvl).pctlid=pctvls_ave(lidindout);
                            end
                            end
                     end
                
                end
                
                
                
            end
        end
        end
    end







    function [xvls]=setxvls(ps)
    
    if(~ps.STIM)
        
        if(ps.TYPE=='plotsum')
    
    %baseline runs  target notes are going to 12 13 14
    xvls{1}{1}{1}=[1]
    xvls{1}{1}{2}=[3]
%     
    %shift runs, target notes
    xvls{2}{1}{1}=[5]
%     xvls{2}{2}{1}=[0 1 2]
    
    %shift runs, control notes
    xvls{2}{1}{2}=[7]
%     xvls{2}{2}{2}=[8 9 10]
    
    %baseline runs, control notes
%     xvls{1}{1}{2}=[]
%     xvls{1}{2}{2}=[]
    
    xvls{3}{1}{1}=[9]
    xvls{3}{1}{2}=[11]
    
%     xvls{3}{2}{1}=[24:26]
%     
%     xvls{3}{1}{2}=[];
%     xvls{3}{2}{2}=[];
    
    
    
    xvls{4}{1}{1}=[13]
    xvls{4}{1}{2}=[15]
    
%     xvls{4}{2}{1}=[32:34]
%     
%     xvls{4}{1}{2}=[];
%     xvls{4}{2}{2}=[];
    
        end
    else
    %shiftruns, targetnotes
    xvls{2}{1}{1}=[5]
    xvls{2}{1}{2}=[7]
    
    %baseline runs, target notes
    xvls{1}{1}{1}=[1]
    xvls{1}{1}{2}=[3]
    
    %shiftruns,rev
    xvls{3}{1}{1}=[9 ]
    xvls{3}{1}{2}=[11]
    
    
%      xvls{4}{1}{1}=[15 16]
%     xvls{4}{2}{1}=[18 19]
    
    
    end
    
    
    function[plotvls,lidindout]=average_duplicates(analvls,duplicate_inds,ps)
        %loop through each of the axvls values
        %confirm that value has not been included yet
        %check if ind is duplicate_ind
        %
        
        anal_completelist=[];
        pctvls_ave=[];
        lidindout=[];
        plotvls.ac=[];
        plotvls.mu=[];
        plotvls.pct=[];
        plotvls.drxn=[];
        plotvls.bs=[];
        plotvls.sh=[];
        crctr=0;
        for ii=1:length(analvls.ac)
           if ~ismember(ii,anal_completelist)
               duplicateflag=0;
               for jj=1:length(duplicate_inds)
                  crduplicates=duplicate_inds{jj}
                  if(ismember(ii,crduplicates))
                     if(ps.combduplicates)

                         plotvls.ac=[plotvls.ac nanmean(analvls.ac(crduplicates))];
                      plotvls.mu=[plotvls.mu nanmean(analvls.mu(crduplicates))];
                      plotvls.bs=[plotvls.bs analvls.bsnm(crduplicates(1))];
                      plotvls.sh=[plotvls.sh analvls.shnm(crduplicates(1))];
                      plotvls.pct=[plotvls.pct nanmean(analvls.pct(crduplicates))];
                      plotvls.drxn=[plotvls.drxn nanmean(analvls.drxnind(crduplicates))];
                      duplicateflag=1;
                      anal_completelist=[anal_completelist crduplicates];
                      crctr=crctr+1;
                      if(ismember(ii,analvls.lidind))
                          lidindout=[lidindout crctr];
                      end
                     end
                  end
               end
               if(duplicateflag==0)
                      plotvls.ac=[plotvls.ac analvls.ac(ii)];
                      plotvls.mu=[plotvls.mu analvls.mu(ii)];
                      plotvls.pct=[plotvls.pct analvls.pct(ii)];
                       plotvls.bs=[plotvls.bs analvls.bsnm(ii)];
                      plotvls.sh=[plotvls.sh analvls.shnm(ii)];
                      plotvls.drxn=[plotvls.drxn analvls.drxnind(ii)];
                      anal_completelist=[anal_completelist ii];
                      crctr=crctr+1;
                      if(ismember(ii,analvls.lidind))
                          lidindout=[lidindout crctr];
                      end
               end
           end
            
            
            
        end
    
    
    
    function [duplicate_inds]=find_duplicates(analvls)
        redinds=[];
        bsind=unique(analvls.bsnm);
        shind=unique(analvls.shnm);
        ct=1;
        for ii=1:length(bsind)
            crbs=bsind(ii);
            for jj=1:length(shind);
                crsh=shind(jj);
                bsinds=find(analvls.bsnm==crbs)
                shinds=find(analvls.shnm==crsh);
                inds=intersect(bsinds,shinds);
                
                if(~isempty(inds))
                    if(length(inds)>=2)
                        duplicate_inds{ct}=inds;
                        ct=ct+1;
                    end
                end
            
            end
        end
        if(~exist('duplicate_inds'))
            duplicate_inds=[];
        end
    
    
    %this function takes the maximum value if there are multiple runs on
    %the same shift.
    function [redinds]=reduce_vls(crvls)
        redinds=[];
        bsind=unique(crvls.bsnm);
        shind=unique(crvls.shnum);
        for ii=1:length(bsind)
            crbs=bsind(ii);
            for jj=1:length(shind);
                crsh=shind(jj);
                bsinds=find(crvls.bsnm==crbs)
                shinds=find(crvls.shnum==crsh);
                inds=intersect(bsinds,shinds);
                
                if(~isempty(inds))
                    redinds=[redinds max(inds)];
                end
            
            end
        end
        
