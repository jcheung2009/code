%ampmscatter.m
%outstruct.mnvls
%outstruct.init_tms
%outstruct.indvl
%outstruct.bsvl;


%     ps.runs=[1]
%     ps.numvls=15;
%     ps.calcsd=1;
%     ps.combshift=1;
%     ps.mutmbnds=[0 0.4583]

function[outstruct]=plotscatter_ampm(sumbs,bsind,ps)
    %1. shiftruns
    %2. revruns
    %3. asympruns
    %4. basruns
%     figure;
%     ps.ax=gca();
%     ps.runs=[1]
%     ps.numvls=15;
%     ps.calcsd=1;
%     ps.combshift=1;
%     ps.mutmbnds=[0 0.4583]
    %hist of previous evening versus day
    plot_type=2;
    
%     %hist of inactivation versus am.
%     plot_type=2;
%     
%     %his of am1 vs. am2
%     plot_type=3;

    %purpose of this is to create pairs which can be plotted against.
    
    %each day has an am1 am2 pm pre
    outstruct.mnvls=[];
    
    outstruct.muindvl=[];
    outstruct.bsind=[];
    outstruct.amindvl=[];
    outstruct.mutms=[];
    outstruct.amout=[];
    outstruct.muout=[];
    outstruct.amcv=[];
    
    for ii=1:length(bsind)
        tst=ii
        ps.bsind=bsind(ii);
        crbs=sumbs(bsind(ii));
    if(ismember(1,plot_type))
        [plotvls]=plotprevpm_am(crbs,ps);
    end
    if(ismember(2,plot_type))
        [outstruct]=plotam_mu(crbs,ps,outstruct);
        
    end
    if(ismember(3,plot_type))
        [plotvls]=plotam1am2(crbs,ps);
    end
    end
    
    plotvlscomb=outstruct.mnvls;
    
    hstout=histc(plotvlscomb,ps.histbnds);
    ln=length(plotvlscomb);
    hstout=hstout./ln
    stairs(ps.histbnds,hstout,'Linewidth',3,'color',ps.plotcol);
    hold on;
    
    mnout=mean(plotvlscomb);
    stdout=std(plotvlscomb)./sqrt(length(plotvlscomb));
    nvls=length(plotvlscomb);
   if(ps.tvl==1)
       htvls=[.1 .15 .2]
       ht2=[.4]
   else
       htvls=[.3 .35 .4]
       ht2=.4
   end
    text(3,htvls(1),['mnout= ' num2str(mnout)],'Fontsize',14,'Color',ps.plotcol);
    text(3,htvls(2),['ste= ' num2str(stdout)],'Fontsize',14,'Color',ps.plotcol);
    text(3,htvls(3),['nvls= ' num2str(nvls)],'Fontsize',14,'Color',ps.plotcol);
    plot([mnout-stdout mnout+stdout],[ht2 ht2],'Linewidth',2,'Color',ps.plotcol);
    plot(mnout,ht2,'Marker','v','Color',ps.plotcol,'MarkerFaceColor',ps.plotcol);
    plot([0 0],[0 0.5],'k--','Linewidth',2);
    box off;
    axis([-4 4  0 0.5]);
    function [plotvls]=plotprevpm_am(crbs,ps)
    axes(ps.ax);
    %amvalues first
    %these are all initial
    ps.type='am';
    
    [am_mn,amind]=getvals(crbs,ps);
    ps.type='pm';
    [pm_mn,pmind]=getvals(crbs,ps);
    outind=[];
    for ii=2:length(amind)
        if(crbs.alldays(ii)-crbs.alldays(ii-1)==1)
            outind=[outind ii];
        end
    end
    am_mn=am_mn(outind);
    pm_mn=pm_mn(outind-1);
    
    plot(am_mn,pm_mn,'k.');
    plotvls.am_mn=am_mn;
    plotvls.pm_mn=pm_mn;
    
function[outstruct]=plotam_mu(crbs,ps,outstruct)
   axes(ps.ax);
    ps.type='mu'
   [mumn,muind,muday]=getvals(crbs,ps);
   
   ps.type='am'
   [am_mn,amind,amday,amcv]=getvals(crbs,ps);
   am_selind=find(ismember(amday,muday));
   am_mnout=am_mn(am_selind);
   amcvout=amcv(am_selind);
%    yvec=zeros(length(am_mnout),1);
   
%    plot([am_mnout-mumn],yvec,'r.');
   
   
   if(ps.combshift)
       indpos=find(am_mnout>0);
       ypos=zeros(length(indpos),1);
       indneg=find(am_mnout<0);
       yneg=zeros(length(indneg),1);
       posvls=am_mnout(indpos)-mumn(indpos);
       negvls=-am_mnout(indneg)+mumn(indneg);
