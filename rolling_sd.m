function [sd_out] = rolling_sd(invect,window)
%
%
%
%
%
%

vectlength = length(invect);

sd_out = zeros(1,vectlength);
sd_out = nan;
% for i = 1+window:length(invect)-window-1
%     var_out(i) = var(invect(i-window:i+window));
%     
% end


waithandle = waitbar(0,'starting...');
for index = 1:vectlength
    
   winStart = index;  
   
   if((index+window) > vectlength)
       winStop = index;
   else
       winStop = index+window;
   end
   
   sd_out(index) = std(invect(winStart:winStop));
   waitbar(index/vectlength,waithandle,'working...');
end
close(waithandle);