function [sm_shift sm_noshift sm_offsets sm_st stringind] = jc_alignsegments(batch,NT,PRENT,POSTNT,PRETIME,POSTTIME,filestart,fileend,repeat)

fs = 32000;
CS = 'obs0'


%%aligned segments script

%get average sp and sm
[avsp, t, f, avsm] = get_avn(batch,NT,PRETIME,POSTTIME,PRENT,POSTNT,'obs0',1);
  
    

sm_shift = [];
sm_noshift = [];
sm_offsets = [];
sm_st = [];
%cross correlate and re-align smoothed der waveforms

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

stringind = [];
note_cnt = 0;
for ii=filestart:fileend
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
    if repeat == 1
        a = ismember(labels,srchstr);
        trans = [find(diff([-1 a -1])~=0)];
        trans(1) = [];
        trans(end) = [];
        string_start = trans(1:2:end);
        string_end = trans(2:2:end) - 1;
        strings = string_end - string_start +1;
        stringind = cat(1,stringind,strings');
    end
    
	if (length(pp)>0)
		
		[filepath,filename,fileext] = fileparts(fn);
        if(strcmpi(fileext,'.wav'))
            [dat,fs] = wavread(fn);
            dat = dat *10e3; % boost amplitude to cbin levels
        else
            [dat,fs]=evsoundin('',fn,CS);
        end
        
		for jj=1:length(pp)
% 			tmpon=onsets(pp(jj));
% 			tmppp=find(abs(tmpon-onsets)<=max([PRETIME,POSTTIME])*1e3);
            
% 			ontimes=[ontimes;(onsets(tmppp)-tmpon)*1e-3];
			onind=fix(round(onsets(pp(jj))*1e-3*fs));
			st=onind-NPRE;
			en=onind+NPOST;
			if (st<1)
				stind=abs(st)+2;
				st=1;
			else
				stind=1;
            end
			
            sm_st = cat(1,sm_st,st);
            
			if (en>length(dat))
				enind=length(dat_tmp)-(en-length(dat));
				en=length(dat);
			else
				enind=length(dat_tmp);
            end
            
			dat_tmp=0*dat_tmp;
			dat_tmp(stind:enind)=dat(st:en);
            if isempty(dat_tmp) 
                break 
            else
           [sm,sp,t,f]=evsmooth(dat_tmp,fs,10,512,0.8,2,100);
           note_cnt = note_cnt +1;
           [corr timecorr] = xcorr(avsm, sm, round(length(sm)/2));
           [maxcorr offset] = max(corr);
           offset = timecorr(offset);
         
            sm_offsets = cat(1,sm_offsets,offset);
           
           if offset < 0
               smshift = [sm(abs(offset)+1:end);zeros(abs(offset),1)]; %shift left
           else if offset > 0
               smshift = [zeros(offset,1);sm(1:end-offset)]; %shift right
           else if offset == 0
               smshift = sm;
               end
               end
           end
               
          sm_shift = cat(2,sm_shift,smshift);
          sm_noshift = cat(2,sm_noshift,sm);
            end
     
        end
    end
end


