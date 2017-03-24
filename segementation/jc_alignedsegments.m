function [timeon timeoff] = jc_alignedsegments(batch,NT,PRENT,POSTNT,POSTTIME,PRETIME)    




%get average sp and sm
[avsp, t, f, avsm] = get_avn(batch,NT,0.05,0.1,'','','obs0',1);
  
    

sm_shift = [];
sm_noshift = [];
%cross correlate and re-align smoothed der waveforms
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


for ii=1:length(files)
	fn=files(ii).fn;
	if (exist([fn,'.not.mat'],'file'))
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

	disp(fn);
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
			ontimes=[ontimes;(onsets(tmppp)-tmpon)*1e-3];
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
           [corr timecorr] = xcorr(avsm, sm, round(length(sm)/2),'coeff');
           [maxcorr offset] = max(corr);
           offset = timecorr(offset);
           
           if offset < 0
               smshift = [sm(abs(offset)+1:end);zeros(abs(offset),1)];
           else if offset > 0
               smshift = [zeros(offset,1);sm(1:end-offset)];
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
% 
% %%% get average waveform of aligned smooth waves and average derivative of
% %%% template wave. define onset and offsets using findpeaks and manual ID
% avsm_align = mean(sm_shift,2);
% avsm_alignder = abs(diff(avsm_align));
% 
% [pks locs] = findpeaks(avsm_alignder);
% 
% figure(100);hold on;
% plot(avsm_align,'k');
% plot(avsm_alignder,'r');
% 
% %%pick peaks for onset and offset
% 
% 
% %%do dtw on all deriv smooth waveforms against template wave. ID matching
% %%onset and offset times
% %%use locs from figure for avsm_alignder
% locs_onset = 1693 
% locs_offset = 4140
% fs = 32000;
% syllon = [];
% sylloff = [];
% 
% for i = 1:size(sm_shift,2)
%     sm_shiftder(:,i) = abs(diff(sm_shift(:,i)));
% end
% 
% for ii = 1:size(sm_shiftder,2)
%    [dist,d,k,w,rw,tw] = dtw(sm_shiftder(:,ii),avsm_alignder,0);
%    ind = find(w(:,2) == locs_onset);
%    ind_shift = w(ind(1),1); %onset point in sm_shiftder
%    ind2 = find(w(:,2) == locs_offset);
%    ind2_shift = w(ind2(1),1); %offset point in sm_shiftder
%    syllon(ii,1) = ind_shift/fs;
%    sylloff(ii,1) = ind2_shift/fs;
% end
% 
% 
%    
% 
% 
% 


           
         



            
            
            
            
            
            