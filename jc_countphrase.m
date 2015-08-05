function phrasecount = jc_countphrase(batch,filestart,fileend,phrase)

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

phrasecount = [];
for i = filestart:fileend;
    if exist(strcat(files(i).fn,'.not.mat')) == 0
        continue
    else
        load(strcat(files(i).fn,'.not.mat'));
        a = length(strfind(labels,phrase));
        if a==0
            continue
        else
            phrasecount = cat(1,phrasecount,a);
        end
    end
end
