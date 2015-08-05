
function []=plotcontour2(ctcontours,fbcontours,avls,ps)
%     ind=avls.basruns;
%     pathvl=avls.pvls{ind};
%     if(isfield(avls,'baspath'))
%         cmd=['cd ' avls.baspath pathvl]
%     else
%         cmd=['cd '  pathvl]
%     end
%     eval(cmd);
%     cmd=['load ' btvl '.mat']
% 
%     eval(cmd);
    [basct,pitchtms]=getbas(avls,ps.basind);
    
    
        axes(ps.ax);    
        mnfb=mean(fbcontours,2)/1000;
        mnct=mean(ctcontours,2)/1000;
        
   
        stdfb=std(fbcontours,0,2)/1000;
        stefb=stdfb./sqrt((length(fbcontours(1,:))));
 
        stdct=std(ctcontours,0,2)/1000;
        stect=stdct./sqrt(length(ctcontours(1,:)));
        ind=find(pitchtms>ps.TIMEBNDS(1)&pitchtms<ps.TIMEBNDS(2))
        xvls=pitchtms(ind);      
        fillx=[xvls xvls(end:-1:1)]
        fbvec=[mnfb(ind)+stefb(ind)]
        fbvec2=[mnfb(ind)-stefb(ind)]
        filly=[fbvec' fbvec2(end:-1:1)']

        ctvec=[mnct(ind)+stect(ind)]
        ctvec2=[mnct(ind)-stect(ind)]
        filly2=[ctvec' ctvec2(end:-1:1)']

        mufillcol=[0.82 0.82 0.82]
        acfillcol=[1 .8 .8]

         if(isfield(ps,'fillbnds'))
                xvec=[ps.fillbnds(1:2) ps.fillbnds(2) ps.fillbnds(1)]
                yvec=[2.25 2.25 2.35 2.35]
                fill(xvec,yvec,[0.6 0.6 0.6],'edgecolor','none');
                hold on;
            end
        
    fill(fillx,filly,acfillcol,'edgecolor','none');
      hold on;
     fill(fillx,filly2,mufillcol,'edgecolor','none');
%         plot(pitchtms(ind), mnfb(ind)-stefb(ind),'r');
%         hold on;
        plot(xvls,mnfb(ind),'r','Linewidth',1)
        hold on;
%         plot(pitchtms(ind), mnfb(ind)+stefb(ind),'r');
    
        
%         plot(pitchtms(ind), mnct(ind)+stect(ind),'k');
%         plot(pitchtms(ind), mnct(ind)-stect(ind),'k');
        plot(xvls,mnct(ind),'k','Linewidth',1)
        
            plot(xvls,basct(ind)/1000,'k--')
            
           
        
   if(isfield(ps,'plotstim'))
            st_time=ps.OFFMEAN-ps.stimdiff;
            tms=st_time:1/32000:(length(ps.stimvals)/32000+st_time);
            
            xvls=[tms(1)-ps.stimwidth/2 tms(1)+ps.stimwidth/2]
            fillx=[xvls xvls([2 1])]
            fillybnds=[2.28 2.32]
            filly=[fillybnds(1) fillybnds(1) fillybnds(2) fillybnds(2)];
            fill(fillx, filly,[0.6 0.6 0.6],'edgecolor','none');
            plot(tms(1:335),ps.stimvals*ps.STIMGAIN+ps.STIMOFFSET,'k');
         end
        
            
% %     mupts=mumean(1:length(indvl))
%     acpts=acmean(1:length(indvl))
%     yvec=[avls.initmean{notevl}*ones(length(mupts),1);mupts(end:-1:1)']
%     

    

   
    box off;
    
    



function [basct,pitchtms]=getbas(avls,basind)

    pathvl=avls.pvls{basind}
    btvl=avls.cvl{basind};
    
    if(isfield(avls,'baspath'))
        cmd=['cd ' avls.baspath pathvl]
    else
        cmd=['cd '  pathvl]
    end
    eval(cmd);
    cmd=['load ' btvl '.mat']

    eval(cmd);
    basct=mean(contours(:,crctind),2);
    