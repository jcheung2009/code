function [timeon timeoff,sm_norm, ent_out] = jc_entsegments(batch,NT,PRENT,POSTNT,POSTTIME,PRETIME)


% %find onsets and offsets based on spectral entropy 
% 
CS = 'obs0';
fs = 32000;
timeon = [];
timeoff = [];
sm_norm = [];
ent_out = [];

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


for ii=1:length(files)
	fn=files(ii).fn;
	if (exist([fn,'.not.mat'],'file'))
		load([fn,'.not.mat']);
	else
		labels=[];
	end
	labels(findstr(labels,'0'))='-';

  
        
    NPRE=ceil(PRETIME*fs);
    NPOST=ceil(POSTTIME*fs);
    dat_tmp=zeros([NPRE+NPOST+1,1]);


	srchstr=[PRENT,NT,POSTNT];
	pp=findstr(labels,srchstr)+length(PRENT);
    
	if (length(pp)>0)
		
		[filepath,filename,fileext] = fileparts(fn);
        if(strcmpi(fileext,'.wav'))
            [dat,fs] = wavread(fn);
            dat = dat *10e3; % boost amplitude to cbin levels
			
        else
            [dat,fs]=evsoundin('',fn,CS);
        end
        
		for jj=1:length(pp)
			tmpon=onsets(pp(jj));
			tmppp=find(abs(tmpon-onsets)<=max([PRETIME,POSTTIME])*1e3);
			onind=fix(round(onsets(pp(jj))*1e-3*fs));
			st=onind-NPRE;
			en=onind+NPOST;
			if (st<1)
				stind=abs(st)+2;
				st=1;
			else
				stind=1;
			end
			
			if (en>length(dat))
				enind=length(dat_tmp)-(en-length(dat));
				en=length(dat);
			else
				enind=length(dat_tmp);
			end

			dat_tmp=0*dat_tmp;
			dat_tmp(stind:enind)=dat(st:en);
            
           [sm,sp,t,f]=evsmooth(dat_tmp,fs,10,512,0.8,2,100);
           sm = sm/max(sm);
            sm_norm = cat(2,sm_norm,sm);
            
           entout = rolling_ent(sp);
           ent_out = cat(1,ent_out,entout);
           
           baseline = mean(entout(1:10));
           threshold = min(entout) + 0.75*(baseline - min(entout));
           entbound = find(entout <= threshold);
           timeon = cat(1,timeon,t(entbound(1)));
           timeoff = cat(1,timeoff,t(entbound(end)));
        end
    end
end

%     