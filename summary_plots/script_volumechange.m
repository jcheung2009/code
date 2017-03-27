%look at relative change in volumes in syllables 

% ff = load_batchf('batchnaspm');
% load('analysis/data_structures/naspmpitchlatency');
% motif = 'aabb';
% excludewashin = 1;
% matchtm = '';
% latency = 1.88;
% fs = 32000;
% th = 0.3;
% min_int = 5;
% min_dur = 20;
% numtrials = length(ff)/2;
% volsal = cell(length(motif),1,numtrials);
% volcond = cell(length(motif),1,numtrials);
% numtrial = 1;
% for i = 1:2:length(ff)
%     load(['analysis/data_structures/motif_',motif,'_',ff(i).name]);
%     load(['analysis/data_structures/motif_',motif,'_',ff(i+1).name]);
%     
%     motifsal = eval(['motif_',motif,'_',ff(i).name]);
%     motifcond = eval(['motif_',motif,'_',ff(i+1).name]);
%     
%     tb_sal = jc_tb([motifsal(:).datenm]',7,0);
%     tb_cond = jc_tb([motifcond(:).datenm]',7,0);
%     
%     if ~isempty(strfind(ff(i+1).name,'sal'))
%         startpt = '';
%     else
%         drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
%         startpt = (drugtime+latency)*3600;%change latency time
%     end
%     
%     if excludewashin == 1 & ~isempty(startpt)
%         ind = find(tb_cond < startpt);
%         motifcond(ind) = [];
%     end
% 
%     if ~isempty(matchtm)
%         indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
%         motifsal = motifsal(indsal);
%     end 
%     
%     for ii = 1:length(motifcond)
%         [ons offs] = SegmentNotes(motifcond(ii).logsm,fs,min_int,min_dur,th);
%         if length(ons)~= length(motif)
%             continue
%         end
%         for p = 1:length(ons)
%             if length(motifcond(ii).sm) < ceil(offs(p)*fs)
%                 volcond{p,1,numtrial} = [volcond{p,1,numtrial}; ...
%                     mean(log10(motifcond(ii).sm(floor(ons(p)*fs):end)))];
%             else
%                 volcond{p,1,numtrial} = [volcond{p,1,numtrial};...
%                     mean(log10(motifcond(ii).sm(floor(ons(p)*fs):ceil(offs(p)*fs))))];
%             end
%         end
%     end
%     
% 
%     for ii = 1:length(motifsal)
%         [ons offs] = SegmentNotes(motifsal(ii).logsm,fs,min_int,min_dur,th);
%         if length(ons)~= length(motif)
%             continue
%         end
%         for p = 1:length(ons)
%             if length(motifsal(ii).sm) < ceil(offs(p)*fs)
%                 volsal{p,1,numtrial} = [volsal{p,1,numtrial}; ...
%                     mean(log10(motifsal(ii).sm(floor(ons(p)*fs):end)))];
%             else
%                 volsal{p,1,numtrial} = [volsal{p,1,numtrial}; ...
%                     mean(log10(motifsal(ii).sm(floor(ons(p)*fs):ceil(offs(p)*fs))))];
%             end
%         end
%     end
%     numtrial = numtrial+1;
% end
% 
% % plot distribution of volume measurements for each syllable between saline and NASPM
% minval = min([min(min(cellfun(@min,volsal)));min(min(cellfun(@min,volcond)))]);
% maxval = max([max(max(cellfun(@max,volsal)));max(max(cellfun(@max,volcond)))]);
% figure;hold on;
% for i = 1:length(motif)
%     h = subtightplot(1,length(motif),i,[0.08,0.04],0.2,0.05);hold on;
%        y = volcond(i,1,:);
%      y = cell2mat(y(:))
%      x = volsal(i,1,:);
%      x = cell2mat(x(:));
%      [n b] = hist(x,[minval:0.1:maxval]);
%      createPatches(b,n/sum(n),0.05,'k',0.5);
%      [n b] = hist(y,[minval:0.1:maxval]);
%      createPatches(b,n/sum(n),0.05,'r',0.5);
%      xlim(h,[minval maxval]);
%      xlabel(h,'volume (db)');
%     ylabel(h,'probability');
%     title(h,['Syllable ',num2str(i)]);
%     set(h,'fontweight','bold');
% end 
% 
% %correlate baseline volume with d' change in NASPM by syllable trials
% figure;hold on;
% subtightplot(1,2,1,0.08,0.15,0.1);hold on;
% volchange = (cellfun(@mean,volcond)-cellfun(@mean,volsal))./sqrt(0.5*(...
%     cellfun(@std,volsal).^2+cellfun(@std,volcond).^2));
% volchange = volchange(:);
% x = cellfun(@mean,volsal);
% x = x(:);
% plot(x,volchange,'ok','markersize',8);
% xlabel('volume (dB)');
% ylabel('d''');
% [r p] = corrcoef(x,volchange);
% str = {['r=',num2str(r(2))],['p=',num2str(p(2))]};
% title(str);
% set(gca,'fontweight','bold');
% 
% subtightplot(1,2,2,0.08,0.15,0.1);hold on;
% volchange = cellfun(@mean,volcond)-cellfun(@mean,volsal);
% volchange = volchange(:);
% plot(x,volchange,'ok','markersize',8);
% xlabel('volume (dB)');
% ylabel('absolute change in NASPM');
% [r p] = corrcoef(x,volchange);
% str = {['r=',num2str(r(2))],['p=',num2str(p(2))]};
% title(str);
% set(gca,'fontweight','bold');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ff = load_batchf('batchnaspm');
syllables = {'A','B','D'};
load('analysis/data_structures/naspmvolumelatency');
excludewashin = 1;
matchtm = 1;
latency = 1.13;
numtrials = length(ff)/4;
volsal = cell(length(syllables),1,numtrials);
volcond = cell(length(syllables),1,numtrials);
numtrial = 1;
for i = 1:4:length(ff)
    for ind = 1:length(syllables)
        load(['analysis/data_structures/fv_syll',syllables{ind},'_',ff(i).name]);
        load(['analysis/data_structures/fv_syll',syllables{ind},'_',ff(i+2).name]);

        fvsal = eval(['fv_syll',syllables{ind},'_',ff(i).name]);
        fvcond = eval(['fv_syll',syllables{ind},'_',ff(i+2).name]);
        
        tb_sal = jc_tb([fvsal(:).datenm]',7,0);
        tb_cond = jc_tb([fvcond(:).datenm]',7,0);

        if ~isempty(strfind(ff(i+2).name,'sal'))
            startpt = '';
        else
            drugtime = naspmvolumelatency.(['tr_',ff(i+2).name]).treattime;
            startpt = (drugtime+latency)*3600;%change latency time
        end

        if excludewashin == 1 & ~isempty(startpt)
            p = find(tb_cond < startpt);
            fvcond(p) = [];
        end

        if ~isempty(matchtm)
            indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
            fvsal = fvsal(indsal);
        end 

        for ii = 1:length(fvcond)
            volcond{ind,1,numtrial} =[volcond{ind,1,numtrial};mean(log10(fvcond(ii).sm))];
        end
        
        for ii = 1:length(fvsal)
            volsal{ind,1,numtrial} = [volsal{ind,1,numtrial};mean(log10(fvsal(ii).sm))];
        end
    end  
    numtrial = numtrial+1;
end

 % plot distribution of volume measurements for each syllable between saline and NASPM
 minval = min([min(min(cellfun(@min,volsal)));min(min(cellfun(@min,volcond)))]);
 maxval = max([max(max(cellfun(@max,volsal)));max(max(cellfun(@max,volcond)))]);
 figure;hold on;
 for i = 1:length(syllables)
     h = subtightplot(1,length(syllables),i,[0.08 0.05],0.2,0.05);hold on;
     y = volcond(i,1,:);
     y = cell2mat(y(:))
     x = volsal(i,1,:);
     x = cell2mat(x(:));
     [n b] = hist(x,[minval:0.1:maxval]);
     createPatches(b,n/sum(n),0.05,'k',0.5);
     [n b] = hist(y,[minval:0.1:maxval]);
     createPatches(b,n/sum(n),0.05,'r',0.5);
     xlabel(h,'volume (db)');
    ylabel(h,'probability');
    title(h,['Syllable ',num2str(i)]);
    set(h,'fontweight','bold');
 end
 
%correlate baseline volume with z-score change in NASPM
figure;hold on;
subtightplot(1,2,1,0.08,0.15,0.1);hold on;
volchange = (cellfun(@mean,volcond)-cellfun(@mean,volsal))./sqrt(0.5*(...
    cellfun(@std,volsal).^2+cellfun(@std,volcond).^2));
volchange = volchange(:);
x = cellfun(@mean,volsal);
x = x(:);
plot(x,volchange,'ok','markersize',8);
xlabel('volume (dB)');
ylabel('d''');
[r p] = corrcoef(x,volchange);
str = {['r=',num2str(r(2))],['p=',num2str(p(2))]};
title(str);
set(gca,'fontweight','bold');

subtightplot(1,2,2,0.08,0.15,0.1);hold on;
volchange = cellfun(@mean,volcond)-cellfun(@mean,volsal);
volchange = volchange(:);
plot(x,volchange,'ok','markersize',8);
xlabel('volume (dB)');
ylabel('absolute change in NASPM');
[r p] = corrcoef(x,volchange);
str = {['r=',num2str(r(2))],['p=',num2str(p(2))]};
title(str);
set(gca,'fontweight','bold');


