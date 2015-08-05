function vallocs = findvals(invect,theval);
%
%
%
%

vallocs = [];
j = 1;
for(i=1:length(invect))
    if(invect(i) > theval);
        vallocs(j)= i;
        j = j+1;
    end
end

