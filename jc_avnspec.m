function [pc_sal pc_cond avn1 tm1 f1 avn2 tm2 f2] = jc_avnspec(fv_sal,fv_cond)
%fv is structure from jc_findwnote5
%produces pitch contours for matched time windows in fv_cond and fv_sal

NFFT = 512;
fs = 32000;

overlap = NFFT-2;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);%gaussian window for spectrogram

tb_cond = jc_tb([fv_cond(:).datenm]',7,0);
tb_sal = jc_tb([fv_sal(:).datenm]',7,0);

ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
                
% for i = 1:length(ind)
%     filtsong = bandpass(fv_sal(ind(i)).smtmp,fs,300,15000,'hanningffir');
%     [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
%     spec(i).sp = abs(sp);
%     spec(i).tm = tm;
%     spec(i).f = f;
% end
% 
% [maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec));
% freqlength = max(arrayfun(@(x) length(x.f),spec));
% avgspec = zeros(freqlength,maxlength);
% for ii = 1:length(spec)
%     pad = maxlength-length(spec(ii).tm);
%     avgspec = avgspec+[spec(ii).sp,zeros(size(spec(ii).sp,1),pad)];
% end
% avn1 = avgspec./length(spec);
% tm1 = spec(ind1).tm;
% f1 = spec(ind1).f; 
% 
% spec = [];
% for i = 1:length(fv_cond)
%     filtsong = bandpass(fv_cond(i).smtmp,fs,300,15000,'hanningffir');
%     [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
%     spec(i).sp = abs(sp);
%     spec(i).tm = tm;
%     spec(i).f = f;
% end
% 
% [maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec));
% freqlength = max(arrayfun(@(x) length(x.f),spec));
% avgspec = zeros(freqlength,maxlength);
% for ii = 1:length(spec)
%     pad = maxlength-length(spec(ii).tm);
%     avgspec = avgspec+[spec(ii).sp,zeros(size(spec(ii).sp,1),pad)];
% end
% avn2 = avgspec./length(spec);
% tm2 = spec(ind1).tm;
% f2 = spec(ind1).f; 

pc_sal = jc_getpc(fv_sal(ind));
pc_cond = jc_getpc(fv_cond);

figure;hold on;
xbins = linspace(pc_sal.tm(1),pc_sal.tm(end),length(pc_sal.tm));
fill([xbins fliplr(xbins)],...
    [nanmean(pc_sal.pc,2)'-nanstderr(pc_sal.pc,2)',...
    fliplr(nanmean(pc_sal.pc,2)'+nanstderr(pc_sal.pc,2)')],'k','edgecolor','none',...
    'FaceAlpha',0.5); hold on;
xbins2 = linspace(pc_cond.tm(1),pc_cond.tm(end),length(pc_cond.tm));
fill([xbins2 fliplr(xbins2)],...
    [nanmean(pc_cond.pc,2)'-nanstderr(pc_cond.pc,2)',...
    fliplr(nanmean(pc_cond.pc,2)'+nanstderr(pc_cond.pc,2)')],'r','edgecolor','none',...
    'FaceAlpha',0.5); hold on;

ylabel('Frequency (Hz)','FontWeight','bold');
xlabel('Time (s)','FontWeight','bold');










