
%option 1.
%edited so that it plots wn, nighttime, raw points, and morning evening


function [phpre,stpre,plotvlsph,plotvlsst]=pk20r49recov(phsumbs,sumbs,bs,sts)
figure

% figstoplot=[1 2 3 4 5  ]
% figstoplot=[5 6 7 ];
% figstoplot=[1 2 7 12]
% figstoplot=[1 2 3 4 7 8 12 13 ]
% figstoplot=[1 2 3 4 7 8 12 13 ];
%EVERYTHING BUT REVERSE 
figstoplot=[3];
% figstoplot=1;
% figstoplot=[4]
% settings for first figure (time course)


%   avlspath='/oriole/bk48w74/datasum'
%   avlsmat='datsum.mat'
%     
%   cmd=['cd ' avlspath];
%   eval(cmd);
%   cmd=['load ' avlsmat];
%   eval(cmd);

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

crbs=5;
    
    cmd=['cd ' bs(crbs).path ];
    eval(cmd);
    cmd=['load ' bs(crbs).matfilename];
    eval(cmd);
clear ps;
%Example asymptote plot.
% figure
%   [sumdyn,sumdynasymp,sumdynrev]=selectdynamicruns3(sumbs,0,0,0,0)





if(ismember(2,figstoplot))
crax=subplot(3,2,3:4)
    ps.ax= crax
          ps.mulistind= [1 2 3 4 5 6 7 8 9 10 11]
               ps.STIM= 0
          ps.plotarrow= 0
            ps.plotave= 1
       ps.plotmumarker= 0
            ps.acindvl= [1 2 3 4 5 6 7 8 9 10 11]
            ps.muindvl= [1 2 3 4 5 6 7 8 9 10 11]
           ps.startind= 1
              ps.plotz= 0
               ps.flip= 0
               ps.startind=13;
               
               ps.endind=15;
               ps.FILL= 1
            ps.wnfloor= 0
         ps.plotwnline= 1
              ps.wncol= 'r'
            ps.plotsep= 1
    ps.plotinitendline= 0
         ps.plotmuline= 1
          ps.plotrawmu= 0
          ps.plotallac= 1
          ps.plotdiff=1;
          ps.netdiff=1;
          ps.plotallacpts=0;
          ps.plotrawac= 0
         ps.runstoplot= [1 2 3 4 5 6 7 8 9 10 11]
              ps.muind= [1 2 3 4 5 6 7]
         ps.plotacline= 1
    [os]=plot_tmcourse5MOD(phsumbs(11),ps,avls)
end











if (ismember(3,figstoplot))
    crbs=1;
    
    cmd=['cd ' bs(crbs).path ];
    eval(cmd);
    cmd=['load ' bs(crbs).matfilename];
    eval(cmd);
    
%     ps.STIM=0;
        ps.plotarrow=1;
%         ps.runstoplot=[5 7 8 9 10 11 12 13 14 15]
        ps.runstoplot=[1:19]
         ps.wncol=[.98 .8 .9]
%         crax=subplot(5,5,1:4)
        crax=subplot(3,3,1:3)        
        ps.ax=crax;
        ps.muht=2.6;
        ps.plotsep=1;
        ps.adjx=1;
        
        ps.acindvl=[1:19]
        ps.muindvl=[1:19]
        ps.FILL=0;
         ps.plotedgeybnds=[2 3]
         ps.startind=13;
         ps.endind=15;
        ps.plotedgexbnds=[0:19]
        ps.plotwn=1;
        ps.plotz=0
        ps.wnfloor=2.2
        ps.plotwnline=1;
        ps.plotmumarker=1;
        ps.divfac=2000;
        ps.plotmuline=0;
        ps.plotacline=0;
        ps.plotrawmu=1;
        ps.plotrawac=0;
        ps.plotallac=1;
        ps.plot_triangles=1;
        ps.plotallacpts=1;
        ps.plotinitendline=0;
        ps.ACINDTOPLOT=1;
        
        ps.flip=0;
        ps.netdiff=1;
      
        ps.mumarksize=2
        ps.plotacmarker=1;
        ps.STIM=0;
        ps.plotdiff=1;
