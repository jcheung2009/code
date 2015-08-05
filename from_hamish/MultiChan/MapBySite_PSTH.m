   load ResultFile;
    
%      ChanList=Result(1).ChanList+1;
    load ChanList
    load ChanMap;
    
    PlotSize=[8 4];
    
 figure;
    
    colorIDX{2}=[0 0 1];
    colorIDX{3}=[1 1 1];
    colorIDX{1}=[0 0 0];
    colorIDX{4}=[0 0 1];
    ChIdx=1;
      SortNum=ChanList(:,2);
    
    for i=2:length(ChanList)+1
        
        [rw cl]=find(SiteMap==(ChanList(i-1,1)-1));
        idx=cl+((rw-1)*PlotSize(2));
        subplot(PlotSize(1),PlotSize(2),idx);
       
        
       for k=1:SortNum(i-1);
            
            ChIdx=ChIdx+1;
            
            MaxFreq=max([Result(:).PSTH]);
            
            plot(Result(ChIdx).PSTH,'color',colorIDX{k});
            title([num2str(ChanList(i-1,1))],'FontSize',6); 
           
            hold on;
%             keyboard
            
               ylim([0 MaxFreq]);                
               if mod(idx,PlotSize(2))~=1   
                    set(gca,'ytick',[]); %,'ytick',[]);                    
               else
                    set(gca,'ytick',[0 MaxFreq]);
                   ylabel('rate');
               end;
               if idx>(PlotSize(1)*PlotSize(2)-PlotSize(1)); %e.g. last row
                   xlim([10 max(T)]);
               else                 
                   xlim([10 max(T)]);
                   set(gca,'xtick',[]);
               end;
                   
                
                
%             set(gca,'xtick',[],'ytick',[]);
             
             ylim([0 200]);
       end;
        
    end;
    
    currdir=cd;
    suptitle(currdir(8:end),8);
%     savefig('MapChanPSTHfig');
    