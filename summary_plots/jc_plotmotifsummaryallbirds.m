function jc_plotmotifsummaryallbirds(motif_sal, motif_cond,marker,linecolor)

jitter = (-1+2*rand)/20;
xpt1 = 0.5 + jitter;
xpt2 = .75+jitter;

fignum = input('figure number:');
figure(fignum);hold on;
%subtightplot(3,1,1,0.07,0.08,0.15);hold on;
mn1 = mean([motif_sal(:).mdur]');
err = stderr([motif_sal(:).mdur]');
plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
mn2 = mean([motif_cond(:).mdur]');
err = stderr([motif_cond(:).mdur]');
plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
set(gca,'xlim',[0.45 .85],'xtick',[0.5 .75],'xticklabel',{'saline','NASPM'});
ylabel('Relative Change');
% 
% subtightplot(3,1,2,0.07,0.08,0.15);hold on;
% mn1 = mean([motif_sal(:).sdur]');
% err = stderr([motif_sal(:).sdur]');
% plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
% mn2 = mean([motif_cond(:).sdur]');
% err = stderr([motif_cond(:).sdur]');
% plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
% plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
% set(gca,'xlim',[0.25 1],'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'});
% ylabel('Relative Change');
% 
% subtightplot(3,1,3,0.07,0.08,0.15);hold on;
% mn1 = mean([motif_sal(:).gdur]');
% err = stderr([motif_sal(:).gdur]');
% plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
% mn2 = mean([motif_cond(:).gdur]');
% err = stderr([motif_cond(:).gdur]');
% plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
% plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
% set(gca,'xlim',[0.25 1],'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'});
% ylabel('Relative Change');