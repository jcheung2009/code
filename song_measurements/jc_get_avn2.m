function [avsp,tm,f,avsm]=jc_get_avn2(bt,NT,PRENT,POSTNT,POSTTIME,CS,PLTIT);
%using spectrogram function instead of evsmooth to plot spec of average
%target syllable. Useful to determining frequency band and timeshifts for
%song measurements.
%[avsp,t,f,avsm]=get_avn(bt,NT,PRETIME,POSTTIME,PRENT,POSTNT,CS,PLTIT);
% bt=batch file
% NT target note
% PRETIME  in seconds
% POSTTIME in seconds
% PRENT  = pre note
% POSTNT = post note
%CS chan spec

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

spcnt=0;
for ii=1:length(files)
	fn=files(ii).fn;
    if findstr(fn,'filt') > 0
        load([fn(1:end-5),'.not.mat'])
    
        elseif (exist([fn,'.not.mat'],'file'))
            load([fn,'.not.mat']);
	else
		labels=[];
	end
	labels(strfind(labels,'0'))='-';

    if (ii==1)
        [dat,fs]=evsoundin('',fn,CS);
        NPRE = 0.016*fs;
        NPOST = ceil(POSTTIME*fs);
        dat_tmp=zeros([NPRE+NPOST+1,1]);
    end

	
	srchstr=[PRENT,NT,POSTNT];
	pp=strfind(labels,srchstr)+length(PRENT);
	if (length(pp)>0)
		[filepath,filename,fileext] = fileparts(fn);
        if(strcmpi(fileext,'.wav'))
            [dat,fs] = audioread(fn);
            dat = dat *10e3; % boost amplitude to cbin levels
        else
            [dat,fs]=evsoundin('',fn,CS);
        end
		for jj=1:length(pp)
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
			
% 			[sm,sp,t,f]=evsmooth(dat_tmp,fs,10,512,0.8,2,100);
            [sm]=evsmooth(dat_tmp,fs);
            
            NFFT = 512;
            overlap = NFFT-2;
            t=-NFFT/2+1:NFFT/2;
            sigma=(1/1000)*fs;
            w=exp(-(t/sigma).^2);
            [sp f tm] = spectrogram(dat_tmp,w,overlap,NFFT,fs);
			tm=tm-NPRE/fs;
            if(spcnt==0)
				avsp=abs(sp);
				avsm=sm;
				spcnt=1;
			else
				avsp=avsp+abs(sp);
				avsm=avsm+sm;
				spcnt=spcnt+1;
			end
		end
	end
end
avsp=avsp./spcnt;
avsm=avsm./spcnt;
disp(num2str(spcnt));
if (PLTIT==1)
	imagesc(tm,f,log(abs(avsp)));set(gca,'YDir','normal');ylim([0,1e4]);
	hold on;
end
return;
