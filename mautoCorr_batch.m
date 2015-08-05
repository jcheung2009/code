function [total_acorr,time] = mautoCorr_batch(batch,filestart,fileend,xmin,xmax)
%
% [acorr_out] = mautoCorr_batch(batch,xmin,xmax)
%
% computes autocorrelation for each trace in batch across range xmin-xmax
%
%
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


total_acorr = [];
for i = filestart:fileend;
    [pth,nm,ext]=fileparts(files(i).fn);
    if(strncmp('.cbin',ext,length(ext)))
        [rawsong,fs] = ReadCbinFile(files(i).fn);
    elseif(strncmp('.wav',ext,length(ext)))
        [rawsong,fs] = wavread(files(i).fn);
    end
    sm = mquicksmooth(rawsong,fs);
    sm = decimate(sm,5);
    dt = 5/fs;
    [acorr,time] = xcorr(sm,'coeff');
    time = time*dt;
    acorr = acorr(find(time>xmin & time<xmax));
    total_acorr = cat(2,total_acorr,acorr);
end

time = time(find(time>xmin & time<xmax));
