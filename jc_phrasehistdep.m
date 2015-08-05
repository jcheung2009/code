function [mean_histdep hiconf_histdep loconf_histdep mean_xx mean_xy] = jc_phrasehistdep(batch,phrase1,phrase2)
%phrase 1 = x, phrase 2 = y, phrase 3 = z
%computes histdep of xx (pick most probable transition)
%abs(p(x|x) - p(x|y)))

fid=fopen(batch,'r');
files=[];cnt=0;
while (1)
       fn=fgetl(fid);
       if (~ischar(fn))
               break;
       end
       cnt=cnt+1;
       files(cnt).fn=fn;
end
fclose(fid);

%%labels without '-' in between phrases
for i = 1:length(files);
    if exist(strcat(files(i).fn,'.not.mat')) == 0
        continue
    else
        load(strcat(files(i).fn,'.not.mat'));
        a = labels(find(~ismember(labels,'-')));
        a = strrep(a,phrase1,'x');
        a = strrep(a,phrase2,'y');
%         a = strrep(a,phrase3,'z');
        str = regexp(a,'x|y');
        histdep(i).labels = a(str);
        
    end
end

%get rid of empty trials
histdep = histdep(arrayfun(@(x) ~isempty(x.labels),histdep));


%%find conditional probability. given x, what is probability following is x  
%xx is vector that counts number of times x occurs after a x 
%given y, what is probability following is x 
%xy = is vector that counts number of times x occurs after a y 
xx = [];
xy = [];
% xz = [];
for i = 1:size(histdep,2);
    b = strfind(histdep(i).labels,'x');
    if isempty(b)
        continue
    elseif b(end) == length(histdep(i).labels)
        b = b(1:end-1);
    end
    xx = cat(1,xx,ismember(histdep(i).labels(b+1)','x'));
%     xz = cat(1,xz,ismember(histdep(i).labels(b+1)','z'));
end

for ii = 1:size(histdep,2)
    c = strfind(histdep(ii).labels,'y');
    if isempty(c)
        continue
    elseif c(end) == length(histdep(i).labels)
        c = c(1:end-1);
    end
    xy = cat(1,xy,ismember(histdep(i).labels(b+1)','x'));
end

% %conditional probabilities
% xx = sum(xx)/(sum(xx) + sum(not_xx));
% xy = sum(xy)/(sum(xy) + sum(not_xy));

%boostrap conditional probabilities and history dependence 
numreps = 5000;
shuffvect1 = zeros(1,numreps);
shuffvect2 = zeros(1,numreps);
% shuffvect3 = zeros(1,numreps);
shuffvect4 = zeros(1,numreps);
alpha = 0.95;

for i = 1:numreps
    thesamp1 = xx(randi(length(xx),1,length(xx))); %random draw with replacement
    shuffvect1(i) = sum(thesamp1)/length(thesamp1);
    thesamp2 = xy(randi(length(xy),1,length(xy)));
    shuffvect2(i) = sum(thesamp2)/length(thesamp2);
%     thesamp3= xz(randi(length(xz),1,length(xz)));
%     shuffvect3(i) = mean(thesamp3);
    shuffvect4(i) = abs(sum(thesamp1)/length(thesamp1) - sum(thesamp2)/length(thesamp2));
end

mean_xx = mean(shuffvect1);
hiconf_xx = prctile(shuffvect1,alpha*100);
loconf_xx = prctile(shuffvect1,(1-alpha)*100);

mean_xy = mean(shuffvect2);
hiconf_xy = prctile(shuffvect2,alpha*100);
loconf_xy = prctile(shuffvect2,(1-alpha)*100);

% mean_xz = mean(shuffvect3);
% hiconf_xz = prctile(shuffvect3,alpha*100);
% loconf_xz = prctile(shuffvect3,(1-alpha)*100);

mean_histdep = mean(shuffvect4);
hiconf_histdep = prctile(shuffvect4,alpha*100);
loconf_histdep = prctile(shuffvect4,(1-alpha)*100);
