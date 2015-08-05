% function PlotAllRHDTraces
[filename direct]=uigetfile('*.rhd');

[amplifier_data,t_amplifier,Fs,filedata,song]=IntanRHDImportAll(direct,filename);

high_f=9000; %make Filters;
low_f=600;
nyq=Fs/2;
[q r]=butter(8,[low_f/nyq high_f/nyq]);

% idx=find(t_amplifier==0)
% t_amplifier(idx(2:end))=[];

figure;
hold on;

if ~isempty(song)
 plot(t_amplifier,song*500,'g');
end;
offset=max(song)*500;

% 
% subtrace=amplifier_data(12,:);
% subtrace=filtfilt(a,b,subtrace);

for i=1:size(amplifier_data,1)
% %     [t,v]=upsample2x(t_amplifier,data);

disp(i)

try
    
   output=amplifier_data(i,:);

   out=filtfilt(q,r,output); 
   
      
    hold on;     
    c=find(out<-4*std(out));
%     size(c)
    a=diff(c);
    b=find(a<3);
    c(b)=[];  
    tIdx=t_amplifier(c(2:end));
    IFR=(diff(tIdx)*200);
    thisOffset=max(IFR)+100;
     offset=offset+thisOffset+50;
%     temp=gausswin(15); 
    
%     IFR=conv(IFR,temp);
%      keyboard;
    plot(tIdx,offset,'r-');
    plot(tIdx,IFR(1:length(tIdx))+offset); 
%     disp(i)
catch
end;
%     
%     figure(2);
%     hold on;
%     plot(t_amplifier(1:length(out)),(offset)+(abs(out))); %-amplifier_data(1,:)));
%     
end;
    
    
    
    