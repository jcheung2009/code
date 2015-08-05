fid = fopen(batch,'r')
tline = fgets(fid);
while ischar(tline)
    delete([tline(1:end-1),'.not.mat'])
    tline = fgets(fid);
end

    
    if ~isempty(strfind(tline,'synth'))
        ind = strfind(tline,'synth');
        fprintf(fleverlog,'%s',tline(ind:end));
    end
    tline = fgets(fid);
    end
    
   

invect = normalizeddata

x = zeros(length(invect),2); %vector for sum squared deviation from running average
y = zeros(length(invect),2); %vector for sum squared deviation from within day average (0)
for i = 1:length(invect)
    runavg = mRunningAvg(invect,i);
    sqdev = (invect - runavg').^2;
    ssd = sum(sqdev);
    x(i,:) = [i, ssd];
    y(i,:) = [i, sum(runavg.^2)];
end

runavg = mRunningAvg(invect,n);
sqdev = (invect-runavg').^2;
ssd = sum(sqdev)/(length(invect)-1);
dev_avg = sum(runavg.^2)/(length(invect)-1);