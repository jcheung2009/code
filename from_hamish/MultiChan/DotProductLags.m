close('all')
clear;

load FirstPSTH;
load SecondPSTH;
load ThirdPSTH;

% FirstPSTH=FirstPSTH';
% SecondPSTH=SecondPSTH';
% ThirdPSTH=ThirdPSTH';

FirstPSTHMean=mean(FirstPSTH');
SecondPSTHMean=mean(SecondPSTH');
ThirdPSTHMean=mean(ThirdPSTH');

pad=zeros(1,length(FirstPSTH));

SecondPSTH=SecondPSTH(:,1:length(FirstPSTH));
ThirdPSTH=ThirdPSTH(:,1:length(FirstPSTH));

for i=2:size(FirstPSTH,1);

    template=smooth([pad FirstPSTH(i,:) pad],15);
    match=smooth(FirstPSTH(i,:),15)';
    matchb=smooth(SecondPSTH(i,:),15)';
    matchc=smooth(ThirdPSTH(i,:),15)';
    
    j=1;
    
    while (j < (length(template)-length(match)))
        
        dotprodfirst{i}(j)=match*template(j:j+(length(match)-1));
        dotprodsecond{i}(j)=matchb*template(j:j+(length(match)-1));
        dotprodthird{i}(j)=matchc*template(j:j+(length(match)-1));Ch
        j=j+1;        
    end;
    
%     idx(2)=length(pad)+length(match);

  [crap firstpeak(i)]=max(dotprodfirst{i});
  [crap secondpeak(i)]=max(dotprodsecond{i}); 
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