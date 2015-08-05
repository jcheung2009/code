if exist('MergedFiles');
    load('MergedFiles');
end;

Goodchan=[]

    for j=1:length(results.AllWarpedTimes)
        if ~isempty(results.AllWarpedTimes{j})
            GoodChan=[GoodChan j];
        end;
    end

figure;
hand=subplot(length(GoodChan),1,1)
set(hand,'XTick',[])   

for i=1:length(GoodChan);
    hand=subplot(length(GoodChan),1,i+1)
    set(hand,'XTick',[])
end;
        
    

    