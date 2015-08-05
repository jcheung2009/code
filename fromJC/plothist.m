figure

slength=8.331;
snums=[1 6 5 4 3 2]
subplotvals=[3 4 5 6 7 8]
imagevals=[9 10];
stimnames={'rev' 'p10' 'bos' 'm10' 'jig' 'jig-comp'}
zeroind=find(imagevec==0);
oneind=find(imagevec==1);
negind=find(imagevec==-1);


imagevecar{1}=imagevec;
imagevecar{1}(negind)=1;
imagevecar{2}=imagevec;
imagevecar{1}(zeroind)=1;
imagevecar{1}(oneind)=0;

splen=length(subplotvals)+length(imagevals)+2;



ax(1:2)=subplot(splen,1,1:2);
   
    [sm,sp,t,f]=evsmooth(corpshiftednormg{1},44150,0.01);
    imagesc(t,f,log(abs(sp)));syn;ylim([0,1e4]);
    box off;
    axis off;



for kk = 1:length(snums)%length(stimf)
	
    
    
    
    
    ax(subplotvals(kk))=subplot(splen,1,subplotvals(kk));	
        xv=[1:size(stimf(snums(kk)).hist,2)]*histbinwid;
		yv=stimf(snums(kk)).hist./stimf(snums(kk)).cnt./histbinwid;
		maxtrial(snums(kk))=max(yv);
        
        
        plot(xv,yv,[clr(1),'-']);
        
        box off;
        %axis off;
        ylabel(stimnames{kk},'Fontsize',16);
        
        
        
          set(gca,'XTickLabel',[]);
          set(gca,'Xtick',[]);
          if (kk~=length(snums))
           set(gca,'YTickLabel',[]);
           set(gca,'Ytick',[]); 
        end    
end



%This is to scale the data correctly.
for kk=1:length(snums)
    ax(subplotvals(kk))=subplot(splen,1,subplotvals(kk));
    hold on;
    maxval=max(maxtrial);
    plot(0:.1:slength, maxval/2, 'r--')
    
    axis([0 slength 0 maxval]);
end


    box off;
    for ii=1:1%length(imagevals)
        ax(imagevals(ii))=subplot(splen,1,imagevals(ii));
        clim=[[0 0 0] ;[1 1 1]]
        imagesc(imaget,f,imagevecar{ii})
        colormap('gray')
        ax(imagevals(ii))=subplot(splen,1,imagevals(ii));
        xlabel('Time (s)','Fontsize',16);
        %set(gca,'YTickLabel','Fontsize',14);
        %set(gca,'Xtick',[]);
        
        set(gca,'Ytick',[]);
        %ylabel('jigstim','Fontsize',14)
    end
    linkaxes(ax,'x');