function [avsm,avsp,t,f,dat_total]=jc_get_avn(bt,NT,PRETIME,POSTTIME,PRENT,POSTNT,CS,align);
%uses cross correlation to align rawsong before computing smoothed and
%aligns to first rendition detected+

%[avsp,t,f,avsm]=get_avn(bt,NT,PRETIME,POSTTIME,PRENT,POSTNT,CS,PLTIT);
% bt=batch file
% NT target note
% PRETIME  in seconds
% POSTTIME in seconds
% PRENT  = pre note
% POSTNT = post note
%CS chan spec
% 
% if (~exist('PLTIT'))
% 	PLTIT=0;
% elseif (length(PLTIT)==0)
% 	PLTIT=0;
% end

if (~exist('CS'))
	CS='obs0';
elseif (length(CS)==0)
	CS='obs0';
end

if (~exist('PRENT'))
	PRENT='';
elseif (length(PRENT)==0)
	PRENT='';
end

if (~exist('POSTNT'))
	POSTNT='';
elseif (length(POSTNT)==0)
	POSTNT='';
end

% if (PLTIT==1)
% 	figure;
% end

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



%pull out all rawsong clips of syllable
dat_total = [];
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

    if (ii==1)
        [dat,fs]=evsoundin('',fn,CS);
        
        NPRE=ceil(PRETIME*fs);
        NPOST=ceil(POSTTIME*fs);
        dat_tmp=zeros([NPRE+NPOST+1,1]);
    end

	
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
            if pp(jj) > length(onsets)
                disp(fn)
            end
            
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
 			%dat_tmp_n = dat_tmp./max(dat_tmp);
           
            dat_total = [dat_total dat_tmp];
        end
    end
end

if align == 1
    
    %cross correlate each rawsong clip with first syllable 
    dat_corr = [];% 

    for i = 1:size(dat_total,2)
        [corr lag] = xcorr(abs(dat_total(:,1)),abs(dat_total(:,i)));
        dat_corr = [dat_corr corr];
    end

    %shift each rawsong by lag in cross correlation
    for i = 1:size(dat_corr,2)
        [c ii] = max(dat_corr(:,i));
        shft = lag(ii);
        if shft > 0 %shift second signal right
            dat_total(:,i) = [zeros(shft,1);dat_total(1:end-shft,i)];
        elseif shft < 0 %shift second signal left
            dat_total(:,i) = [dat_total(abs(shft)+1:end,i);zeros(abs(shft),1)];
        end
    end
end


%smooth and compute spec
spcnt = 0;
sm_total = [];
N = 512;
t = -N/2+1:N/2;
sigma = (1/1000)*fs;
w = exp(-(t/sigma).^2);


for i = 1:size(dat_total,2)

    %[sm,sp,t,f]=evsmooth(dat_total(:,i),fs,0.0001,512,0.8,2,100);


    [sp f t] = spectrogram(dat_total(:,i),w,N-2,N,fs);%matches with pitch contour code
    sm = mquicksmooth(dat_total(:,i),fs,1,2,100,'');

    sm_total = [sm_total sm];
    if (spcnt == 0)
        avsm = sm;
        avsp = abs(sp);
        spcnt = spcnt +1;
    else
        avsp = avsp + abs(sp);
        avsm = avsm + sm;
        spcnt = spcnt +1;
    end
end

avsp = avsp./spcnt;
avsm = avsm./spcnt;
 t = t-PRETIME;  
    
    

    




          
   
         