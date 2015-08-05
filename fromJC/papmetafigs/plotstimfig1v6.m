
%plotstimfig1.

function [combvls,shiftplot,sumdata,sumdataout,sumdataex]=plotstimfig1v6(sumbs)
GROUPHST=0;
BARPLOT=1;


% figstoplot=[1 2 3 4 5 7]
%  figstoplot=[1 2 3  5 6 7]
% figstoplot=[1 3 5 6 7 ]
% figstoplot=[1 3 5 6 7 8]
figstoplot=[ 6 7 9]
% figstoplot=[ 9];
% % figstoplot=;
%settings for first figure (time course)


  avlspath='/oriole/bk48w74/datasum'
  avlsmat='datsum.mat'
    
  cmd=['cd ' avlspath];
  eval(cmd);
  cmd=['load ' avlsmat];
  eval(cmd);

ps(1).bsnum=[2 1]
ps(1).runstoplot{1}=[1 4 9 10 11 12 13 14 15 16 17]
ps(1).runstoplot{2}=[2 3 4 5 6 7 13  14 15 16 17]

ps(2).bsnum=[2 ]
ps(2).runstoplot{1}=[4 13]
% ps(2).runstoplot{2}=[3 14]
ps(2).totalplot=2;
ps(2).shiftdrxn=[1 0]
ps(2).arrowht=[0.4 0.45]
ps(2).distht=0.35
ps(2).shiftnum=1;


if(ismember(1,figstoplot))
  
    
    exsong(1).path=[avls.baspath avls.pvls{2}]
    exsong(1).cvl=avls.cvl{2}
    exsong(1).fn='bk48w74_210809_105358.168.cbin';
    exsong(1).bnds=[4 6.7]
    exsong(1).stim_path='/oriole/bk48w74/stimexample2'
    exsong(1).stim_mat='stimexample.mat'
    exsong(1).ax1=subplot(5,3,1)
    exsong(1).ax2=subplot(5,3,[4]);
    
    
%     exsong(1).fvst=fvstex{1};

    exsong(2).avlspath='oriole/bk48w74/datasum'
    exsong(2).avlsmat='datsum.mat'
    exsong(2).path=[avls.baspath avls.pvls{2}]
    exsong(2).cvl=avls.cvl{4}
    exsong(2).fn=exsong(1).fn;
    exsong(2).bnds=[4 6.7]
    exsong(2).ax1=subplot(5,3,2)
    exsong(2).ax2=subplot(5,3,5)
%     exsong(2).fvst=fvstex{2}

    [axspects1,axspects2]=plotexspect(exsong);
end

if(ismember(2,figstoplot))
    ptsps.marksize=2
    ptsps.rawvl='raw'
    ptsps.plot_triangles=1;
    ptsps.triangle_xvl=0.95
    ptsps.ntvl=1;
    indtoplot=[2 4 75]
    ptsps.col{1}='k';
    ptsps.col{2}='r'
    prepost_indplot=[89 88 92]
    ptsps.STIM=1
    ptsps.plotextra=0
    sfact=3000;
   
    for ii=1:length(indtoplot)
        ptsps.indtoplot=indtoplot(ii);
        ptsps.prepost_indplot=prepost_indplot(ii);
        axraw(ii)=subplot(5,3,ii+6)
        ptsps.ax=gca();
        sumdataex(ii)=inactiv_rawpoints(avls,ptsps,sfact);
%         axis square
        box off
    end
    linkaxes(axraw)
    axis([-.6 1 2.18 2.64])
    
end

if(ismember(3,figstoplot))
    clear ps
    indtoplot=[2 4 75]
    ps.basind=1;
    ps.TIMEBNDS=[.066 .11]
    for ii=1:length(indtoplot)
        ps.indtoplot=indtoplot(ii);
        axcon(ii)=subplot(5,3,(ii+12));
        ps.ax=gca();
        ps.boxbnds=[.074 .090]
        [contours,crctind,crfbind,fvst,pitchtms]=loadcontours(avls,ps.indtoplot)
          ps.fvst=fvst;
          ps.PLOTSTIMBOUNDS=1;
          ps.plotstimln=.06;
          ps.plot_triangles=1;
        plotcontour(avls,ps)
        axis square
        box off
    end
    linkaxes(axcon,'x')
    axes(axcon(1))
    axis([.06 .12 2.25 2.6])
    axes(axcon(2))
    axis([.06 .12 2.25 2.6])
    axes(axcon(3))
    axis([.06 .12 2.25 2.6])
    
