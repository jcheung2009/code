function [aligned_dat] = jc_getavmotif(bt,motif,PRETIME,POSTTIME,CS,PLTIT);

if (~exist('PLTIT'))
	PLTIT=0;
elseif (length(PLTIT)==0)
	PLTIT=0;
end

if (~exist('CS'))
	CS='obs0';
elseif (length(CS)==0)
	CS='obs0';
end

if (PLTIT==1)
	figure;
end

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
fclose(fid);





total_dat = {};
for ii=1:length(files)
	fn=files(ii).fn;
    if findstr(fn,'filt') > 0
        load([fn(1:end-5),'.not.mat'])
    
        elseif (exist([fn,'.not.mat'],'file'))
            load([fn,'.not.mat']);
	else
		labels=[];
	end
	labels(findstr(labels,'0'))='-';
	

	pp=findstr(labels,motif);
	if (length(pp)>0)
		
		[filepath,filename,fileext] = fileparts(fn);
        if(strcmpi(fileext,'.wav'))
            [dat,fs] = wavread(fn);
            dat = dat *10e3; % boost amplitude to cbin levels
        else
            [dat,fs]=evsoundin('',fn,CS);
        end
        NPRE=ceil(PRETIME*fs);
        NPOST=ceil(POSTTIME*fs);
		for jj=1:length(pp)
            onsamp = (onsets(pp(jj))*1e-3*fs)-NPRE;
            offsamp = (offsets(pp(jj)+length(motif)-1)*1e-3*fs)+NPOST;
            total_dat = cat(2,total_dat,dat(onsamp:offsamp));
        end
    end
end
            
maxlength = max(cellfun(@(x)numel(x),total_dat));
total_dat =  cell2mat(cellfun(@(x)cat(1,x,zeros(maxlength-length(x),1)),...
    total_dat,'UniformOutput',false));	

refdat = total_dat(:,1);
[aligned_dat] = jc_aligndat(refdat,total_dat,0);
			