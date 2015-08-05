function  [postnote] = prenote(batch,filestart, fileend, note)

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

if isempty(filestart)
    filestart = 1;
end

if isempty(fileend)
    fileend = length(files);
end


% prenote = [];
postnote = [];
for i = filestart:fileend;
    if exist(strcat(files(i).fn,'.not.mat')) == 0
        continue
    else
        load(strcat(files(i).fn,'.not.mat'));
        a = strfind(labels,note);
%       prenote = strcat(prenote,labels(a-1));
      
        postnote = strcat(postnote,labels(a+1));
       
        
    end
end