%         axtmcourse(ii)=subplot(1,bsln,ii);
% %         plot_tmcourse5mod2(phsumbs(crbs),ps,avls);
% %         axis square
%         axis([ -2 14 3.3 4.2])
%         ps.plotedge=1;
%         ps.plotedgeybnds=[2 3]
%         ps.plotedgexbnds=[0:15]

%         axt(1)=subplot(3,3,4)
%         ps.runstoplot=[4]
%         ps.divfac=2000;
%         plotlimraw(avls,ps)
%         axt(1)=subplot(3,3,5)
%         ps.runstoplot=[7];
%         plotlimraw(avls,ps)
%         
%         
        ps.divfac=2;
         axt(1)=subplot(3,3,4)
        ps.runstoplot=[12];
        plotlimraw(avls,ps)
        axt(2)=subplot(3,3,5)
        ps.runstoplot=[14];
        plotlimraw(avls,ps)
        
        axt(3)=subplot(3,3,6)
         ps.runstoplot=[19];
        plotlimraw(avls,ps)
        
        linkaxes(axt)
        figure
        ps.plotrawmu=0;
        ps.STIM=0;
        ps.runstoplot=12:19
        ps.divfac=2000
        ps.ACINDTOPLOT=1;
        ps.plotdiff=1;
        ps.plotacline=1;
        ps.netdiff=1;
        ps.plotmuline=1;
        ps.plotallacpts=0;
        ps.plotstdv=1;
        [os_ph]=plot_tmcourse5MOD2(phsumbs(1),ps,avls)
        
end

if(ismember(4,figstoplot))
crax=subplot(3,2,3:4)
    ps.ax= crax
          ps.mulistind= [1 2 3 4 5 6 7 8 9 10 11]
               ps.STIM= 0
          ps.plotarrow= 0
            ps.plotave= 1
       ps.plotmumarker= 0
            ps.acindvl= [1 2 3 4 5 6 7 8 9 10 11]
            ps.muindvl= [1 2 3 4 5 6 7 8 9 10 11]
           ps.startind= 1
              ps.plotz= 0
               ps.flip= 0
               ps.startind=13;
               ps.endind=15;
               ps.FILL= 1
            ps.wnfloor= 0
         ps.plotwnline= 1
              ps.wncol= 'r'
            ps.plotsep= 1
    ps.plotinitendline= 0
         ps.plotmuline= 1
          ps.plotrawmu= 0
          ps.plotallac= 1
          ps.plotdiff=1;
          ps.netdiff=1;
          ps.plotallacpts=0;
          ps.plotrawac= 0
         ps.runstoplot= [1 2 3 4 5 6 7 8 9 10 11]
              ps.muind= [1 2 3 4 5 6 7]
         ps.plotacline= 1
    [os]=plot_tmcourse5MOD(phsumbs(5),ps,avls)
end


if (ismember(5,figstoplot))
     clear ps
%      ps.ax=subplot(6,5,29:30);
%      [sumdyn]=selectdynamicruns3(sumbs,0,0,0,0)
    
    ps.minx=1
ps.maxx=5
ps.ac_col='k'
ps.mu_col=[0.4 0.4 1]
ps.mufillcol=[1 0.7 0.7]
ps.acfillcol=[0.82 0.82 0.82]


ps.exmufillcol=[1 0.7 0.7]
ps.exacfillcol=[0.82 0.82 0.82]
ps.flip=1
ps.plotraw=0
ps.addzero=1
ps.plotsep=0;
ps.ploter=1;
ps.type='nor';
ps.insert=1
ps.aligntimes=1
ps.roundtimes=1;
ps.interptozero=1;
ps.plot_type='pct'
ps.use_exadjtimes=1;

