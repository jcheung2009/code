
   load ResultFile;
    
%     ChanList=Result(1).ChanList+1;
    load ChanMap;
    
    PlotSize=[8 4];
    figure;    
    currdir=cd;
    
    title(currdir(8:end));  
    hold on;
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
        
        

%         if ChIdx/
        
        for k=1:SortNum(i-1);
            
            ChIdx=ChIdx+1;
        
            for j=1:length(endidx)

                if mod(ChIdx,4)~=1
                    set(gca,'xtick',[]); %,'ytick',[]);
                end;
%                 if mod(ChIDX,8)
%                 end;
               
                TickTimes=round(Result(ChIdx).WarpedSpikeTimes{j}');
                RowVector=[ones(size(TickTimes))*j*1;ones(size(TickTimes))*(j*1-1)];   
                RowVector=RowVector+(length(endidx)*(k-1));
                plot([TickTimes;TickTimes],RowVector,'Color',colorIDX{k},'LineWidth',0.5);     
                hold on;
%                 hold on;
            end;
             title([num2str(ChanList(i-1,1))],'FontSize',6); 
            
               ylim([0 numtrials*k]); 
                  
               if mod(idx,PlotSize(2))~=1   
                    set(gca,'ytick',[]); %,'ytick',[]);                    
               else
                   set(gca,'ytick',[0 numtrials*k]);
                   ylabel('rate');
               end;
               if idx>(PlotSize(1)*PlotSize(2)-PlotSize(1)); %e.g. last row
                   xlim([10 max(T)]);
               else                 
                   xlim([10 max(T)]);
                   set(gca,'xtick',[]);
               end;
%           set(gca,'xtick',[],'ytick',[]);         
          xlim([10 max(T)]);
                     
              
        end;

%           set(gca,'xtick',[],'ytick',[]);         
%           xlim([10 max(T)]);
%           ylim([0 numtrials*k]);
          
    end;
           
    currdir=cd;
    suptitle(currdir(8:end),8);
    
    save Result;
%     savefig('MapBySiteRasterFig');
    
    
    