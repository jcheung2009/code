function addext(batch,ext)




fid = fopen(char(batch));
files = [];cnt = 0;
while (1)
       fn=fgetl(fid);
       if (~ischar(fn))
               break;
       end
       cnt=cnt+1;
       files(cnt).fn=fn;
end
fclose(fid);

for i = 1:length(files)
    oldname = files(i).fn;
    newname = [files(i).fn,ext];
    movefile(oldname, newname);
end
