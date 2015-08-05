function [total_sm,time,avg_vol,motif_dur] = motif_song(batch,motifstart,motifend,filestart,fileend)
% best for linear motif qwerty

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


total_sm = {};
% motif_acorr = [];
motif_dur = [];
avg_vol = [];
for i = filestart:fileend;
    load(strcat(files(i).fn,'.not.mat'));
    a = strfind(labels, motifstart);
    b = strfind(labels, motifend);
%     if length(a) ~= length(b)
%         display(fname)
%         continue
%     end
    [pth,nm,ext]=fileparts(files(i).fn);
   if(strncmp('.cbin',ext,length(ext)))
       [rawsong,fs] = ReadCbinFile(files(i).fn);
   elseif(strncmp('.wav',ext,length(ext)))
       [rawsong,fs] = wavread(files(i).fn);
   end
   
   if length(a) == length(b)
        for ii = 1:length(a)
             motif_onset = onsets(a(ii));
             motif_offset = offsets(b(ii));
            if motif_offset - motif_onset > 600 || motif_offset - motif_onset < 0
                  continue
            else
                duration = motif_offset - motif_onset;
                motif_dur = cat(1,motif_dur,duration);
                motif_onset = onsets(a(ii))* 32;
                motif_offset = offsets(b(ii))*32;
                rawsong2 = rawsong(motif_onset:motif_offset);
                sm = mquicksmooth(rawsong2,fs);
                %sm = decimate(sm,5);
                dt = 5/fs;
                total_sm = cat(2,total_sm,sm);
                vol = mean(sm);
                avg_vol = cat(1,avg_vol, vol);
%                 [acorr,time2] = xcorr(sm,'coeff');
%                 time2 = time2*dt;
%                 acorr = acorr(find(time2>0 & time2< 0.4));
%                 motif_acorr = cat(2,motif_acorr,acorr);
            end
        end
   end
   
   if length(a) > length(b)
        for iv = 1:length(b);
            iii = 1;
           while offsets(b(iv)) - onsets(a(iii)) > 600 || offsets(b(iv)) - onsets(a(iii)) < 0
               iii = iii + 1;
               if iii == length(a)
                   break
               end
           end
           if offsets(b(iv)) - onsets(a(iii)) > 600 || offsets(b(iv)) - onsets(a(iii)) < 0
               continue
           else
               duration = offsets(b(iv)) - onsets(a(iii));
               motif_dur = cat(1,motif_dur,duration);
               motif_onset = onsets(a(iii))*32;
               motif_offset = offsets(b(iv))*32;
               rawsong2 = rawsong(motif_onset:motif_offset);
               sm = mquicksmooth(rawsong2,fs);
               sm = decimate(sm,5);
               dt = 5/fs;
               total_sm = cat(2,total_sm,sm);
               vol = mean(sm);
               avg_vol = cat(1,avg_vol, vol);
%                [acorr,time2] = xcorr(sm,'coeff');
%                time2 = time2*dt;
%                acorr = acorr(find(time2>0 & time2< 0.4));
%                motif_acorr = cat(2,motif_acorr,acorr);      
           end   
        end
   end
   
   if length(a) < length(b)
       for iii = 1:length(a)
           iv = 1;
           while offsets(b(iv)) - onsets(a(iii)) > 600 || offsets(b(iv)) - onsets(a(iii)) < 0
               iv = iv + 1;
               if iv == length(b)
                   break
               end
           end
           if offsets(b(iv)) - onsets(a(iii)) > 600 || offsets(b(iv)) - onsets(a(iii)) < 0
               continue
           else
               duration = offsets(b(iv)) - onsets(a(iii));
               motif_dur = cat(1,motif_dur,duration);
               motif_onset = onsets(a(iii))*32;
               motif_offset = offsets(b(iv))*32;
               rawsong2 = rawsong(motif_onset:motif_offset);
               sm = mquicksmooth(rawsong2,fs);
               sm = decimate(sm,5);
               dt = 5/fs;
               total_sm = cat(2,total_sm,sm);
               vol = mean(sm);
               avg_vol = cat(1,avg_vol, vol);
%                [acorr,time2] = xcorr(sm,'coeff');
%                time2 = time2*dt;
%                acorr = acorr(find(time2>0 & time2< 0.4));
%                motif_acorr = cat(2,motif_acorr,acorr);      
           end
       end
   end
   display(fname)
end


maxlength = max(cellfun(@(x)numel(x),total_sm));
total_sm =  cell2mat(cellfun(@(x)cat(1,x,zeros(maxlength-length(x),1)),total_sm,'UniformOutput',false));
time = [0:dt:(maxlength-1)*dt];

% maxlength2 = max(cellfun(@(x)numel(x),motif_acorr));
% motif_acorr = cell2mat(cellfun(@(x)cat(1,x,zeros(maxlength2-length(x),1)),motif_acorr,'UniformOutput',false));
% % time2 = [0:dt:(maxlength2-1)*dt];
%  time2 = time2(find(time2>0 & time2<0.4));

 
 

 