ps.usepct=1
ps.plotbnds=[-1 9  -1 9]
ps.analbnds=[1 8]
ps.plotfixedpoints=1;
ps.plotsum=1;
ps.maxsd=100;
ps.plotmot=0;
ps.tmwins{1}=[1:2 ]
ps.tmwins{2}=[3:4]
ps.tmwins{3}=[5:6]
ps.xvls=[1.5 3.5 5.5]
ps.plotacz=1;
ps.fill=0;
% ps.tmwins{3}=[6 7]
% ps.axlman=subplot(7,5,6:9);
% ps.axacz=subplot(7,5,19);
% ps.axmot=subplot(7,5,6:9);
ps.plotlman=0;
% ps.sumax=ps.axlman;
% figure
ps.NTANAL=1;
ps.MX_TM=30
ps.calcz=1;
ps.USEPRE=0;
ps.STIM=1;
ps.MKPLOT=1;
ps.DIFF=0;
% figure
[shiftplot,combvls]=plothistoryscatterB(sumbs,ps)
% figure
ps.axsum=subplot(3,2,5:6)
ps.axz=subplot(3,2,5:6)
ps.plotcv=0;
[plotvlsst]=plotbarasymp(sumbs,combvls,ps);
ps.tmwins=[];
ps.tmwins{1}=[2:3 ]
ps.tmwins{2}=[4:5]
% ps.tmwins{3}=[5:6]
ps.DIFF=1;
% figure
[shiftplot,combvls]=plothistoryscatterB(sumbs,ps)

[plotvlsstpre]=plotbarpre(sumbs,combvls,ps);
end





if (ismember(6,figstoplot))
     clear ps
%      ps.ax=subplot(5,5,18:19);
%      [sumdyn]=selectdynamicruns3(sumbs,0,0,0,0)
    
    ps.minx=1
ps.maxx=6
ps.ac_col='k'
ps.mu_col=[.4 .4 1]
ps.mufillcol=[1 0.7 0.7]
ps.acfillcol=[0.82 0.82 0.82]
ps.exmufillcol=ps.mufillcol
ps.exacfillcol=ps.acfillcol;

ps.flip=1
ps.plotraw=0
ps.plotlman=0;
ps.plotmot=0;
ps.ploter=1;
ps.addzero=1
ps.plotsep=0;
ps.type='phar';
ps.maxsd=7;
ps.insert=1
ps.aligntimes=1
ps.usepct=0
ps.plotbnds=[-1 10 -1 10]
ps.analbnds=[0 8]
ps.addbas=0;
ps.roundtimes=1;
ps.interptozero=1;
ps.plot_type='pct'
ps.plotsum=1;
ps.plotfixedpoints=1;
ps.tmwins{1}=[1  2]
ps.tmwins{2}=[3 4]
ps.tmwins{3}=[5 6]
% ps.xvls=[1.5 3.5 5.5]
% ps.axlman=subplot(7,5,25);
% ps.axmot=subplot(7,5,25);
% ps.plotacz=0;
% ps.axacz=subplot(7,5,21:24);
% ps.sumax=ps.axacz;
ps.fill=0;
ps.NTANAL=1;
ps.MX_TM=30
ps.calcz=1;
ps.USEPRE=1;
ps.STIM=0;
ps.STIM=0;
ps.MKPLOT=1;
ps.DIFF=0;
% figure
[shiftplot,combvls]=plothistoryscatterB(phsumbs,ps)
% figure
ps.axsum=subplot(3,2,5)
ps.axz=subplot(3,2,6)
ps.plotcv=0;
[plotvlsph]=plotbarasymp(phsumbs,combvls,ps);
% ps.tmwins=[];
% ps.tmwins{1}=[2:3 ]
% ps.tmwins{2}=[4:5]
% ps.DIFF=1;
% % figure
% [shiftplot,combvls]=plothistoryscatterB(phsumbs,ps)
% 
% % ps.tmwins{3}=[5:6]
% [plotvlsphpre]=plotbarpre(phsumbs,combvls,ps);

ps.tmwins=[];
ps.tmwins{1}=[1 2 3]
ps.tmwins{2}=[4 5 6]
% ps.axsum=subplot(7,1,3:4)
% ps.axz=subplot(717)
end
if (ismember(7,figstoplot))

    %stats
%create norm version.
ph=plotvlsph;
st=plotvlsst;
phnorm=mknorm(1-ph.pct);
stnorm=mknorm(1-st.pct);

lnph=length(ph.pct(:,1));
lnst=length(st.pct(:,1));

