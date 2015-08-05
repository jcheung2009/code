
function [vlout]=pltdynamics(avls)

subplot(212)
cmd=['cd ' avls.baspath]
    eval(cmd);
    load sumdata.mat
    
    otmtinds=1:10
for ii=1:length(otmtinds)
    crind=otmtinds(ii);
    crmt=otmt(crind)
    crdy=unqdys(crind)-unqdys(1);
  
    tmedges=[8/24 11/24 15/24  19/24]
    endtms=[7/24 21/24]
    colorvls={'k' 'r'}
    
    pltvls{1}.vls=crmt.ct_vls
    pltvls{2}.mvl=crmt.stslope
    pltvls{2}.vls=crmt.st_vls
    pltvls{1}.mvl=crmt.ctslope
    pltvls{2}.yint=crmt.stint
    pltvls{1}.yint=crmt.ctind
    
    
            lnctvls=length(crmt.ctvls(:,1));
            rndvls=rand(lnctvls,1);
            [sortout,ind]=sort(rndvls)
            numind=ceil(.1*ind)
%             plot(crdy+mod(crmt.ctvls(ind(1:numind),1),1),crmt.ctvls(ind(1:numind),2),'ko','MarkerSize',2)
%             hold on;
%             lnstvls=length(crmt.stvls(:,1));
%             rndvls=rand(lnstvls,1);
%             [sortout,ind]=sort(rndvls)
%             numind=ceil(.1*ind)
%             
%              lnstvls=length(crmt.stvls(:,1));
%             plot(crdy+mod(crmt.stvls(ind(1:numind),1),1),crmt.stvls(ind(1:numind),2),'ro','MarkerSize',2)
%             plot(crdy+mod(crmt.stvls(:,1),1),crmt.stvls(:,2),'mo','MarkerSize',2);
            
    
    
    for jj=1:2
           crmvl=pltvls{jj}.mvl
            cryint=pltvls{jj}.yint
            plot(endtms+crdy, endtms*crmvl+cryint,'Color',colorvls{jj},'Linewidth',2)
            %catch
            if(jj==1)    
            %catchvls
                vlout(ii).catch=[endtms*crmvl+cryint]
            else
            %stimvls
                vlout(ii).stim=[endtms*crmvl+cryint]
            end
            hold on;
        for vlsind=1:length(pltvls{jj}.vls)
            crvls=pltvls{jj}.vls{vlsind}
         
            crtm=crdy+tmedges(vlsind);
            crmd=median(crvls)
            crer=std(crvls)./sqrt(length(crvls));
            
            
            
            
                        plot(crtm,crmd,'o','Color',colorvls{jj})
            hold on;
            plot([crtm crtm],[crmd+crer crmd-crer],'Color',colorvls{jj})
            
        end
    end
    
    
            
            
end