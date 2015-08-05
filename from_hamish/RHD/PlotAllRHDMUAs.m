% function PlotAllRHDTraces
[filename direct]=uigetfile('*.rhd');

[amplifier_data,t_amplifier,Fs,filedata,song]=IntanRHDImportAll(direct,filename);

high_f=9000; %make Filters;
low_f=600;
nyq=Fs/2;
[a b]=butter(8,[low_f/nyq high_f/nyq]);
[c d]=butter(2,[50/nyq 250/nyq]);

% idx=find(t_amplifier==0)
% t_amplifier(idx(2:end))=[];

figure;
hold on;
song=song/max(song); 

if ~isempty(song)
 plot(t_amplifier,song,'g');
end;
% offset=max(song)*500;

% 
% subtrace=amplifier_data(12,:);
% subtrace=filtfilt(a,b,subtrace);


for i=1: size(amplifier_data,1)
% %     [t,v]=upsample2x(t_amplifier,data);

   output=amplifier_data(i,:);
%    output=output-amplifier_data(1,:);
 %  output(idx)=[];
   SpikeOut=filtfilt(a,b,output); 
   thisOffset=max(SpikeOut)-min(SpikeOut);
  
   
   SubBetaOut=filtfilt(c,d,output);
   LFPScaleFactor=max((SubBetaOut));
   MUA=smooth(abs(SpikeOut),150);
   MUA=MUA/max(MUA);
   
%      figure(1);
%     hold on;
%   
% %       plot(t_amplifier(1:length(SpikeOut)),(offset)+SpikeOut); %-amplifier_data(1,:)));
%    
%      figure(2);
     hold on;
     plot(t_amplifier(1:length(SpikeOut)),(2*i)+((abs(MUA)))); %-amplifier_data(1,:)));
%       plot(t_amplifier(1:length(SubBetaOut)),(2*i)+abs(SubBetaOut/LFPScaleFactor*-1),'r'); %-amplifier_data(1,:)));
%     
end;
    
    
    
    