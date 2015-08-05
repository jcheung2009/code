function [mean_histdep hiconf_histdep loconf_histdep mean_cd mean_ca] = histdep(batch,note,postnt1,postnt2)
%for divergent transitions

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

%%finds all notes after note c
for i = 1:length(files);
    if exist(strcat(files(i).fn,'.not.mat')) == 0
        continue
    else
        load(strcat(files(i).fn,'.not.mat'));
        a = strfind(labels,note);
        
       histdep(i).postnt = labels(a+1);
    end
end

%get rid of empty trials
histdep = histdep(arrayfun(@(x) ~isempty(x.postnt),histdep));


%%find conditional probability. given cd, what is probability of cd. cd is
%%vector that counts number of times CD occurs after a CD 
cd = [];
for i = 1:size(histdep,2);
    b = strfind(histdep(i).postnt,postnt1);
    if b(end) == length(histdep(i).postnt)
        b = b(1:end-1);
    end
    cd = cat(1,cd,ismember(histdep(i).postnt(b+1)',postnt1));
end

% counts number of times CD occurs after CA
ca = [];
for i = 1:size(histdep,2);
    c = strfind(histdep(i).postnt,postnt2);
    if isempty(c) == 1
        continue
    elseif c(end) == length(histdep(i).postnt)
        c = c(1:end-1);
    end
    ca = cat(1,ca,ismember(histdep(i).postnt(c+1)',postnt1));
end

%boostrap conditional probabilities and history dependence 
numreps = 5000;
shuffvect1 = zeros(1,numreps);
shuffvect2 = zeros(1,numreps);
shuffvect3 = zeros(1,numreps);
alpha = 0.95;

for i = 1:numreps
    thesamp1 = cd(randi(length(cd),1,length(cd)));
    shuffvect1(i) = mean(thesamp1);
    thesamp2 = ca(randi(length(ca),1,length(ca)));
    shuffvect2(i) = mean(thesamp2);
    shuffvect3(i) = abs(mean(thesamp1) - mean(thesamp2));
end

mean_cd = mean(shuffvect1);
hiconf_cd = prctile(shuffvect1,alpha*100);
loconf_cd = prctile(shuffvect1,(1-alpha)*100);

mean_ca = mean(shuffvect2);
hiconf_ca = prctile(shuffvect2,alpha*100);
loconf_ca = prctile(shuffvect2,(1-alpha)*100);

mean_histdep = mean(shuffvect3);
hiconf_histdep = prctile(shuffvect3,alpha*100);
loconf_histdep = prctile(shuffvect3,(1-alpha)*100);





    