phvec=mkvec(1-ph.mupct);
phnormvec=mkvec(phnorm);
stvec=mkvec(1-st.mupct);
stnormvec=mkvec(stnorm);
ps.ax=subplot(326)
mkcomb_barplot(ph,st,ps);
axis
phpre=plotvlsphpre;
% phvec=mkvec(phpre);
% phnorm=mknorm(phpre);
% phnormvec=mkvec(phnorm);
stpre=plotvlsstpre;
% stvec=mkvec(stpre);
% stnorm=mknorm(stpre);
% stnormvec=mkvec(stnorm);
% 

ps.ax=subplot(325)
mkprebarplot(phpre,stpre,plotvlsph,plotvlsst,ps)
g1=[ones(lnph,1);2*ones(lnph,1);3*ones(lnph,1);ones(lnst,1);2*ones(lnst,1);3*ones(lnst,1)];
g2=[ones(lnph*3,1);2*ones(lnst*3,1)];
pvec=anovan([phvec;stvec],{g1 g2});
pnormvec=anovan([phnormvec;stnormvec],{g1 g2});
%this is example of stats test.
[h,p]=ttest([[1-st.mupct(:,1)];[1-ph.mupct(:,1)]],[[1-st.mupct(:,2)];[1-ph.mupct(:,2)]],.05,'right')
end

if(ismember(8,figstoplot))
   figure;
%    ps.ax=gca();
    mkfillnetdiff(os,ps);
    axis([-2 11 -80 80])
    axis
%     ps.ax=subplot(3,4,7:8);
%     mkfillnetdiff(os_st,ps);
%     axis([-2 11 -80 80])
end







if (ismember(14,figstoplot))
     clear ps
     ps.ax=subplot(6,5,30);
%      [sumdyn]=selectdynamicruns3(sumbs,0,0,0,0)
    
    ps.minx=1
ps.maxx=5
ps.ac_col='k'
ps.mu_col=[.4 .4 1]
ps.mufillcol=[1 0.7 0.7]
ps.acfillcol=[0.82 0.82 0.82]
ps.exmufillcol=ps.mufillcol
ps.exacfillcol=ps.acfillcol;

ps.flip=1
ps.plotraw=0
ps.plotlman=0;
ps.plotmot=0;
ps.ploter=1;
ps.addzero=1
ps.plotsep=0;
ps.type='phar';
ps.maxsd=7;
ps.insert=1

ps.aligntimes=1
ps.usepct=0
ps.plotbnds=[-1 10 -1 10]
ps.analbnds=[0 8]

ps.roundtimes=1;
ps.interptozero=1;
ps.plot_type='mop'
ps.runtype='rev'
ps.plotsum=1;
ps.fill=0;
% ps.plotmean=1;
ps.plotfixedpoints=1;
ps.tmwins{1}=[1  ]
ps.tmwins{2}=[2 3]
ps.tmwins{3}=[4 5]
ps.xvls=[1 2.5 4.5]
ps.axlman=subplot(7,5,32:33);
ps.axmot=subplot(7,5,34:35);
ps.excludebs=0;
ps.excludeshnum=0;
ps.plotacz=0;
ps.addbas=0;
ps.axacz=subplot(7,5,[31]);
ps.sumax=subplot(7,5,[31]);
% figure
[phsumdyn,phsumdynasymp,phsumdynrev]=selectdynamicruns4(phsumbs,0,0,0)
[ctinds,ctindsin]=plotcombdynamics7_pharm(phsumdynrev,phsumbs,ps)

outstr.pharminds_asy=ctinds;
outstr.pharmrev=phsumdynrev;

axes(ps.axlman)
axis([0 4 -1 5])
% axis square;
axes(ps.axacz)
axis([0 4 -1 5])
plot([0 6],[0 0],'k--')
axis square;
axes(ps.axacz)
axis([0 5 -1 5])
axis square;


plot([-1 5],[0 0],'k--');
plot([-1 5],[100 100],'k--');
text(3.5,4,['n=' num2str(length(ctinds))]);
% text(3.5,75,['n=' num2str(length(ctindsin))]);
% axis square;
title('pharm/asymptote');
box off;
end
if (ismember(15,figstoplot))
    crbs=2;
    
    cmd=['cd ' bs(crbs).path ];
    eval(cmd);
    cmd=['load ' bs(crbs).matfilename];
    eval(cmd);
    
%     ps.STIM=0;
        ps.plotarrow=1;
