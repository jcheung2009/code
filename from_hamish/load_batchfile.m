function [ filenamesout ] = load_batchfile(filename)

fid=fopen(filename);
i=1;

filenamesout{i}=fgetl(fid);

while ischar(filenamesout{i})
    i=i+1;      
    filenamesout{i}=fgetl(fid); 
end;


filenamesout=filenamesout(1:end-1);
fclose(fid);

end

