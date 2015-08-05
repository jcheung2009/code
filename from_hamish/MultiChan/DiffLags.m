close('all')
clear;

filename=uigetfile;
load(filename);

% load FirstPSTH;
% load SecondPSTH;
% load ThirdPSTH;

FirstPSTHMean=mean(FirstPSTH');
SecondPSTHMean=mean(SecondPSTH');
ThirdPSTHMean=mean(ThirdPSTH');

pad=zeros(1,length(FirstPSTH));

SecondPSTH=SecondPSTH(:,1:length(FirstPSTH));
ThirdPSTH=ThirdPSTH(:,1:length(FirstPSTH));

for i=2:size(FirstPSTH,1);

    template=smooth([pad FirstPSTH(i,:) pad]);
    match=smooth(SecondPSTH(i,:),15)';
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
        dotprodsecond{i}(j)=sum(match*template(j:j+(length(match)-1)));
        
        j=j+1;        
    end;
        
    idx(1)=length(pad)+length(match);
 
    [crap secondpeak(i)]=max(dotprodsecond{i});   
    
    
end


for i=2:size(FirstPSTH,1);

    template=smooth([pad FirstPSTH(i,:) pad],15);
    match=smooth(FirstPSTH(i,:),15)';
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
        dotprodfirst{i}(j)=sum(match-template(j:j+(length(match)-1)));
        
        j=j+1;        
    end;
    
    idx(2)=length(pad)+length(match);

  [crap firstpeak(i)]=max(dotprodfirst{i});
end



for i=2:size(FirstPSTH,1);

    template=[pad FirstPSTH(i,:) pad];
    match=ThirdPSTH(i,:);
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
        dotprodthird{i}(j)=sum(match-template(j:j+(length(match)-1)));
        
        j=j+1;        
    end;
    
    idx(2)=length(pad)+length(match);
    [crap thirdpeak(i)]=max(dotprodthird{i});
  
end

tseries=1:length(dotprodsecond{i});
tseries=tseries-1614;

for i=2:size(FirstPSTH,1)
    
    figure;
    hold on;
    plot(tseries,dotprodfirst{i},'k');
    tseries=1:length(dotprodsecond{i});
    tseries=tseries-1614;
    
    plot(tseries,dotprodsecond{i});
%     plot(idx(1),(1:2000));
    hold on;
    plot(tseries,dotprodthird{i},'r');

    
end;