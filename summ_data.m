function summ_data(b,normdata)
%summ_data(a,b,pitch1,pitch2, vol1, vol2, acorr1, acorr2, sm1,
%sm2,normdata)

% normdata is array col 1: sal, col 2: drug, row1: pitch, row2: vol, row3:
% motifdur, row4: fv_locs

% figure(a);hold on;
% subplot(4,1,1);
% plot(pitch1(:,1),pitch1(:,2),'k.'); hold on;
% plot(pitch2(:,1),pitch2(:,2),'r.');
% 
% subplot(4,1,2);
% plot(vol1(:,1),vol1(:,2),'k.'); hold on;
% plot(vol2(:,1),vol2(:,2),'r.');
% 
% subplot(4,1,3);
% plot(acorr1(:,1),mean(acorr1(:,2:end),2),'k'); hold on;
% plot(acorr1(:,1),mean(acorr1(:,2:end),2)+stderr(acorr1(:,2:end),2),'k'); hold on;
% plot(acorr1(:,1),mean(acorr1(:,2:end),2)-stderr(acorr1(:,2:end),2),'k'); hold on;
% plot(acorr2(:,1),mean(acorr2(:,2:end),2),'r'); hold on;
% plot(acorr2(:,1),mean(acorr2(:,2:end),2)+stderr(acorr2(:,2:end),2),'r'); hold on;
% plot(acorr2(:,1),mean(acorr2(:,2:end),2)-stderr(acorr2(:,2:end),2),'r'); 
% 
% subplot(4,1,4);
% plot(sm1(:,1),mean(sm1(:,2:end),2),'k'); hold on;
% plot(sm1(:,1),mean(sm1(:,2:end),2)+stderr(sm1(:,2:end),2),'k'); hold on;
% plot(sm1(:,1),mean(sm1(:,2:end),2)-stderr(sm1(:,2:end),2),'k'); hold on;
% plot(sm2(:,1),mean(sm2(:,2:end),2),'r'); hold on;
% plot(sm2(:,1),mean(sm2(:,2:end),2)+stderr(sm2(:,2:end),2),'r'); hold on;
% plot(sm2(:,1),mean(sm2(:,2:end),2)-stderr(sm2(:,2:end),2),'r'); 
% 
figure(b);hold on;

subplot(3,4,1);
errorbar(2,mean(normdata{1,1}),stderr(normdata{1,1}),'b.'); hold on;
errorbar(3,mean(normdata{1,2}),stderr(normdata{1,2}),'g.'); hold on;
plot([2,3],[mean(normdata{1,1}),mean(normdata{1,2})],'k');

figure(b);hold on;
subplot(3,4,2);
errorbar(2,mean(normdata{2,1}),stderr(normdata{2,1}),'b.'); hold on;
errorbar(3,mean(normdata{2,2}),stderr(normdata{2,2}),'g.'); hold on;
plot([2,3],[mean(normdata{2,1}),mean(normdata{2,2})],'k');
% % 
% figure(b);hold on;
% subplot(3,4,3);
% plot(1,cv(normdata{1,1})/cv(normdata{1,1}),'k.'); hold on;
% plot(2,cv(normdata{1,2})/cv(normdata{1,1}),'b.'); hold on;
% plot([1,2],[cv(normdata{1,1})/cv(normdata{1,1}),cv(normdata{1,2})/cv(normdata{1,1})], 'k');

figure(b);hold on;
subplot(3,4,4);
errorbar(2,nanmean(normdata{3,1}),nanstderr(normdata{3,1}),'b.');hold on;
errorbar(3,nanmean(normdata{3,2}),nanstderr(normdata{3,2}),'g.');hold on;
plot([2,3],[nanmean(normdata{3,1}),nanmean(normdata{3,2})],'k');

% figure(b);hold on;
% subplot(1,5,5);
% errorbar(1,mean(normdata{4,1}),stderr(normdata{4,1}),'k.');hold on;
% errorbar(2,mean(normdata{4,2}),stderr(normdata{4,2}),'r');hold on;
% plot([1,2],[mean(normdata{4,1}),mean(normdata{4,2})],'k');