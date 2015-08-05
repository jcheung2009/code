function freq = getfreq(N)

freq = zeros(N,1);
for k=2:fix(N/2)+1
  freq(k) = (k-1)/N; 
end
for k=fix(N/2)+2:N
  freq(k) = (k-N-1)/N;
end