%        hstpos=histc(posvls,ps.histbnds);
% %        plot([posvls],ypos,'o','Color',ps.plotcol);
%         stairs(ps.histbnds,hstpos,'Color',ps.plotcol,'Linewidth',3);
%        hold on;
%        hstneg=histc(posvls,ps.histbnds);
% %        plot([posvls],ypos,'o','Color',ps.plotcol);
%         stairs(ps.histbnds,hstpos,'Color',ps.plotcol,'Linewidth',3);
%        plot([negvls],yneg,'o','Color',ps.plotcol);
       outstruct.mnvls=[outstruct.mnvls posvls negvls]
       outstruct.amout=[outstruct.amout am_mnout];
       outstruct.muout=[outstruct.muout mumn];
       if(~isempty(muind))
           
           outstruct.mutms=[outstruct.mutms crbs.mutmsinit(muind)];
       else
           outstruct.mutms=[outstruct.mutms muind]
       end
           outstruct.amcv=[outstruct.amcv amcvout];
        
       outstruct.bsind=[outstruct.bsind ps.bsind*ones(1,length(am_selind))];
       outstruct.muindvl=[outstruct.muindvl muind];
       outstruct.amindvl=[outstruct.amindvl amind(am_selind)];
   end
   
% function []=plotam1am2(crbs,runs)
%     ps.numvls=30;
%     [am_mn,amind]=getamvalues(crbs,ps);
%     plot
       
   
function [outmn,outind,outday,outcv]=getvals(crbs,ps)
    runlist=[];
    %select possible runs
    %between bas, shift, rev, and asymp
    if(ismember(1,ps.runs))
        runlist=[runlist crbs.shiftlist];
    end
    if(ismember(2,ps.runs))
        runlist=[runlist crbs.revlist];
        
    end    
    if(ismember(3,ps.runs))
        runlist=[runlist crbs.asympshiftlist];
        
    end
    if(ismember(4,ps.runs))
        runlist=[runlist crbs.basruns]
    end
        
    if(ps.type=='mu')
       %here you need to do a loop because of possibility of multiple
       %muruns
       [selind]=find(ismember(crbs.murun,runlist));
%         sel_runs=crbs.murun(selind);
        if(isfield(ps,'mutmbnds'))
           selind2=find(crbs.mutmsinit>ps.mutmbnds(1)&crbs.mutmsinit<ps.mutmbnds(2))
            
        end
        selind=intersect(selind2,selind);
       if(~isempty(selind))
            for ii=1:length(selind)
                nmuvls=length(crbs.muvls{selind(ii)});
                if(nmuvls>=ps.minmuvls)
                    outday(ii)=crbs.muday(selind(ii));
                    outind(ii)=selind(ii);
                    outmn(ii)=mean(crbs.muvls{selind(ii)});
                    outcv(ii)=std(crbs.muvls{selind(ii)})./sqrt(length(crbs.muvls{selind(ii)}));
                    if(ps.calcsd)
                        outmn(ii)=(outmn(ii)-crbs.initmean)./crbs.initsd;
                
                    end
                    
                else
                    outday(ii)=NaN
                    outind(ii)=NaN
                    outmn(ii)=NaN
                    outcv(ii)=NaN
                end
            end
       else
          outday=[];
          outmn=[];
          outind=[];
          outcv=[];
           
       end
    
    %find runs which are on runlist and also on crbs.initrun    
    elseif(ps.type=='am')
        [selind]=find(ismember(crbs.initrun,runlist));
        sel_runs=crbs.initrun(selind);
        if(~isempty(selind))
            for ii=1:length(selind)
            
                outind(ii)=selind(ii);
                outday(ii)=crbs.alldays(selind(ii));
                crvls=crbs.initptvls{outind(ii)};
                ln=length(crvls);
                if(ln>=ps.numvls)
                    outmn(ii)=mean(crvls(1:ps.numvls));
                    outcv(ii)=std(crvls(1:ps.numvls))./outmn(ii);
                else
                    outmn(ii)=mean(crvls(1:ln))
                    outcv(ii)=std(crvls(1:ln))./outmn(ii);
                end
                if(ps.calcsd)
                    outmn(ii)=(outmn(ii)-crbs.initmean)./crbs.initsd;
                end
            end
        else
            outmn=[];
            outind=[];
            outday=[];
            outcv=[];
            
    end
    
    elseif(ps.type=='pm')
         [selind]=find(ismember(crbs.endrun,runlist));
        sel_runs=crbs.endrun(selind);
        for ii=1:length(selind)
            outind=selind(ii);
            outday(ii)=crbs.alldays(selind(ii));
            crvls=crbs.endptvls{outind};
            ln=length(crvls);
            if(ln>=ps.numvls)
                outmn(ii)=mean(crvls(end:-1:end-ps.numvls+1));
            else
                outmn(ii)=mean(crvls(end:-1:end-ln+1));
            end
            if(ps.calcsd)
                outmn(ii)=(outmean(ii)-crbs.initmean)./crbs.initsd;
            end
            
        end
            
        
        
    end
    ind=find(isnan(outmn)==0);
    outmn=outmn(ind);
    outday=outday(ind)
    outind=outind(ind);
    outcv=outcv(ind);
    
    tst=1;

        
        
