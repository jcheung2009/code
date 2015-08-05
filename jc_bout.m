function [boutdistr] = jc_bout(indCell,incell,norm,pltit)
%estimates the median pitch at the beginning and ends of bouts 
%boutdistr is structure with fields:
%   st = [median pitch of first five syllables, bout length]
%   end = [med pitch of last five syll, bout length]
%   inboutchange = [difference in median st and end, bout length]
%   btwnboutchange = [diff btwn adjacent bouts, bout length]

%normalize pitchdata 
if strcmp(norm,'m')
    for i = 1:length(incell)
        incell{i}(:,2) = incell{i}(:,2) - mean(incell{i}(:,2));
    end
elseif strcmp(norm,'z')
    for i = 1:length(incell)
        incell{i}(:,2) = (incell{i}(:,2) - mean(incell{i}(:,2)))/std(incell{i}(:,2));
    end
end

boutdistr = struct('st',[],'end',[],'inboutchange',[],'btwnboutchange',[]);
boutends = [];
for i = 1:length(indCell)
    for ii = 1:max(indCell{i})
        if sum(indCell{i} == ii) < 20
            boutends = [boutends; NaN(1,2)];
            continue
        else
            ind = find(indCell{i}==ii);
            boutdistr.st = [boutdistr.st; [mean(incell{i}(ind(1:5),2)) sum(indCell{i}==ii)]];
            boutdistr.end = [boutdistr.end; [mean(incell{i}(ind(end-4:end),2)) sum(indCell{i} == ii)]];
            boutdistr.inboutchange = [boutdistr.inboutchange; [mean(incell{i}(ind(1:5),2)) - mean(incell{i}(ind(end-4:end),2)),sum(indCell{i}==ii)]];
            
            boutends = [boutends; mean(incell{i}(ind(1:5),2)), mean(incell{i}(ind(end-4:end),2))]; %use this matrix to get change in pitch for adjacent bouts 
        end
    end
end

if size(boutends,1)>1
    for i = 1:size(boutends,1)-1
        boutdistr.btwnboutchange = [boutdistr.btwnboutchange; boutends(i+1,1)-boutends(i,2)];
    end
    boutdistr.btwnboutchange = boutdistr.btwnboutchange(~isnan(boutdistr.btwnboutchange));
end

if ~isempty(pltit)
    minval = min([min(boutdistr.st(:,1)) min(boutdistr.end(:,1))]);
    maxval = max([max(boutdistr.st(:,1)) max(boutdistr.end(:,1))]); 
    figure(pltit);hold on;subplot(1,2,1);
    [n b] = hist(boutdistr.st(:,1),[minval:2:maxval]);plot(b,n/sum(n),'k');hold on;
    [n b] = hist(boutdistr.end(:,1),[minval:2:maxval]);plot(b,n/sum(n),'r');
    figure(pltit);hold on;subplot(1,2,2);
    minval = min([min(boutdistr.inboutchange(:,1)) min(boutdistr.btwnboutchange(:,1))]);
    maxval = max([max(boutdistr.inboutchange(:,1)) max(boutdistr.btwnboutchange(:,1))]);
    [n b] = hist(boutdistr.inboutchange(:,1),[minval:2:maxval]);plot(b,n/sum(n),'k');hold on;
    [n b] = hist(boutdistr.btwnboutchange(:,1),[minval:2:maxval]);plot(b,n/sum(n),'r');
end

              



    
    