end

if(ismember(4,figstoplot))
    clear ps
    indlist{1}=[2 3 4 5 ]
    indlist{2}=[67 68 70 75 ]
    bsvl=1
    for ii=1:length(indlist)
         subplot(3,4,(ii-1)*4+4)
         ps.ax=gca();
        plotextmcourse(sumbs(1),indlist{ii},ps)
    end
end

if (ismember(5,figstoplot))
     clear ps
     indtoplot=[2 4 75]
     bsnum=1;
     ps.arrowht=[0.4 0.45]
    ps.distht=0.35
     ps.col{1}='k'
     ps.col{2}=['r']
     ps.col{3}=[0.6 0.6 0.6]
     
       ps.col{3}=[0.6 0.6 0.6]
       ps.plot_triangles=1;
       
       ps.shift_col=[0.6 0.6 0.6]
       ps.rev_col=[1 .6 .6]

     for ii=1:length(indtoplot)
         ps.indtoplot=indtoplot(ii);
         ps.initmean=sumbs(bsnum).initmean
         ps.REMOVEOUTLIERS=1;
         ps.PLOTSTIMBOUNDS=0;
           subplot(5,3,[ii+9])
           axhist(ii)=gca();
           ps.ax=gca();
           ps.ntind=1;
           ps.STIM=1;
           ps.shift_col='k'
           ps.rev_col='r';
          [contours,crctind,crfbind,fvst,pitchtms]=loadcontours(avls,ps.indtoplot) 
        
       plotexhistinactiv2(avls,ps )
    
     end
     
     linkaxes(axhist);
     axis([2.15 2.65 0 0.5])
%      axis square;
end



if (ismember(6,figstoplot))
    figure
    subplot(5,3,[3 6]);
    clear ps
    ps.axscatter=gca();
    ps.axin=gca();
    ps.axbnds=[0 10 0 10]
%     colin{1}{1}=[0.1 0.1 0.1]
%     colin{1}{2}=[0.5 0.5 0.5]
%     
%     colin{2}{1}=[1 0 0]
%     colin{2}{2}=[1 .6 .6]
%     colin{3}=[.6 .6 1]
    ps.MX_TM=4;
    ps.colin=0;
    ps.PLOTSCATTER=1;
    ps.USEPRE=0;
    ps.minpts=0;
    ps.mishift=0;
    ps.norm_asymp=0;
    ps.STIM=1;
   
    ps.NTANAL=1
    if(BARPLOT) 
        ps.calcz=1;
        
    [shiftplot,combvls]=plothistoryscatter4(sumbs,ps) 
    sumdata.MX_TM=ps.MX_TM;
     figure
         ps.axsum=subplot(4,5,1:3)
        ps.axpct=subplot(4,5,4:5)
        ps.TYPE='plotsum'
        ps.STIM=1;
         ps.runtypetoplot=1:3
         ps.combduplicates=1;
         ps.marksize=5;
         ps.splitupdown=1;
        [sumdataout]=plotgroupbar3(combvls,ps);
     ps.calcz=0;
        
    [shiftplot,combvls]=plothistoryscatter4(sumbs,ps) 
    sumdata.MX_TM=ps.MX_TM;
    
         ps.axsum=subplot(4,5,6:8)
        ps.axpct=subplot(4,5,9:10)
        ps.TYPE='plotsum'
        ps.STIM=1;
         ps.runtypetoplot=1:3
         ps.combduplicates=1;
         ps.marksize=5;
         ps.splitupdown=1;
        [sumdataout]=plotgroupbar3(combvls,ps);
    
    
    
   
%     axis square;   

    
       
         ps.axsum=subplot(4,5,11:13)
        ps.axpct=subplot(4,5,14:15)
        ps.TYPE='plotsum'
        ps.STIM=1;
         ps.runtypetoplot=1:3
         ps.combduplicates=0;
         ps.marksize=5;
         ps.splitupdown=1;
        [sumdataout]=plotgroupbar3(combvls,ps);
        
        
       ps.axsum=subplot(4,5,16:18)
        ps.axpct=subplot(4,5,19:20)
        ps.TYPE='plotsum'
        ps.STIM=1;
         ps.runtypetoplot=1:3
         ps.combduplicates=1;
         ps.marksize=5;
         ps.splitupdown=0;
        [sumdataout]=plotgroupbar3(combvls,ps);
        
        
    end
   
      