%         ps.runstoplot=[5 7 8 9 10 11 12 13 14 15]
        ps.runstoplot=[1:30 ]
%         crax=subplot(5,5,1:4)
        
    ps.ax=subplot(6,5,21:22);
        ps.plotsep=1;
        ps.adjx=1;
        ps.startind=3;
        ps.acindvl=[1:19]
        ps.muindvl=[1:11]
        ps.FILL=1;
         ps.plotedgeybnds=[2 3]
         ps.startind=13;
        ps.plotedgexbnds=[0:15]
        ps.plotmumarker=1;
        ps.plotwn=1;
        ps.muht=2.6
        ps.plotmuline=1;
        ps.plotraw=0;
        ps.plotlman=0;
        ps.plotrawmu=1;
        ps.plotrawac=1;
%         axtmcourse(ii)=subplot(1,bsln,ii);
        plot_tmcourse5(phsumbs(crbs),ps.runstoplot,ps,avls);
%         axis square
        axis([ -2 15 2.0 2.4])
%         ps.plotedge=1;
%         ps.plotedgeybnds=[2 3]
%         ps.plotedgexbnds=[0:15]
end

 
    


%plotting reverse raw example for pu34.
if (ismember(16,figstoplot))
    figure
    crbs=2;
    cmd=['cd ' bs(crbs).path ];
    eval(cmd);
    cmd=['load ' bs(crbs).matfilename];
    eval(cmd);
    
        %this determines which meanacvalues plotted.
        ps.runstoplot=[11:19 ]
         ps.wncol=[.98 .8 .9]
%         crax=subplot(5,5,1:4)
    crax=subplot(6,5,1:30)  
    ps.muht=2.6;
        ps.plotsep=1;
        ps.adjx=1;
        
        ps.acindvl=[14:22]
        %this determines which meanmuvalues plotted.
        ps.muindvl=[5:11]
        ps.FILL=1;
         ps.plotedgeybnds=[2 3]
         ps.startind=13;
         ps.endind=15;
    
   
        ps.plotedgexbnds=[0:15]
        ps.plotwn=1;
        ps.wnfloor=2.2
        ps.plotwnline=1;
        ps.plotmumarker=1;
        ps.plotmuline=1;
        ps.plotrawmu=0;
        ps.plotrawac=0
        ps.plotz=1;
        ps.plotallac=0;
        ps.plotallac=1;
        ps.plotinitendline=0;
        ps.flip=1;
        ps.mumarksize=2
%         axtmcourse(ii)=subplot(1,bsln,ii);
        plot_tmcourse6(phsumbs(crbs),ps.runstoplot,ps,avls);
%         axis square
        axis([ -2 20 1 10])

    
    
    
end
    

%plotting reverse raw example for pu34.
if (ismember(17,figstoplot))
    figure
    crbs=1;
    cmd=['cd ' sts(crbs).path ];
    eval(cmd);
    cmd=['load ' sts(crbs).matfilename];
    eval(cmd);
    
        %this determines which meanacvalues plotted.
        ps.runstoplot=[1:55 ]
         ps.wncol=[.98 .8 .9]
%         crax=subplot(5,5,1:4)
    crax=subplot(6,5,1:30)  
    ps.muht=2.6;
        ps.plotsep=1;
        ps.adjx=1;
        
        ps.acindvl=[1:55]
        %this determines which meanmuvalues plotted.
        ps.muindvl=[1:55]
        ps.FILL=1;
         ps.plotedgeybnds=[2 3]
         ps.startind=13;
         ps.endind=15;
    
   
        ps.plotedgexbnds=[0:15]
        ps.plotwn=0;
        ps.wnfloor=2.2
        ps.plotwnline=1;
        ps.plotmumarker=1;
        ps.plotmuline=1;
        ps.plotrawmu=0;
        ps.plotrawac=0
        ps.plotz=1;
        ps.plotallac=0;
        ps.plotallac=1;
        ps.plotinitendline=0;
        ps.flip=0;
        ps.mumarksize=2
        ps.STIM=1;
%         axtmcourse(ii)=subplot(1,bsln,ii);
plot_tmcourse6(sumbs(crbs),ps.runstoplot,ps,avls);

