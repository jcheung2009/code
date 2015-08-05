% function PlotAllRHDTraces

[f]=uigetfile('*.mat');


figure;
hold on;



load(f);
dt=1/Fs;

t=dt:dt:dt*length(SongBout);

plot(t,SongBout*500,'r');
hold on;

for i=1:size(ADCOut,1)
%     data=(ADCOut(i,:));
%     [t,v]=upsample2x(t_amplifier,data);
    
    plot(t,(i*750)+ADCOut(i,:));
end;
    
    
    
    