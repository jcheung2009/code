close('all')
clear;

load FirstPSTH;
load SecondPSTH;
load ThirdPSTH;

FirstPSTHMean=mean(FirstPSTH');
SecondPSTHMean=mean(SecondPSTH');
ThirdPSTHMean=mean(ThirdPSTH');

SecondPSTH=SecondPSTH(:,1:length(FirstPSTH));
ThirdPSTH=ThirdPSTH(:,1:length(FirstPSTH));

for i=2:size(FirstPSTH,1);
    
%     FirstPSTH(i,:)=FirstPSTH(i,:)-mean(FirstPSTH(i,:));
%     SecondPSTH(i,:)=SecondPSTH(i,:)-mean(SecondPSTH(i,:));
%     ThirdPSTH(i,:)=ThirdPSTH(i,:)-mean(ThirdPSTH(i,:));
%     
%     [FirstFirstCorr{i} FirstFirstLags{i}]=xcov(FirstPSTH(i,:),FirstPSTH(i,:),200);
%     [FirstSecondCorr{i} FirstSecondLags{i}]=xcov(FirstPSTH(i,:),SecondPSTH(i,:),200);
%     [FirstThirdCorr{i} FirstThirdLags{i}]=xcov(FirstPSTH(i,:),ThirdPSTH(i,:),200);
%     
%     FirstFirstCorr{i}=FirstFirstCorr{i}(0.5*end:end);
%     FirstFirstLags{i}=FirstFirstLags{i}(0.5*end:end);
%     FirstSecondCorr{i}=FirstSecondCorr{i}(0.5*end:end);
%     FirstSecondLags{i}=FirstSecondLags{i}(0.5*end:end);
%     FirstThirdCorr{i}=FirstThirdCorr{i}(0.5*end:end);
%     FirstThirdLags{i}=FirstThirdLags{i}(0.5*end:end);
%     
%     figure; hold on;
%     
%      plot(FirstFirstLags{i},FirstFirstCorr{i},'k');
%     plot(FirstSecondLags{i},FirstSecondCorr{i},'b');
%     plot(FirstThirdLags{i},FirstThirdCorr{i},'r');
end

d=randperm(length(FirstPSTH(1,:)));
FirstShuffPSTH=FirstPSTH(d);

for i=2:size(FirstPSTH,1);
    
    
    FirstPSTH(i,:)=FirstPSTH(i,:)-mean(FirstPSTH(i,:));
    SecondPSTH(i,:)=SecondPSTH(i,:)-mean(SecondPSTH(i,:));
    ThirdPSTH(i,:)=ThirdPSTH(i,:)-mean(ThirdPSTH(i,:));
    
%     d=randperm(length(FirstPSTH(1,:)));
%     FirstShuffPSTH=FirstPSTH(d);
%     d=randperm(length(FirstPSTH(1,:)));
%     SecondShuffPSTH=SecondPSTH(d);
%     d=randperm(length(ThirdPSTH(1,:)));
%     ThirdShuffPSTH=ThirdPSTH(d);

%      FirstPSTH(i,:)=smooth(FirstPSTH(i,:)-mean(FirstPSTH(i,:)));
%      SecondPSTH(i,:)=smooth(SecondPSTH(i,:)-mean(SecondPSTH(i,:)));
%      ThirdPSTH(i,:)=smooth(ThirdPSTH(i,:)-mean(ThirdPSTH(i,:)));

    [coha f]=mscohere(FirstPSTH(i,:),SecondPSTH(i,:),32,30,128,1000); %'twosided');
    
    t=(1./f)*1000;
    
    figure;hold on;
    plot(t,smooth(coha));
    

    [cohb f]=mscohere(FirstPSTH(i,:),ThirdPSTH(i,:),32,30,128,1000); %,'twosided');
    t=(1./f)*1000;    
    plot(t,cohb,'r');
    
 
%     [b a]=mscohere(FirstPSTH(i,:),ThirdPSTH(i,:),128,60,256,1000,'twosided');
%     plot(a,b,'r');    
end;
