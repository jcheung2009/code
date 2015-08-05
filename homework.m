%homework for Loren, 9_30_2014, PS 1

numtrials = 10000;
A = NaN(numtrials,1);
B = NaN(numtrials,1);
C = zeros(numtrials,1);
for i = 1:numtrials
    %determine if A fires
    x = rand(1);
    if x <= 0.1
        A(i) = 1;
    else
        A(i) = 0;
    end
    %determine if B fires
    x = rand(1);
   if x <= 0.4
       B(i) = 1;
   else
       B(i) = 0;
   end
   %determine if C fires
   if A(i) == 1 && B(i) == 1
       C(i) = 1;
   elseif A(i) == 1
       x = rand(1);
       if x <= 0.5
           C(i) = 1;
       end
   elseif B(i) == 1
       x = rand(1);
       if x <= 0.2
           C(i) = 1;
       end
   elseif A(i) == 0 && B(i) == 0
       C(i) = 0;
   end
end

%for P(A|C)
i = find(C==1);
sum(A(i))/length(i)

%for P(B|C)
i = find(C==1);
sum(B(i))/length(i)

%for P(A&B|C)
i = find(C==1);
AgivenC = A(i);
BgivenC = B(i);
ii = find(AgivenC == 1);
sum(BgivenC(ii))/length(i)
%for P(A~B|C)
(length(ii) - sum(BgivenC(ii)))/length(i)
%for P(~AB|C)
ii = find(AgivenC == 0);
sum(BgivenC(ii))/length(i)