%         axis square
     axis([-20 90 -5 5])
    
    
    
end
    
  function []=mkfillnetdiff(os,ps)
   subplot(211); 
fillx=[makerow(os.nettms) makerow(os.nettms(end:-1:1))];
    filly=[os.netdiff zeros(1,length(os.netdiff))];
col=[0.4 0.4 0.4]
    fill(fillx,filly,col,'EdgeColor','k');
hold on;
plot(os.nettms,os.netdiff,'ko','Linewidth',1,'MarkerSize',6,'MarkerFaceColor','k');  
    
      subplot(212); 
fillx=[makerow(os.nettms) makerow(os.nettms(end:-1:1))];
    filly=[os.mudiff zeros(1,length(os.mudiff))];
col=[0.4 0.4 0.4]
    fill(fillx,filly,col,'EdgeColor','k');
hold on;
plot(os.nettms,os.mudiff,'ko','Linewidth',1,'MarkerSize',6,'MarkerFaceColor','k');  
    




% 
% if (ismember(17,figstoplot))
%     cd ~/matlab/ampm/
%     figure
%     [outstruct]=metaplot_muam(phsumbs)
% end
% 
% if (ismember(18,figstoplot))
%     figure
%     plotsameday(sumbs)
% end

% if (ismember(13,figstoplot))
%      clear ps
%      ps.ax=subplot(339);
% %      [sumdyn]=selectdynamicruns3(sumbs,0,0,0,0)
%     
%     ps.minx=4
% ps.maxx=7
% ps.ac_col='k'
% ps.mu_col=['r']
% ps.mufillcol=[1 0.7 0.7]
% ps.acfillcol=[0.82 0.82 0.82]
% ps.exmufillcol=ps.mufillcol
% ps.exacfillcol=ps.acfillcol;
% 
% ps.ploter=0;
% ps.flip=1
% ps.plotraw=1
% ps.addzero=1
% ps.plotsep=0;
% ps.type='nor';
% ps.insert=1
% ps.aligntimes=1
% ps.usepct=1
% ps.plotbnds=[-1 5 -1 5]
% ps.analbnds=[0 6]
% % figure
% [sumdyn,sumdynasymp,sumdynrev]=selectdynamicrunsstim2(sumbs,0,0,0)
% [outvlaczcomb,outvlmuzcomb]=plotcombdynamics2_pharm(sumdynasymp,sumbs,ps)
% hold on;
%  plot([-1 5],[0 0],'k--');
% plot([-1 5],[3.5 3.5],'k--');
% 
% end



function avls=getavls(bs,sumbsvl)
    pth=bs(sumbsvl).path;
    mtname=bs(sumbsvl).matfilename;
    cmd=['cd ' pth 'datasum'];
    eval(cmd);
    cmd=['load ' mtname];
    eval(cmd);
    test=1;
    
     
   


function []=plotextmcourse(sumbs,indlist,ax)
    plot_tmcourse2(sumbs,indlist,ax)



%TAKEN FROM PLOTHISTORYFIGSSCRIPT2, REWRITTEN IN GENERAL FORM
function []=plotexhist(avls,ps)

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
  
       origarrow=[ps.initmean/3000 arht(1) crctmn/3000  arht(1)]
       shiftarrow=[crctmn/3000 arht(2) crfbmn/3000  arht(2)]
   
   
   plotarrows(origarrow,shiftarrow);
   
   
   end
       
    




function [ax1,ax2]=plotexspect(exsong)
clear catchvl
clear ax

figure;
ax1(1)=subplot(12,1,2:6)
exsong(1).ax=ax1(1);
ax1(2)=subplot(12,1,1);

exsong(2)=exsong(1)
ax2(1)=subplot(12,1,8:12);
exsong(2).ax=ax2(1);
ax2(2)=subplot(12,1,7);

