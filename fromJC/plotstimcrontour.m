%create baseline contour.

stimx{1}=[.055 .07]
stimx{2}=[.04 .08]
stimx{3}=[.065 .08]


cd /oriole6/bk59w37redo/wnon710

load pitchdata.mat
pitchdata_bas=contours;
meanbas=mean(pitchdata_bas,2);
stdbas=std(pitchdata_bas,0,2);
figure
% muinds=[4 17:19]
raw=1;
residual=0;
% muinds=[2:8]
ln=length(muinds);
for ii=1:length(muinds)
    
    crind=muinds(ii);
    pathvl=tvls.pvls{crind}
    if(exist('baspath'))
        cmd=['cd ' baspath pathvl]
    else
        cmd=['cd ' baspath pathvl]
    end
    eval(cmd);
    load pitchdata.mat
    load extradata.mat
    axcnt(ii)=subplot(ln,1,ii);
    mnfb=mean(contours(:,crfbind),2);
    mnct=mean(contours(:,crctind),2);
    if(ii==1)
        basct=mnct
    end
    stdfb=std(contours(:,crfbind),0,2);
    stefb=stdfb./sqrt((length(crfbind)));
    stdct=std(contours(:,crctind),0,2);
    stect=stdct./sqrt(length(crctind));
    ind=find(pitchtms>.06)
    
    
    if(residual)
        plot(pitchtms(ind), mnfb(ind)-meanbas(ind)-stefb(ind),'r');
        hold on;
        plot(pitchtms(ind), mnfb(ind)-meanbas(ind)+stefb(ind),'r');
        plot(pitchtms(ind), mnct(ind)-meanbas(ind)+stect(ind),'k');
        plot(pitchtms(ind), mnct(ind)-meanbas(ind)-stect(ind),'k');
    end
    if(raw)
         plot(pitchtms(ind), mnfb(ind)-stefb(ind),'r');
         
        hold on;
        plot(pitchtms(ind),mnfb(ind),'r','Linewidth',2)
        plot(pitchtms(ind), mnfb(ind)+stefb(ind),'r');
        plot(pitchtms(ind), mnct(ind)+stect(ind),'k');
        plot(pitchtms(ind), mnct(ind)-stect(ind),'k');
        plot(pitchtms(ind),mnct(ind),'k','Linewidth',2)
        if(ii>1)
            plot(pitchtms,basct,'c--')
        end
%         plot(pitchtms(ind),meanbas,'c--')
    end
        
%     plot(stimx{ii},[0 0],'r')
end
% muinds=[9 10 12 13 15 16]
figure
for ii=1:length(muinds)
    crind=muinds(ii);
    pathvl=tvls.pvls{crind}
    if(exist('baspath'))
       cmd=['cd ' baspath pathvl]
       eval(cmd);
    else
        cmd=['cd ' pathvl]
        eval(cmd);
    end
    load pitchdata.mat
    load extradata.mat
    axhist(ii)=subplot(ln,1,ii);
   stairs(edges/3,hsctnrm,'k')
   
   hold on;
%    plot([2294 2294],[0 1],'c--','Linewidth',2)
   plot([2327+30 2327+30], [0 1], 'c--')
   plot([2327-30 2327-30], [0 1], 'c--')
   mnvlsct=mean(crvls(crctind,2));
   stdvlsct=std(crvls(crctind,2));
   mnvlsfb=mean(crvls(crfbind,2));
   stdvlsfb=std(crvls(crfbind,2));
   plot([(mnvlsfb-stdvlsfb)/3 (mnvlsfb+stdvlsfb)/3],[0.55 0.55],'r')
   plot([(mnvlsct-stdvlsct)/3 (mnvlsct+stdvlsct)/3],[0.5 0.5],'k')
   text(2125,0.5,['catch=' num2str(length(crctind))],'Color','k');
   text(2125,0.2,['fb=' num2str(length(crfbind))],'Color','r');
   stairs(edges/3,hsfbnrm,'r')
   box off;
end

%comparison between 3 and 19
compinds=[3 ]
colvec={'r' 'k'}
figure
for ii=1:length(compinds)
    pathvl=tvls.pvls{crind}
    cmd=['cd ' pathvl]
    eval(cmd);
    load extradata.mat
    load pitchdata.mat
    
    mnvlsfb=mean(contours(:,crfbind),2);
    mnvlsct=mean(contours(:,crctind),2);
    sdvlsfb=std(contours(:,crfbind),0,2);
    sevlsfb=sdvlsfb/sqrt(length(crfbind));
    plot(pitchtms,mnvlsfb,colvec{ii},'Linewidth',2)
    hold on;
    plot(pitchtms,mnvlsfb+sevlsfb,colvec{ii});
    plot(pitchtms,mnvlsfb-sevlsfb,colvec{ii});
end
compinds=[3 19]
figure
for ii=1:length(compinds)
    crind=compinds(ii);
    pathvl=tvls.pvls{crind}
    cmd=['cd ' pathvl]
    eval(cmd);
    load pitchdata.mat
    mnvlsfb=mean(contours(:,crfbind),2);
    sdvlsfb=std(contours(:,crfbind),0,2);
    sevlsfb=sdvlsfb/sqrt(length(crfbind));
    plot(pitchtms,mnvlsfb,colvec{ii},'Linewidth',2)
    hold on;
    plot(pitchtms,mnvlsfb+sevlsfb,colvec{ii});
    plot(pitchtms,mnvlsfb-sevlsfb,colvec{ii});
end
    
    
    