end

if (ismember(8,figstoplot))
     
    bsgrp{1}=[1]
    bsgrp{2}=[2]
    bsgrp{3}=[3 4]
    bsgrp{4}=[5]
     
      [shiftplot,sumdata]=calcavgbaseffects(combvls,shiftplot,bsgrp);
      box off;
    
end


    %plot baseline cv reduction
    %for targeted notes and control notes.
    
    %NEED TO SEPARATE OUT LIDOCAINE/MUSCIMOL RUNS FROM THIS.
    if(ismember(9,figstoplot))
    colvec={'k' 'r' 'c' 'b'}
    sfact=[3000 3000 3000 3000 2000]
    bslookupvl=[ 1 2 3 3 4];    
    
    figure
    meancombcv.ac=[];
    meancombcv.mu=[];
    allcombcv.mu=[];
    allcombcv.ac=[];
    
    runctr=1;
    for birdind=1:length(sumbs);
%         clear accv_vls lidflag mucv_vls acmn_vls mumn_vls birdvl
        crbs=sumbs(birdind);
        ntind=1;
        crbaslist=crbs.basruns;
        
        
        %find matching acsf runs for each of these basruns
      
            for ii=1:length(crbaslist)
                cr_run=crbaslist(ii);
               
                accv_vls(runctr)=crbs.ac_cv(cr_run);
                mucv_vls(runctr)=crbs.mu_cv(cr_run);
                acmn_vls(runctr)=crbs.acmean(cr_run)./sfact(birdind);
                mumn_vls(runctr)=crbs.mumean(cr_run)./sfact(birdind);
                birdvl(runctr)=bslookupvl(birdind);
                runctr=runctr+1;
            end
    end
    
    for ii=1:length(colvec)
        
        crind=find(birdvl==ii);
       
        comb.mumean(ii)=nanmean(mumn_vls(crind));
        comb.acmean(ii)=nanmean(acmn_vls(crind));
        comb.muster(ii)=nanstd(mumn_vls(crind))./sqrt(length(find(~isnan(mumn_vls(crind)))));
        comb.acster(ii)=nanstd(acmn_vls(crind))./sqrt(length(find(~isnan(acmn_vls(crind)))));
        
         combcv.mumean(ii)=nanmean(mucv_vls(crind));
        combcv.acmean(ii)=nanmean(accv_vls(crind));
        combcv.muster(ii)=nanstd(mucv_vls(crind))./sqrt(length(find(~isnan(mucv_vls(crind)))));
        combcv.acster(ii)=nanstd(accv_vls(crind))./sqrt(length(find(~isnan(accv_vls(crind)))));
    
        sumdata.comb=comb
        sumdata.combcv=combcv;
        sumdata.mumn_vls=mumn_vls;
        sumdata.acmn_vls=acmn_vls;
        sumdata.accv_vls=accv_vls;
        sumdata.mucv_vls=mucv_vls;
        
        
        subplot(211)
         plot(mumn_vls(crind), acmn_vls(crind),'o','Color',colvec{ii},'MarkerSize',5,'MarkerFaceColor',colvec{ii});
        hold on;
         box off;
%         axis([0 0.05 0 0.05]);
        hold on;
        acvls=[comb.acmean(ii)+comb.acster(ii) comb.acmean(ii)-comb.acster(ii)];
        muvls=[comb.mumean(ii)+comb.muster(ii) comb.mumean(ii)-comb.muster(ii)];
        
        plot(muvls,[comb.acmean(ii) comb.acmean(ii)],colvec{ii})
        plot([comb.mumean(ii) comb.mumean(ii)],acvls,colvec{ii});
        
        plot([2.25 2.6],[2.25 2.6],'k--');
        axis([2.25 2.6 2.25 2.6])
        axis square;
    
        subplot(212)
          plot(mucv_vls(crind), accv_vls(crind),'o','Color',colvec{ii},'MarkerSize',5,'MarkerFaceColor',colvec{ii});
        hold on;
         box off;
