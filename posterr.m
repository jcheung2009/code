function [posthigh random1 postlow random2] = posterr(invect)

upperperc = 90;
lowerperc = 10;

x= datevec(invect(:,1));
[m n] = unique(x(:,4));

posthigh = [];
random1 = [];

for i = 1:length(m)
    v = find(x(:,4) == m(i));
     bin = invect(v,:);
     bin(:,2) = bin(:,2) - mean(bin(:,2));
     ii = find(bin(:,2) > prctile(bin(:,2),upperperc));
         if isempty(ii)
        continue
    else if ii(end) == length(bin)
            ii = ii(1:end-1);
        end
         end
    posthigh = cat(1,posthigh,bin(ii(1:end-1)+1,2));
    rand_ii = randsample(length(bin)-1,length(ii));
    random1 = cat(1,random1,bin(rand_ii+1,2));
end

postlow = [];
random2 = [];

for i = 1:length(m)
    v = find(x(:,4) == m(i));
     bin = invect(v,:);
     bin(:,2) = bin(:,2) - mean(bin(:,2));
     ii = find(bin(:,2) < prctile(bin(:,2),lowerperc));
         if isempty(ii)
        continue
    else if ii(end) == length(bin)
            ii = ii(1:end-1);
        end
         end
    postlow = cat(1,postlow,bin(ii(1:end-1)+1,2));
    rand_ii = randsample(length(bin)-1,length(ii));
    random2 = cat(1,random2,bin(rand_ii+1,2));
end


% posthigh = [];
% random1 = [];

% % looking at syllables after strings of errors of at least 2 
% for i = 1:length(m)
%     v = find(x(:,4)==m(i));
%     bin = invect(v,:);
%     bin(:,2) = bin(:,2) - mean(bin(:,2));
%     
%    % ii = find(bin(:,2) > prctile(bin(:,2),upperperc) | bin(:,2) < prctile(bin(:,2),lowerperc));
%    ii = find(bin(:,2) > prctile(bin(:,2), upperperc));
%     if isempty(ii)
%         continue
%     else if ii(end) == length(bin)
%             ii = ii(1:end-1);
%         end
%     end
%     a = [NaN; ii];
%     a = diff(a) == 1;
%     a = [a; NaN];
%     a = diff(a);%1 are start points, -1 are endpoints
%     endpoints = find(a == -1);
%     posthigh = cat(1,posthigh,bin(ii(endpoints)+1,2));
%     randpts = randsample(length(bin)-1,length(endpoints));
%     random1 = cat(1,random1,bin(randpts+1,2)); 
% end
% 
% postlow = [];
% random2 = [];
% 
% for i = 1:length(m)
%     v = find(x(:,4) == m(i));
%     bin = invect(v,:);
%     bin(:,2) = bin(:,2) -mean(bin(:,2));
%     
%     ii = find(bin(:,2) < prctile(bin(:,2), lowerperc));
%     if isempty(ii)
%         continue
%     elseif ii(end) == length(bin)
%         ii = ii(1:end-1);
%     end
%     a = [NaN; ii];
%     a = diff(a) == 1;
%     a = [a; NaN];
%     a = diff(a);%1 are start points, -1 are endpoints
%     endpoints = find(a == -1);
%     postlow = cat(1,postlow,bin(ii(endpoints)+1,2));
%     randpts = randsample(length(bin)-1,length(endpoints));
%     random2 = cat(1,random2,bin(randpts+1,2));
% end
% 
%             
            
            
            
            
%             
%             
%         post = cat(1,post,bin(ii(1:end-1)+1,2));
%     else
%         post = cat(1,post,bin(ii+1,2));
%         end
%     end
%     rand_ii = randsample(length(bin)-1,length(ii));
%     random = cat(1,random,bin(rand_ii+1,2));
% end
% 

    