for ii=1:2
    [dat,fs]=plotcbin(exsong(ii));
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
        axes(ax1(2));
    else
        axes(ax2(2));
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

    dtime(1)=onstime(1)/1000+stimofftime(1)/1000-exsong(1).bnds(1);
    dtime(2)=onstime(2)/1000+stimofftime(2)/1000-exsong(1).bnds(1);
    dtime(3)=onstime(3)/1000+stimofftime(3)/1000-exsong(1).bnds(1);

    hold on;
    for ii=1:3
        plot([dtime(ii) dtime(ii)],[0 20000],'r','Linewidth',2)
    end

    for ii=1:3
        if catchvl(ii)<1
        plot(dtime(ii)+.065+stimtms,dat_stimnew,'k','Linewidth',2)
        end
    end
end
axes(ax1(2))
linkaxes(ax1,'x')
axis([0 2.63 0 2e4])

axes(ax2(2))
linkaxes(ax2,'x')
axis([1.34 1.5 0 2e4])

st_tm=onstime(2)/1000+.077-.016-exsong(1).bnds(1);
end_tm=st_tm+512/32000;
axes(ax2(1))
plotbox([st_tm end_tm 6000 8000],'c')

function [outvec]=mknorm(invec)
    outvec(:,2)=invec(:,2)-invec(:,1);
    outvec(:,3)=invec(:,3)-invec(:,1);
    outvec(:,1)=invec(:,1)-invec(:,1);
function [outvec]=mkvec(invec)
outvec=[invec(:,1);invec(:,2);invec(:,3)]

function[]=mkcomb_barplot(ph,st,ps)
axes(ps.ax);
xvls=[1:3]
mnphshift=mean(ph.shiftpct);
mnphmu=mean(ph.mupct);
lnph=length(ph.mupct(:,1));
lnst=length(st.mupct(:,1));
mnstshift=mean(st.shiftpct);
mnstmu=mean(st.mupct);
cmbshift=[ph.shiftpct;st.shiftpct]
mncmbshift=mean(cmbshift);
stdshift=std(cmbshift);
stershift=stdshift./sqrt(lnph+lnst);

cmbmu=[ph.mupct;st.mupct]
mncmbmu=mean(cmbmu);
stdmu=std(cmbmu);
stermu=stdmu./sqrt(lnph+lnst);




for ii=1:length(xvls)
    bar(xvls(ii),mncmbshift(ii),0.6,'FaceColor','none');
    hold on;
    bar(xvls(ii),mncmbmu(ii),0.6,'FaceColor','none');
    hold on;
    hold on;
    plot([xvls(ii) xvls(ii)],[mncmbshift(ii)+stershift(ii) mncmbshift(ii)-stershift(ii)]);
     plot([xvls(ii) xvls(ii)],[mncmbmu(ii)+stermu(ii) mncmbmu(ii)-stermu(ii)]);
    plot(xvls(ii)+0.6,mnstshift(ii),'r<');
    plot(xvls(ii)+0.6,mnphshift(ii),'k<');
    
    plot(xvls(ii)+0.6,mnstmu(ii),'r<');
    plot(xvls(ii)+0.6,mnphmu(ii),'k<');
    
    if(ii==length(xvls))
        text(xvls(ii)+.4,mnstmu(ii),['n=' num2str(lnst)],'Color','r');
        text(xvls(ii)+.4,mnphmu(ii),['n=' num2str(lnph)],'Color','k');
    end
end

    
function mkprebarplot(phpre,stpre,ph,st,ps)
axes(ps.ax);
xvls=[1:2]
phpreind=[];
stpreind=[];
%loop through ph and st to find prematches.
%NEED TO REWRITE THIS. to use appropriate value.
for ii=1:length(ph.bsnm)
   crbs=ph.bsnm(ii);
   crsh=ph.shnm(ii);
   ind=find(phpre.bsnm==crbs&phpre.shnm==crsh);
   if(~isempty(ind))
       phpreind=[phpreind ind]
   end
end
for ii=1:length(st.bsnm)
   crbs=st.bsnm(ii);
   crsh=st.shnm(ii);
   ind=find(stpre.bsnm==crbs&stpre.shnm==crsh);
   if(~isempty(ind))
       stpreind=[stpreind ind]
   end
end
phpreind=1:length(phpre.bsnm);
stpreind=1:(length(stpre.bsnm));


    
mnphshift=mean(phpre.ac(phpreind,:));
mnphmu=mean(phpre.mu(phpreind,:));
lnph=length(phpreind);
lnst=length(stpreind);
mnstshift=mean(stpre.ac(stpreind,:));
mnstmu=mean(stpre.mu(stpreind,:));
cmbshift=[phpre.ac(phpreind,:);stpre.ac(stpreind,:)]
mncmbshift=mean(cmbshift);
stdshift=std(cmbshift);
stershift=stdshift./sqrt(lnph+lnst);