%         axis([0 0.05 0 0.05]);
        hold on;
        acvls=[combcv.acmean(ii)+combcv.acster(ii) combcv.acmean(ii)-combcv.acster(ii)];
        muvls=[combcv.mumean(ii)+combcv.muster(ii) combcv.mumean(ii)-combcv.muster(ii)];
        
        plot(muvls,[combcv.acmean(ii) combcv.acmean(ii)],colvec{ii})
        plot([combcv.mumean(ii) combcv.mumean(ii)],acvls,colvec{ii});
        
        plot([0 0.05],[0 0.05],'k--');
        axis([0 0.03 0 0.03])
        axis square;
    end


    end
   


function [contours,crctind,crfbind,fvst,pitchtms]=loadcontours(avls,crind)
    if(isfield(avls,'baspath'))
        path=[avls.baspath avls.pvls{crind}]
    else
        path=[avls.pvls{crind}];
    end
    cmd=['cd ' path];
    eval(cmd);
    bt=avls.cvl{crind}
    cmd=['load ' bt '.mat']
    eval(cmd);


     
     
   


function []=plotextmcourse(sumbs,indlist,ps)
    
%      figure
   
        
        ps.STIM=1;
        ps.plotarrow=1;
%         axtmcourse(ii)=subplot(1,bsln,ii);
        plot_tmcourse2rev(sumbs,indlist,ps);
   








%TAKEN FROM PLOTHISTORYFIGSSCRIPT2, REWRITTEN IN GENERAL FORM
function []=plotexhist(avls,ps)
    if(isfield(ps,'REMOVEOUTLIERS'))
        if(ps.REMOVEOUTLIERS)
            REM_OUTLIERS=1;
        else
            REM_OUTLIERS=0;
        end
    else
        REM_OUTLIERS=0;
    end
    
   
    
    dht=ps.distht;
    arht=ps.arrowht;
    
        for indnum=1:length(ps.indtoplot)
            crind=ps.indtoplot(indnum);
            axes(ps.ax);
            crct=avls.hsctnrm{crind};
            crfb=avls.hsfbnrm{crind};
            crctmn=avls.ctmean(crind)
            crfbmn=avls.fbmean(crind);
            stdct=avls.stdct(crind);
            stdfb=avls.stdfb(crind);
            crctind=avls.crctind{crind};
            crfbind=avls.crfbind{crind};
             if(REM_OUTLIERS)
                crfbmn=avls.fbmeanlim(crind);
                stdfb=avls.stdfblim(crind);
                crfbind=avls.crfbindlim{crind};
           
             end
            
            
            crctste=stdct./sqrt(length(crctind));
            crfbste=stdfb./sqrt(length(crfbind));
            %plot catch value
            
            stairs(avls.HST_EDGES/3000,crct,'k','Linewidth',2)
            hold on;
       
            %    plot([mnbas+stdbas mnbas+stdbas], [0 1], 'c--')
            %    plot([mnbas-stdbas mnbas-stdbas], [0 1], 'c--')
            plot([ps.initmean/3000 ps.initmean/3000],[0 1],'k--','Linewidth',2)
            
            text(2.225,0.5,['catch=' num2str(length(crctind))],'Color','k');
            plot([(crctmn-crctste)/3000 (crctmn+crctste)/3000],[dht dht],'k','Linewidth',3)
   
             %this is for the stim trial
            if(~isempty(crfbind))
        
                plot([(crfbmn-crfbste)/3000 (crfbmn+crfbste)/3000],[dht dht],'r','Linewidth',3)
                text(2.225,0.2,['fb=' num2str(length(crfbind))],'Color','r');
                stairs(avls.HST_EDGES/3000,crfb,'r','Linewidth',2)
            box off;
            end
%             if(PLOTSTIMBOUNDS)
%                 
%                 
%             end
  
       origarrow=[ps.initmean/3000 arht(1) crctmn/3000  arht(1)]
       shiftarrow=[crctmn/3000 arht(2) crfbmn/3000  arht(2)]
        ps.plotshiftarrow=1;
        ps.plotrevarrow=1;
   plotarrows(origarrow,shiftarrow,ps);
   
   
        end
 
    function [mnstim,stdstim]=calcstim_meanstd(fvst,crfbind)
        combfvst=[];
        for ii=1:length(fvst)
           combfvst=[combfvst fvst(ii).STIMTIME];
           
           
            
        end
        mnstim=mean(combfvst(crfbind));
        stdstim=std(combfvst(crfbind));
        
