function cbin2wavbatch(batch)
%transforms all files in batch from cbin to wav
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

for i = 1:length(files)
    cbin2wav(files(i).fn,[files(i).fn(1:end-4),'wav']);
end
