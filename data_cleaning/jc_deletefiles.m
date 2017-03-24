function jc_deletefiles(bt)

fid=fopen(bt,'r');
files=[];cnt=0;
while (1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    cnt=cnt+1;
    files(cnt).fn=fn;
end


for i = 1:length(files)
    delete([files(i).fn,'.not.mat']);
end