function [ax1,ax2]=plotexspect(exsong)
clear catchvl
clear ax

figure;

ax1(1)=exsong(1).ax1

ax1(2)=exsong(1).ax2;


ax2(1)=exsong(2).ax1;
ax2(2)=exsong(2).ax2;

for ii=1:2
    exsong(ii).ax=exsong(ii).ax2;
    ps.tst=1
    [dat,fs]=plotcbin(exsong(ii),ps);
    hold on;
    plot([0 2.5],[6600 6600],'c--')
end
% 
%     tms=0:1/fs:length(dat(:,2))/fs
%     tms2=tms(1:end-1);
%     ax2(2)=subplot(6,1,1)
%     plot(tms2,dat(:,2),'k','Lininactivtw5ewidth',2)

%plot stim component
for plotnum=1:2
    if plotnum==1
        axes(ax1(1));
    else
        axes(ax2(1));
    end
    %this is for first one. 
    cmd=['cd ' exsong(1).path]
    eval(cmd);
    cmd=['load ' exsong(1).cvl '.mat']
    eval(cmd);
    cmd=['cd ' exsong(1).stim_path]
    eval(cmd);
    cmd=['load ' exsong(1).stim_mat]
    eval(cmd);
    onstime(1)=fvst(2).ons(fvst(2).ind)
    onstime(2)=fvst(3).ons(fvst(3).ind)
    onstime(3)=fvst(4).ons(fvst(4).ind)
    % onstime(3)=fvst(9).ons(fvst(9).ind)
    stimofftime(1)=fvst(2).STIMTIME;
    catchvl(1)=fvst(2).STIMCATCH
    stimofftime(2)=fvst(3).STIMTIME;
    catchvl(2)=fvst(3).STIMCATCH
    stimofftime(3)=fvst(4).STIMTIME;
    catchvl(3)=fvst(3).STIMCATCH;
    hold on;
    if(plotnum==2)
        axes(ax2(2));
        %hacked to be up until .012 seconds.
        xvls=makerow((pitchtms(160:592)+onstime(2)/1000-exsong(1).bnds(1)));
        tst=contours(:,3);
        tst1=tst(160:592);
        
        plot(xvls,tst1,'Linewidth',3,'Color','c');
        axes(ax2(1));
    end
        dtime(1)=onstime(1)/1000+stimofftime(1)/1000-exsong(1).bnds(1);
    dtime(2)=onstime(2)/1000+stimofftime(2)/1000-exsong(1).bnds(1);
    dtime(3)=onstime(3)/1000+stimofftime(3)/1000-exsong(1).bnds(1);

    hold on;
    for ii=1:3
        plot(dtime(ii),1000,'rv','MarkerFaceColor','r')
    end

    for ii=1:3
        if catchvl(ii)<1
        plot(dtime(ii)+.065+stimtms,dat_stimnew,'k','Linewidth',2)
        end
    end
end
axes(ax1(1))
linkaxes(ax1,'x')
axis([0 2.63 0 2e4])

axes(ax2(1))
linkaxes(ax2,'x')
axis([1.3 1.5 0 2e4])

st_tm=onstime(2)/1000+.077-.016-exsong(1).bnds(1);
end_tm=st_tm+512/32000;
axes(ax1(2))
plotbox([1.35 1.48 2200 2700],'c')

axes(ax2(2))
axis([1.35 1.48 2200 2700])


