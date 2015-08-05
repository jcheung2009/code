close('all')
clear;

filename=uigetfile;
load(filename);

% load FirstPSTH;
% load SecondPSTH;
% load ThirdPSTH;

FirstPSTHMean=mean(FirstPSTH);
SecondPSTHMean=mean(SecondPSTH);
ThirdPSTHMean=mean(ThirdPSTH);

pad=zeros(1,length(FirstPSTH));

FirstPSTH=FirstPSTH';
SecondPSTH=SecondPSTH(1:length(FirstPSTH))';
ThirdPSTH=ThirdPSTH(1:length(FirstPSTH))';
% 
% for i=2:size(FirstPSTH,1);

    template=smooth([pad FirstPSTH pad]);
    
%     match=smooth(SecondPSTH,15)';
    match=SecondPSTH;
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
        dotprodsecond(j)=sum(match*template(j:j+(length(match)-1)));
        
        j=j+1;        
    end;
        
    idx(1)=length(pad)+length(match);
 
    [crap secondpeak]=max(dotprodsecond);   
    
    
% end

% 
% for i=2:size(FirstPSTH,1);

%     template=smooth([pad FirstPSTH pad],15);
     match=FirstPSTH;
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
        dotprodfirst(j)=sum(match*template(j:j+(length(match)-1)));
        
        j=j+1;        
    end;
    
    idx(2)=length(pad)+length(match);

  [crap firstpeak]=max(dotprodfirst);
% % end



% for i=2:size(FirstPSTH,1);

%     template=[pad FirstPSTH pad];
    match=ThirdPSTH;
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
       dotprodthird(j)=sum(match*template(j:j+(length(match)-1)));
        
        j=j+1;        
    end;
    
    idx(2)=length(pad)+length(match);
    [crap thirdpeak]=max(dotprodthird);
  
% end
% 
 tseries=1:length(dotprodsecond);
% tseries=tseries-1614;
% 
% for i=2:size(FirstPSTH,1)
    
    figure;
    hold on;
    plot(tseries,dotprodfirst,'k');
    tseries=1:length(dotprodsecond);
%     tseries=tseries-1614;
    

    plot(tseries,dotprodsecond);
%     plot(idx(1),(1:2000));
    hold on;
    plot(tseries,dotprodthird,'r');

    
% end;
peak=[firstpeak;secondpeak;thirdpeak];
% open peak;
temp=diff(peak)'*-1;
open temp
open filename;