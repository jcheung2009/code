function [var_out] = rolling_var(invect,window)
%
%
%
%
%
%

vectlength = length(invect);

var_out = zeros(1,vectlength);
var_out = nan;
% for i = 1+window:length(invect)-window-1
%     var_out(i) = var(invect(i-window:i+window));
%     
% end

for index = 1:vectlength
    
   winStart = index;  
   
   if((index+window) > vectlength)
       winStop = index;
   else
       winStop = index+window;
   end
   
   var_out(index) = cv(invect(winStart:winStop));
   
end