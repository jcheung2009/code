
temp=dir('*.SpikeData.mat')

if exist('MergedFiles');
    load('MergedFiles');
end;

%     for j=1:length(Events)
%         if ~isempty(Events{j})
%             GoodChan{i}=[GoodChan{i} j];
%         end;
%     end
%     

%     Alltrials.Events=;%ell(32,length([GoodChan{1,:}]));
    
load(temp(1).name);
% AllEvents=Events;
results.T=T;
results.P=P;
results.F=F;
results.AllWarpedTimes=WarpedTimes;
results.AllWaveForms=WaveForms;
results.AllTimes=Times;



 for FileNum=2:length(temp); 
     
    load(temp(FileNum).name);
    start=size(results.AllTimes,2)       
    
    for k=1:32
        for j=1:size(Events,2)
            j+start
%             AllEvents{k,j+start}=Events{k,j};
            results.AllWarpedTimes{k,j+start}=WarpedTimes{k,j};
            results.AllWaveForms{k,j+start}=WaveForms{k,j};
            results.AllTimes{k,j+start}=Times{k,j};
            
        end;
        
    end;
    save('MergedFiles','results');     
 end;
    
% save('MergedFiles','results'); 
    
% 
% 

% figure;
% hand=subplot(length([GoodChan{1,:}]),1,1)
%     
%  for FileNum=1:length(temp);    
%     load(temp(i).FileNum);
% 
%     set(hand,'XTick',[])    
%     
%     for j=1:length([GoodChan{1,:}])
%         
%         hand=subplot(length([GoodChan{1,:}]),1,j)
%         set(hand,'XTick',[])
%             PlotEvents=Events{GoodChan{i}(j)}
%             plot(
%     end;
%     


