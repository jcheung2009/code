% function PlotAllRHDTraces
[filename direct]=uigetfile('*.rhd');

[amplifier_data,t_amplifier,Fs,filedata,song]=IntanRHDImportAll(direct,filename);

high_f=9000; %make Filters;
low_f=100;
nyq=Fs/2;
[a b]=butter(8,[low_f/nyq high_f/nyq]);
[c d]=butter(2,[2/nyq 30/nyq]);

% idx=find(t_amplifier==0)
% t_amplifier(idx(2:end))=[];

figure;
hold on;

if ~isempty(song)
 plot(t_amplifier,(song/max(song)-1)*1000,'g');
end;
offset=0;
% offset=max(song)*500;

% 
% subtrace=amplifier_data(12,:);
% subtrace=filtfilt(a,b,subtrace);

for i=1: size(amplifier_data,1)
% %     [t,v]=upsample2x(t_amplifier,data);

   output=amplifier_data(i,:);
%    output=output-amplifier_data(1,:);
 %  output(idx)=[];
%    SpikeOut=filtfilt(a,b,output); 
% %     [t,v]=upsample2x(t_amplifier,data);

   SpikeOut=wavefilter(amplifier_data(i,:),6); % LP at ~250hz (i,:);
%    output=output-amplifier_data(1,:);
 %  output(idx)=[];
   SpikeOut=filtfilt(a,b,output); 
%    SpikeOut=SpikeOut/((max(SpikeOut)+50)-(min(SpikeOut)-50));
    thisOffset=max(SpikeOut)-min(SpikeOut);
    offset=offset+thisOffset;
%    offset=offset+ma;
%    
%    SubBetaOut=filtfilt(c,d,output);
    
%      figure(1);
    hold on;
    plot(t_amplifier(1:length(SpikeOut)),(offset)+SpikeOut); %-amplifier_data(1,:)));
%     plot(t_amplifier(1:length(SubBetaOut)),(offset)+SubBetaOut,'r'); %-amplifier_data(1,:)));
   SpikeOut=SpikeOut/((max(SpikeOut)+50)-(min(SpikeOut)-50));
%    thisOffset=max(SpikeOut)-min(SpikeOut);
   offset=offset+1;
%    
%    SubBetaOut=filtfilt(c,d,output);
    
%      figure(1);
    hold on;
    plot(t_amplifier(1:length(SpikeOut)),(offset)+SpikeOut); %-amplifier_data(1,:)));
%     plot(t_amplifier(1:length(SubBetaOut)),(offset)+SubBetaOut,'r'); %-amplifier_data(1,:)));
%     
%     figure(2);
%     hold on;
%     plot(t_amplifier(1:length(out)),(offset)+(abs(out))); %-amplifier_data(1,:)));
%     
end;
    
    
    
    