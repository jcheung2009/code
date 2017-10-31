function [pc_sal pc_cond avn1 tm1 f1 avn2 tm2 f2] = jc_avnspec(fv_sal,fv_cond,timematch)
%fv is structure from jc_findwnote5
%produces pitch contours for matched time windows in fv_cond and fv_sal

NFFT = 512;
fs = 32000;

overlap = NFFT-2;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);%gaussian window for spectrogram

if timematch == 'y'
    tb_cond = jc_tb([fv_cond(:).datenm]',7,0);
    tb_sal = jc_tb([fv_sal(:).datenm]',7,0);
    ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
    pc_sal = jc_getpc(fv_sal(ind));
    sm_sal = jc_getsm(fv_sal(ind));
else
    pc_sal = jc_getpc(fv_sal);
    sm_sal = jc_getsm(fv_sal);
end
pc_cond = jc_getpc(fv_cond);     
sm_cond = jc_getsm(fv_cond);

for i = 1:length(fv_sal)
    filtsong = bandpass(fv_sal(i).smtmp,fs,300,10000,'hanningffir');
    [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
    spec(i).sp = abs(sp);
    spec(i).tm = tm-0.016;
    spec(i).f = f;
end

[maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec));
freqlength = max(arrayfun(@(x) length(x.f),spec));
avgspec = zeros(freqlength,maxlength);
for ii = 1:length(spec)
    pad = maxlength-length(spec(ii).tm);
    avgspec = avgspec+[spec(ii).sp,zeros(size(spec(ii).sp,1),pad)];
end
avn1 = avgspec./length(spec);
tm1 = spec(ind1).tm;
f1 = spec(ind1).f; 

spec = [];
for i = 1:length(fv_cond)
    filtsong = bandpass(fv_cond(i).smtmp,fs,300,10000,'hanningffir');
    [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
    spec(i).sp = abs(sp);
    spec(i).tm = tm-0.016;
    spec(i).f = f;
end

[maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec));
freqlength = max(arrayfun(@(x) length(x.f),spec));
avgspec = zeros(freqlength,maxlength);
for ii = 1:length(spec)
    pad = maxlength-length(spec(ii).tm);
    avgspec = avgspec+[spec(ii).sp,zeros(size(spec(ii).sp,1),pad)];
end
avn2 = avgspec./length(spec);
tm2 = spec(ind1).tm;
f2 = spec(ind1).f; 

id = find(f1>=300 &f1<=10000);
f1=f1(id);f2=f2(id);avn1=avn1(id,:);avn2=avn2(id,:);

figure;hold on;subtightplot(2,2,1,0.07,0.07,0.07);hold on;
imagesc(tm1,f1,log(avn1));axis('xy');colormap jet;ylim([300 10000]);;hold on;
plot(pc_sal.tm,nanmean(pc_sal.pc,2),'g','linewidth',2);hold on;
xlim([tm1(1) tm1(end)]);
subtightplot(2,2,2,0.07,0.07,0.07);hold on;
imagesc(tm2,f2,log(avn2));axis('xy');colormap jet;ylim([300 10000]);hold on;
xlim([tm2(1) tm2(end)]);
plot(pc_cond.tm,nanmean(pc_cond.pc,2),'g','linewidth',2);hold on;
subtightplot(2,2,3,0.07,0.07,0.07);hold on;
plot((sm_sal.tm/fs)-0.016,log(nanmean(sm_sal.sm,2)),'k','linewidth',2);hold on;
subtightplot(2,2,4,0.07,0.07,0.07);hold on;
plot((sm_cond.tm/fs)-0.016,log(nanmean(sm_cond.sm,2)),'r','linewidth',2);hold on;

% if ~isempty(plothandle);
%     axes(plothandle);
% else
%     figure;hold on;
% end
% xbins = linspace(pc_sal.tm(1),pc_sal.tm(end),length(pc_sal.tm));
% fill([xbins fliplr(xbins)],...
%     [nanmean(pc_sal.pc,2)'-nanstderr(pc_sal.pc,2)',...
%     fliplr(nanmean(pc_sal.pc,2)'+nanstderr(pc_sal.pc,2)')],'k','edgecolor','none',...
%     'FaceAlpha',0.5); hold on;
% xbins2 = linspace(pc_cond.tm(1),pc_cond.tm(end),length(pc_cond.tm));
% fill([xbins2 fliplr(xbins2)],...
%     [nanmean(pc_cond.pc,2)'-nanstderr(pc_cond.pc,2)',...
%     fliplr(nanmean(pc_cond.pc,2)'+nanstderr(pc_cond.pc,2)')],'r','edgecolor','none',...
%     'FaceAlpha',0.5); hold on;
% set(gca,'fontweight','bold')
% ylabel('Frequency (Hz)','FontWeight','bold');
% xlabel('Time (s)','FontWeight','bold');
% hold off;
% 
% if ~isempty(plothandle2)
%     axes(plothandle2);
%     
%     imagesc(tm1,f1,avn1);axis('xy');colormap hot;ylim([0 10000]);
%     set(plothandle2,'fontweight','bold');
%     hold off;
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
