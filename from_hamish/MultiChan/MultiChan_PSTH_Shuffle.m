    


for i=1:Result(1).numtrials;
    
       
         
         t=[CrossCellPSTH{:,i}];
         CCshuff=zeros(size(t,2),size(t,2));
         for j=1:size(t,2);
             WithoutResub=1:Result(1).numtrials;
             for k=j:size(t,2);
                 q=randi(length(WithoutResub),1);
                 idx=WithoutResub(q);
                 WithoutResub(q)=[];
                CCORRshuff=xcorr(t(:,j),CrossCellPSTH{k+1,idx},'Coeff');      
%                 keyboard;
                CCshuff(j,k)=CCORRshuff(round(0.5*length(CCORRshuff)));
             end;
         end;
         
%          a=find(CC==0);
%          CC(a)=NaN;
%          a=find(CC>=1);
%          CC(a)=NaN;
         
          
         ShuffTrialCC(i)=nanmean(nanmean(CCshuff));         
         hand=subplot(SubPlotNum,5,[1:5]+((i+4)*5));
         ShortCC=num2str(ShuffTrialCC(i));
%          ShortCC=ShortCC(1:5)
         
%          text(-50,1,['CC=' ShortCC],'FontSize',8);
%          keyboard
         
         hold on;
         
     end;
     
     ShuffTrialCC=ShuffTrialCC'
       
%     currdir=cd;
%     suptitle(currdir(8:end),8);