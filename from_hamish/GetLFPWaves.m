% 
 function [alpha beta gamma delta theta highgamma spks]=GetLFPWaves(datab,Fs)

% Alpha= 8–12 Hz 
% Beta = 12 and 30 Hz (High, 19+, Beta, 15-18, Low Beta, 12-15)
% Gamma = 25 to 100
% Theta, 4–7 
% Delta, 0-4

high=[4 7 12 30 90 250];
low=[0.1 4 8 12 45 120];




data=decimate(datab,1); %10Khz is good enough;

Nyq=(Fs/32)/2;

high=high./Nyq;
low=low./Nyq;



for i=1:length(high);
    
    [b a]=butter(4,[low(i) high(i)]);
    output{i}=filtfilt(b,a,data);    
%     figure;plot(output{i});
end;

delta=output{1};
theta=output{2};
alpha=output{3};
beta=output{4};
gamma=output{5};
highgamma=output{6};

Nyq=(Fs/2);
[b a]=butter(4,[600/Fs 9000/Fs]);
spks=filtfilt(b,a,datab);  




