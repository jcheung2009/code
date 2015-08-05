function [ Output ] = FilterData(data,Fs,f_low, f_high)

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%     Nyq=Fs/2;
       
    keyboard;
    [b,a]=butter(8,[f_low/(Fs/2) f_high/(Fs/2)]);
    Output=filtfilt(b, a, data);     
    
       
    
end

