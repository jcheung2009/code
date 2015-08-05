function [total_sm, time, durs, gaps] = dur_gap(bt, motif, filestart, fileend)


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
if isempty(filestart)
    filestart = 1;
end
if isempty(fileend)
    fileend = length(files);
end


% %takes the duration of all syllables in each file 
% durs = [];
% gaps = [];
% for i = 1:length(files);
%     load(strcat(files(i).fn,'.not.mat'));
%     h = find(labels == syll);
%     duration = offsets(h)- onsets(h);
%     durs = cat(1,durs, duration,2);
%     for ii = 1:length(h)-1
%         intervals = onsets(h(ii+1))-offsets(h(ii));
%         gaps = cat(1,gaps,intervals,2);
%     end
% end

% %takes the duration and gaps of only the MOTIFS in each file
durs = [];
gaps = [];
total_sm = {};
for i = filestart:fileend;
    if ~exist([files(i).fn,'.not.mat'])
        continue
    end
    load(strcat(files(i).fn,'.not.mat'));
    a = strfind(labels, motif);
    if isempty(a)
        continue
    else
        for b = 0:length(motif)-1
            sylldurs = offsets(a+b) - onsets(a+b);
            durs = cat(1, durs, sylldurs);
        end

        for c = 1:length(motif)-1
            syllgaps = onsets(a+c) - offsets(a+c-1);
            gaps = cat(1, gaps, syllgaps);
        end

       [pth,nm,ext]=fileparts(files(i).fn);
       if(strncmp('.cbin',ext,length(ext)))
           [rawsong,fs] = ReadCbinFile(files(i).fn);
       elseif(strncmp('.wav',ext,length(ext)))
           [rawsong,fs] = wavread(files(i).fn);
       end 
       
       for iii = 1:length(a)
            motif_onset = onsets(a(iii))*32;
            motif_offset = offsets(a(iii)+length(motif)-1)*32;

            rawsong2 = rawsong(floor(motif_onset):ceil(motif_offset));
            sm = mquicksmooth(rawsong2,fs);
            sm = decimate(sm,5);
            dt = 5/fs;
            total_sm = [total_sm, sm];
       end
    end
end  
   
maxlength = max(cellfun(@(x)numel(x),total_sm));
total_sm =  cell2mat(cellfun(@(x)cat(1,x,zeros(maxlength-length(x),1)),total_sm,'UniformOutput',false));
time = [0:dt:(maxlength-1)*dt];




% %takes the duration and gaps of SPECIFIC syllables in each file 
% nt = 'd'
% nxt_nt = 'e'
% song = [];
% for i = 1:length(files);
%     load (files(i).fn);
%     note_onset = onsets(strfind(labels, nt));
%     note_offset = offsets(strfind(labels, nt));
%     duration = note_offset - note_onset;
%     song(i).duration = duration;
% end
% 
% for i = 1:length(files);
%     load (files(i).fn);
%     pair_locs = strfind(labels, strcat(nt,nxt_nt));
%     note_offset = offsets(pair_locs);
%     nxt_note_onset = onsets(pair_locs+1);
%     gap = nxt_note_onset - note_offset;
%     song(i).gap = gap;
% end
% 
% %takes the duration and gaps of only the MOTIFS in each file
% song = []
% motif = 'abcdee'
% for i = 1:length(files);
%     load(files(i).fn);
%     a = strfind(labels, motif);
%     duration = []
%     for b = 0:length(motif)-1
%         note_dur = offsets(a+b) - onsets(a+b);
%         duration = cat(1, duration, note_dur);
%         song(i).duration = duration
%     end
%     gap = []
%     for c = 1:length(motif)-1
%         note_gap = onsets(a+c) - offsets(a+c-1);
%         gap = cat(1, gap, note_gap);
%         song(i).gap = gap;
%     end
% end
% 
% %combines all the durations from each file
% duration = cat(1, song.duration);
% duration = duration(find(duration <=200));
% gap = cat(1, song.gap);
% gap = gap(find(gap <= 200));
% 
% %plot duration PDF with 250 bins 
% [c b] = hist(duration, 10);
% figure();bar(b,c/sum(c));; title('dur');
% %plot gap histogram with 250 bins
% [d e] = hist(gap, 10);
% figure();bar(e,d/sum(d));title('gap');
% 
% % %OPTION 1 FOR FINDING PEAKS
% % %fit two guassians to gap 
% % prob = rand(1,2);
% % [ug, sigg, t, iter] = fit_mix_gaussian(gap, 2);
% % figure();subplot(5,1,1);plot_mix_gaussian(ug, sigg, prob, gap);title('dur fit 9-1-2011');
% % %fit two gaussians to duration
% % [ud, sigd, t, iter] = fit_mix_gaussian(duration, 2);
% % figure();subplot(5,1,1);plot_mix_gaussian(ud, sigd, prob, duration);title('gap fit 9-1-2011');
% 
% %OPTION 2
% %findpeaks estimates locations of peaks and uses these as estimates for
% %peakfit
% %fitout = Peak number, Peak position, Height, Width, and Peak area
% [ampHist ampHistLocs] = hist(duration,100);
% [pks,pksloc] = findpeaks(ampHist/sum(ampHist),'SORTSTR','descend', 'minpeakdistance', 10);
% est1 = ampHistLocs(pksloc(1));
% est2 = ampHistLocs(pksloc(2));
% %est3 = ampHistLocs(pksloc(3));
% %est4 = ampHistLocs(pksloc(4));
% estWidth =25;
% fitInput = vertcat(ampHistLocs,ampHist/sum(ampHist));
% [fitout,fiterror,start,xi,yi] = peakfit(fitInput',est1,est1*5,2,1,0,10,[est1 estWidth est2 estWidth]);
% figure(); 
% plot(xi,yi(1,:),'r');hold on;
% plot(xi,yi(2,:),'b');hold on;
% % plot(xi, yi(3,:),'g');hold on;
% %plot(xi,yi(4,:),'k');hold on;
% plot(ampHistLocs,ampHist/sum(ampHist), 'b');hold on;
% 
% %%find curve intersects***check fitout to see if xi,yi are in right peak
% %%order 
% peak1 = [xi', yi(2,:)'];
% peak2 = [xi', yi(1,:)'];
% peak3 = [xi',yi(3,:)'];
% [x y] = curveintersect(peak1(:,1),peak1(:,2),peak2(:,1),peak2(:,2))
% [x2 y2] = curveintersect(peak2(:,1),peak2(:,2),peak3(:,1),peak3(:,2))
% 
% %separate raw data by peak borders***check curve intersects to set borders 
% peak1 = duration(find(duration>10 & duration<x(1)));
% peak2 = duration(find(duration>x(1) & duration<x2(1)));
% peak3 = duration(find(duration>x2(1) & duration<120));