cmbmu=[phpre.mu(phpreind,:);stpre.mu(stpreind,:)]
mncmbmu=mean(cmbmu);
stdmu=std(cmbmu);
stermu=stdmu./sqrt(lnph+lnst);

for ii=1:length(xvls)
    bar(xvls(ii),mncmbshift(ii),0.6,'FaceColor','none');
    hold on;
    bar(xvls(ii),mncmbmu(ii),0.6,'FaceColor','none');
    hold on;
    hold on;
    plot([xvls(ii) xvls(ii)],[mncmbshift(ii)+stershift(ii) mncmbshift(ii)-stershift(ii)]);
     plot([xvls(ii) xvls(ii)],[mncmbmu(ii)+stermu(ii) mncmbmu(ii)-stermu(ii)]);
    plot(xvls(ii)+0.6,mnstshift(ii),'r<');
    plot(xvls(ii)+0.6,mnphshift(ii),'<k');
    
    plot(xvls(ii)+0.6,mnstmu(ii),'r<');
    plot(xvls(ii)+0.6,mnphmu(ii),'k<');
    if(ii==length(xvls))
        text(xvls(ii)+.4,mnstmu(miii),['n=' num2str(lnst)],'Color','r');
        text(xvls(ii)+.4,mnphmu(ii),['n=' num2str(lnph)],'Color','k');
    end
end

% function []=plotlimraw(avls,ps)
%     for ii=1:length(ps.runstoplot)
%        crind=ps.runstoplot(ii);
%        crvl=avls.aclist(crind,1);
%        crmuvl=avls.mulist(crind);
%         if(ii==1)
%            floorvl=floor(avls.adjvls{1}{crvl}(1,1));
%         end
%         mdac=median(avls.adjvls{1}{crvl}(:,2))./ps.divfac;
%         mdmu=mean(avls.adjvls{1}{crmuvl}(:,2))./ps.divfac;
% 
%         if (ps.plot_triangles)
%             xvl=0.9;
%             plot(xvl,mdac,'<','MarkerFaceColor','k','MarkerEdgeColor','k');
%             hold on;
%             plot(xvl,mdmu,'<','MarkerFaceColor','r','MarkerEdgeColor','r');
%         end
% 
%         if(crvl)
%            
%            
%            plot(avls.adjvls{1}{crvl}(:,1)-floorvl,avls.adjvls{1}{crvl}(:,2)./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor','k');
%            hold on;
%        end
%        crvl=avls.aclist(crind,2);
%        if(crvl)
%            [vl]=setdiff(avls.rawvls{1}{crvl}(:,1),avls.adjvls{1}{crvl}(:,1));
%            [rwind]=find(ismember(avls.rawvls{1}{crvl}(:,1),vl));
%            plot(avls.rawvls{1}{crvl}(rwind,1)-floorvl,avls.rawvls{1}{crvl}(rwind,2)./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor',[0.5, 0.5, 0.5])
%            
%            plot(avls.adjvls{1}{crvl}(:,1)-floorvl,avls.adjvls{1}{crvl}(:,2)./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor','k');
%        end
%        
%        if(crvl)
%           [vl]=setdiff(avls.rawvls{1}{crmuvl}(:,1),avls.adjvls{1}{crmuvl}(:,1));
%           [rwind]=find(ismember(avls.rawvls{1}{crmuvl}(:,1),vl)); 
%           plot(avls.rawvls{1}{crmuvl}(rwind,1)-floorvl,avls.rawvls{1}{crmuvl}(rwind,2)./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor',[1, 0.4, 0.6])
%            plot(avls.adjvls{1}{crmuvl}(:,1)-floorvl,avls.adjvls{1}{crmuvl}(:,2)./ps.divfac,'o','MarkerSize',2,'MarkerFaceColor','none','MarkerEdgeColor','r');
%        end
%         hold on; 
%     end
% 
% 
% 
% 




