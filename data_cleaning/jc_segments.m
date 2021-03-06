function [timeon, timeoff, sm_norm,thresh,spectrogram, ent_out] = jc_segments(batch,NT,PRENT,POSTNT,POSTTIME,PRETIME)

% %%find onsets and offsets by normalizing smooth amp and finding crossings
% %%at half 0.2x threshold 
% 
CS = 'obs0';
fs = 32000;
timeon = [];
timeoff = [];
sm_norm = [];
thresh = [];
ent_out = [];
spectrogram = [];


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

note_count = 0;
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
            note_count = note_count + 1;
            ampbound = [];
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
            
           [sm1,sp,t,f]=evsmooth(dat_tmp,fs,10,512,0.8,2,100);

            spectrogram(note_count).sp = sp;
            spectrogram(note_count).t = t;
            spectrogram(note_count).f = f;
% 
%            sm = filter(ones(1,256)/256,1,(dat_tmp.^2));
           sm1 = sm1/max(sm1);
           sm_norm = cat(2,sm_norm,sm1);
           
           entout = rolling_ent(sp);
           ent_out = cat(1,ent_out,entout);
           
           prebase = sm1(1:320);
           postbase = sm1(end-320:end);
      

           if mean(prebase) >= 0.15 | mean(postbase) >= 0.15
               time_on = NaN;
               time_off = NaN;
           else
                   noise = [prebase;postbase];
                   noisemean = mean(noise);
                   threshold = prctile(noise,95);
                   thresh = cat(2,thresh,threshold);
                   ampbound = find(sm1 >= threshold);
                    
                   [conseq f] = find(diff(ampbound) > 1);
                      if ~isempty(conseq)
                            conseqr = ampbound(conseq);
                            conseqr = [conseqr;ampbound(end)];
                            conseql = ampbound(conseq + 1);
                            conseql = [1;conseql];
                            [f maxconseq] = max(conseqr - conseql);
                            onbounds = [conseql(maxconseq)-10:conseql(maxconseq)+10];
                                
                                if onbounds(1) <= 0
                                    time_on = 1000*((conseql(maxconseq)/fs)-PRETIME);
                                else
                                    poly1 = polyfit(onbounds',sm1(onbounds),1);
                                    time_on = round((noisemean - poly1(2))/poly1(1));
                                        if time_on < 0 | time_on > conseql(maxconseq)+10
                                            time_on = 1000*((conseql(maxconseq)/fs)-PRETIME);
                                        else
                                            time_on = 1000*((time_on/fs)-PRETIME);
                                        end
                                end
                            
                            offbounds = [conseqr(maxconseq)-10:conseqr(maxconseq)+10];
                            
                                if offbounds(end) > length(sm1)
                                    time_off = 1000*((conseqr(maxconseq)/fs)-PRETIME);
                                else
                                    poly2 = polyfit(offbounds',sm1(offbounds),1);
                                    time_off = round((noisemean - poly2(2))/poly2(1));
                                        if time_off > length(sm1) | time_off < conseqr(maxconseq) - 10
                                            time_off = 1000*((conseqr(maxconseq)/fs)-PRETIME);
                                        else
                                            time_off = 1000*((time_off/fs)-PRETIME);
                                        end
                                end
                            
                        else
                            onbounds = [ampbound(1)-10:ampbound(1)+10];
                                if onbounds(1) <= 0
                                    time_on = 1000*((ambpound(1)/fs)-PRETIME);
                                else
                                    poly1 = polyfit(onbounds',sm1(onbounds),1);
                                    time_on = round((noisemean - poly1(2))/poly1(1));
                                        if time_on < 0 | time_on > ampbound(1)+10
                                            time_on = 1000*((ampbound(1)/fs)-PRETIME);
                                        else
                                            time_on = 1000*((time_on/fs)-PRETIME);
                                        end
                                end
                            offbounds = [ampbound(end)-10:ampbound(end)+10];
                                if offbounds(end) > length(sm1)
                                    time_off = 1000*((ampbound(end)/fs)-PRETIME);
                                else
                                    poly2 = polyfit(offbounds',sm1(offbounds),1);
                                    time_off = round((noisemean - poly2(2))/poly2(1));
                                        if time_off > length(sm1) | time_off < ampbound(end) - 10
                                            time_off = 1000*((ampbound(end)/fs)-PRETIME);
                                        else
                                            time_off = 1000*((time_off/fs)-PRETIME);
                                        end
                                end
                        end
           end
               
            timeon = cat(1,timeon,time_on);
            timeoff = cat(1,timeoff,time_off);
           
         end
       
       end
                
        
        
end






           
         



            
            
            
            
            
            