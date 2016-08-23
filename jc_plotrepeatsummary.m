function [rep sdur gdur temp] = jc_plotrepeatsummary(fv_rep_sal,fv_rep_cond,...
    marker,linecolor,xpt,excludewashin,startpt,matchtm,checkoutliers,fignum)
%plots summary data for changes in repeat length, gap duration, and
%syllable duration for target repeat
%gap durations and syllable durations are matched by repeat position before
%normalizing 
%for saline morn vs drug noon



tb_sal = jc_tb([fv_rep_sal(:).datenm]',7,0);
tb_cond = jc_tb([fv_rep_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    tb_cond(ind) = [];
    fv_rep_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    fv_rep_cond(ind) = [];
    tb_cond(ind) = [];
end

runlength = [fv_rep_sal(:).runlength];
runlength2 = [fv_rep_cond(:).runlength];
acorr = [fv_rep_sal(:).firstpeakdistance];
acorr2 = [fv_rep_cond(:).firstpeakdistance];
gapdur = arrayfun(@(x) mean(x.syllgaps),fv_rep_sal)';
gapdur2 = arrayfun(@(x) mean(x.syllgaps),fv_rep_cond)';
sylldur = arrayfun(@(x) mean(x.sylldurations),fv_rep_sal)';
sylldur2 = arrayfun(@(x) mean(x.sylldurations),fv_rep_cond)';

if matchtm==1
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    tb_sal = tb_sal(indsal);
    runlength = runlength(indsal);
    acorr = acorr(indsal);
    gapdur = gapdur(indsal);
    sylldur = sylldur(indsal);
end 

if checkoutliers == 'y'
    nstd = 4;
    acorr = jc_removeoutliers(acorr,nstd);
    acorr2 = jc_removeoutliers(acorr2,nstd);
    gapdur = jc_removeoutliers(gapdur,nstd);
    gapdur2 = jc_removeoutliers(gapdur2,nstd);
    sylldur = jc_removeoutliers(sylldur,nstd);
    sylldur2 = jc_removeoutliers(sylldur2,nstd);
end

if ~isempty(find(isnan(acorr)))
    removeind = find(isnan(acorr));
    acorr(removeind) = [];
elseif ~isempty(find(isnan(gapdur)))
    removeind = find(isnan(gapdur));
    gapdur(removeind) = [];
elseif ~isempty(find(isnan(sylldur)))
    removeind = find(isnan(sylldur));
    sylldur(removeind) = [];
end
if ~isempty(find(isnan(acorr2)))
    removeind = find(isnan(acorr2));
    acorr2(removeind) = [];
elseif ~isempty(find(isnan(gapdur2)))
    removeind = find(isnan(gapdur2));
    gapdur2(removeind) = [];
elseif ~isempty(find(isnan(sylldur2)))
    removeind = find(isnan(sylldur2));
    sylldur2(removeind) = [];
end

% gapdur = [];
% sylldur = [];
% for i = 1:length(fv_rep_sal)
%     gapdur = [gapdur; [1:length(fv_rep_sal(i).syllgaps)]' fv_rep_sal(i).syllgaps];%repeat position and duration of gap
%     sylldur = [sylldur; [1:length(fv_rep_sal(i).sylldurations)]' fv_rep_sal(i).sylldurations];
% end
% gapdur2 = [];
% sylldur2 = [];
% for i = 1:length(fv_rep_cond)
%     gapdur2 = [gapdur2; [1:length(fv_rep_cond(i).syllgaps)]' fv_rep_cond(i).syllgaps];
%     sylldur2 = [sylldur2; [1:length(fv_rep_cond(i).sylldurations)]' fv_rep_cond(i).sylldurations];
% end

% if checkoutliers == 'y'
%     fignum = input('figure number for checking outliers:');
%     figure(fignum);
%     h = plot(1,gapdur(:,2),'k.');
%     removeoutliers = input('remove outliers (y/n):','s');
%     while removeoutliers == 'y'
%         nstd = input('nstd:');
%         delete(h);
%         removeind = jc_findoutliers(gapdur(:,2),nstd);
%         gapdur(removeind,:) = [];
%         plot(1,gapdur(:,2),'k.');
%         removeoutliers = input('remove outliers (y/n):','s');
%     end
%     delete(h);
% 
%     h = plot(1,sylldur(:,2),'k.');
%     removeoutliers = input('remove outliers (y/n):','s');
%     while removeoutliers == 'y'
%         nstd = input('nstd:');
%         delete(h);
%         removeind = jc_findoutliers(sylldur(:,2),nstd);
%         sylldur(removeind,:) = [];
%         plot(1,sylldur(:,2),'k.');
%         removeoutliers = input('remove outliers (y/n):','s');
%     end
%     delete(h);
% 
%     h = plot(1,gapdur2(:,2),'k.');
%     removeoutliers = input('remove outliers (y/n):','s');
%     while removeoutliers == 'y'
%         nstd = input('nstd:');
%         delete(h);
%         removeind = jc_findoutliers(gapdur2(:,2),nstd);
%         gapdur2(removeind,:) = [];
%         plot(1,gapdur2(:,2),'k.');
%         removeoutliers = input('remove outliers (y/n):','s');
%     end
%     delete(h);
% 
%     h = plot(1,sylldur2(:,2),'k.');
%     removeoutliers = input('remove outliers (y/n):','s');
%     while removeoutliers == 'y'
%         nstd = input('nstd:');
%         delete(h);
%         removeind = jc_findoutliers(sylldur2(:,2),nstd);
%         sylldur2(removeind,:) = [];
%         plot(1,sylldur2(:,2),'k.');
%         removeoutliers = input('remove outliers (y/n):','s');
%     end
%     delete(h);
% end

%% normalize gap and syllable durations by repeat position 
% maxlength = max([runlength';runlength2']);
% for i = 1:maxlength
%     ind = find(gapdur(:,1)==i);
%     ind2 = find(gapdur2(:,1)==i);
% %     if length(ind) < 20 | length(ind2) < 20
% %          gapdur(ind,:) = [];
% %          gapdur2(ind2,:) = [];
% %          continue
% %     end
%     if ~isempty(ind)
%         salmn = mean(gapdur(ind,2));
%         gapdur(ind,2) = gapdur(ind,2)/salmn;
%         gapdur2(ind2,2) = gapdur2(ind2,2)/salmn;
%     else
%         gapdur(ind,:) = [];
%         gapdur2(ind2,:) = [];
%     end
% end
% for i = 1:maxlength
%     ind = find(sylldur(:,1)==i);
%     ind2 = find(sylldur2(:,1)==i);
% %     if length(ind) < 20 | length(ind2) < 20
% %         sylldur(ind,:) = [];
% %         sylldur2(ind2,:) = [];
% %         continue
% %     end
%     if ~isempty(ind)
%         salmn = mean(sylldur(ind,2));
%         sylldur(ind,2) = sylldur(ind,2)/salmn;
%         sylldur2(ind2,2) = sylldur2(ind2,2)/salmn;
%     else
%         sylldur(ind,:) = [];
%         sylldur2(ind2,:) = [];
%     end
% end
%% 
%% 

figure(fignum);
%z-score
runlengthn = (runlength2-mean(runlength))./std(runlength);
acorrn = (acorr2-nanmean(acorr))./nanstd(acorr);
gapdurn = (gapdur2-nanmean(gapdur))./nanstd(gapdur);
sylldurn = (sylldur2-nanmean(sylldur))./nanstd(sylldur);

subtightplot(4,1,1,0.07,0.08,0.15);hold on;
[hi lo mn2] = mBootstrapCI(runlengthn);
jitter = (-1+2*rand)/20;
xpt = xpt+jitter;
plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0 3],[0 0],'c','linewidth',2);
    set(gca,'xlim',[0 3],'xtick',[0.5,1.5 2.5],'xticklabel',...
        {'saline','iem','iem+apv'},'fontweight','bold');
ylabel('z-score');
title('Change in repeat length');
rep.zsc = mn2;

subtightplot(4,1,2,0.07,0.08,0.15);hold on;
[hi lo mn2] = mBootstrapCI(gapdurn);
plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
plot([0 3],[0 0],'c','linewidth',2);
    set(gca,'xlim',[0 3],'xtick',[0.5,1.5 2.5],'xticklabel',...
        {'saline','iem','iem+apv'},'fontweight','bold');
ylabel('z-score');
title('Change in gap duration');
 gdur.zsc = mn2;
 
subtightplot(4,1,3,0.07,0.08,0.15);hold on;
[hi lo mn2] = mBootstrapCI(sylldurn);
plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
 plot([0 3],[0 0],'c','linewidth',2);
    set(gca,'xlim',[0 3],'xtick',[0.5,1.5 2.5],'xticklabel',...
        {'saline','iem','iem+apv'},'fontweight','bold');
ylabel('z-score');
title('Change in syllable duration');
 sdur.zsc = mn2;
 
subtightplot(4,1,4,0.07,0.08,0.15);hold on;
 [hi lo mn2] = mBootstrapCI(acorrn);
plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
 plot([0 3],[0 0],'c','linewidth',2);
    set(gca,'xlim',[0 3],'xtick',[0.5,1.5 2.5],'xticklabel',...
        {'saline','iem','iem+apv'},'fontweight','bold');
ylabel('z-score');
title('Change in tempo');
temp.zsc = mn2;

%absolute values
rep.abs = mean(runlength2)-mean(runlength);
gdur.abs = nanmean(gapdur2)-nanmean(gapdur);
sdur.abs = nanmean(sylldur2)-nanmean(sylldur);
temp.abs = nanmean(acorr2)-nanmean(acorr);

%relative values
runlength2 = runlength2/nanmean(runlength);
gapdur2 = gapdur2/nanmean(gapdur);
sylldur2 = sylldur2/nanmean(sylldur);
acorr2 = acorr2/nanmean(acorr);

rep.rel = nanmean(runlength2);
gdur.rel = nanmean(gapdur2);
sdur.rel = nanmean(sylldur2);
temp.rel = nanmean(acorr2);


 