%this is for second one.
% axes(ax2(2));
% fvst=fvstex{2}
% %these happen to be 19 and 20.
% onstime(1)=fvst(40).ons(fvst(40).ind)
% onstime(2)=fvst(41).ons(fvst(41).ind)
% onstime(3)=fvst(42).ons(fvst(42).ind)
% % onstime(3)=fvst(9).ons(fvst(9).ind)
% stimofftime(1)=fvst(40).STIMTIME;
% catchvl(1)=fvst(40).STIMCATCH
% stimofftime(2)=fvst(41).STIMTIME;
% catchvl(2)=fvst(41).STIMCATCH;
% stimofftime(3)=fvst(42).STIMTIME;
% catchvl(3)=fvst(42).STIMCATCH
% dtime(1)=onstime(1)/1000+stimofftime(1)/1000-exsong(2).bnds(1);
% dtime(2)=onstime(2)/1000+stimofftime(2)/1000-exsong(2).bnds(1);
% dtime(3)=onstime(3)/1000+stimofftime(3)/1000-exsong(2).bnds(1);
% 
% hold on;
% for ii=1:3
%     plot([dtime(ii) dtime(ii)],[0 20000],'r','Linewidth',2)
% end
% 
% for ii=1:3
%     if catchvl(ii)<1
%     plot((dtime(ii)+.065+stimtms),stimblock,'k','Linewidth',2)
%     end
% end


title('plotstimexample.m')


function [axgrphst]=plotgrouphsts(combvls,ps)
%     colvec={'r' 'c' 'k' 'm'}
%     
    axgrphst=ps.ax;
    edges=ps.edges;
    col=ps.col;
    jjpair{1}=[1 2]
    jjpair{2}=[1 2]
    
    for ii=1:length(combvls)
        for jj=1:length(combvls{ii})
%             if(jj==2)
%                 combvls{ii}{jj}=-combvls{ii}{jj}
%             end
            hstvls=combvls{ii}{jj}.offz;
            hst_tmp=histc(hstvls,edges)
            mnout{ii}{jj}=nanmean(hstvls)
            ster{ii}{jj}=nanstd(hstvls)./sqrt(length(hstvls));
            hstout{ii}{jj}=hst_tmp./sum(hst_tmp);
            ct{ii}{jj}=sum(hst_tmp);
        end
    end
    
    for figcnt=1:2
        axes(axgrphst(figcnt))
        crvls=jjpair{figcnt}
        colcnt=figcnt
        stairs(edges,hstout{figcnt}{crvls(1)},'Color',col{figcnt}{crvls(1)},'Linewidth',3)
        axis(ps.axbnds);
        hold on;
%         if(figcnt==1)
            stairs(edges,hstout{figcnt}{crvls(2)},'Color',col{figcnt}{crvls(2)},'Linewidth',3)
%         end
            axis([-4 4 0 0.5])
    
        
        text(3, 0.35, ['n = ' num2str(ct{figcnt}{crvls(1)})],'Color',col{figcnt}{crvls(1)},'Fontsize',16)  
        for hstcount=1:2
            for ii=1:2
        crmn=mnout{figcnt}{crvls(hstcount)};
        crster=ster{figcnt}{crvls(hstcount)};
%         crmn=mnout{figcnt}{crvls(1)};
%         crster=ster{figcnt}{crvls(1)};
        plot([crmn-crster crmn+crster],[0.6 0.6],'Color',col{ii}{crvls(hstcount)},'Linewidth',3);
        plot(crmn,0.7,'v', 'Color',col{ii}{crvls(hstcount)},'MarkerFaceColor',col{ii}{crvls(hstcount)});
            end
            end
%         h1=arrow([0 0.35],[crmn 0.35],'Length',3,'Width',0.5)
%         set(h1,'FaceColor',col{figcnt}{crvls(1)})
%         set(h1,'EdgeColor','none')
    end    
        
        
%         plot([0 crmn],[0.35 0.35],'Color',col.basrev,'Linewidth',3);
        plot([crmn-crster crmn+crster],[0.3 0.3],'Color',col{figcnt}{crvls(2)},'Linewidth',3);
        if(figcnt==1)
        crmn=mnout{crvls(2)};
        crster=ster{crvls(2)};
%          h1=arrow([0 0.35],[crmn 0.35],'Length',3,'Width',0.5)
%         set(h1,'FaceColor',col{figcnt}{crvls(2)})
%         set(h1,'EdgeColor','none')
%         
%         arrowh([0 crmn],[0.35 0.35],col.asyrev,[200 200]);
%         plot([0 crmn],[0.35 0.35],'Color',col.asyrev,'Linewidth',3);
%         plot([crmn-crster crmn+crster],[0.3 0.3],'Color',col{figcnt}{crvls(2)},'Linewidth',3);
        
        text(3, 0.3, ['n = ' num2str(ct{crvls(2)})],'Color',col{figcnt}{crvls(2)},'Fontsize',16)  
        end
       
























































































































