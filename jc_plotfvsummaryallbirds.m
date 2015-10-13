function jc_plotfvsummaryallbirds(fv_sal,fv_cond,marker,linecolor)
%takes the fvsummary structure from jc_plotfvsummary
jitter = (-1+2*rand)/20;
xpt1 = 0.5 + jitter;
xpt2 = 0.75+jitter;

fignum = input('figure number:');
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
mn1 = mean([fv_sal(:).fv]');
err = stderr([fv_sal(:).fv]');
plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
mn2 = mean([fv_cond(:).fv]');
err = stderr([fv_cond(:).fv]');
plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
set(gca,'xlim',[0 2],'xtick',[0.5 .75],'xticklabel',{'saline','NASPM'});
ylabel('Change relative to saline');

subtightplot(3,1,2,0.07,0.08,0.15);hold on;
mn1 = mean([fv_sal(:).vol]');
err = stderr([fv_sal(:).vol]');
plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
mn2 = mean([fv_cond(:).vol]');
err = stderr([fv_cond(:).vol]');
plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
set(gca,'xlim',[0 2],'xtick',[0.5 .75],'xticklabel',{'saline','NASPM'});
ylabel('Change relative to saline');

% subtightplot(4,1,3,0.07,0.08,0.15);hold on;
% mn1 = mean([fv_sal(:).ent]');
% err = stderr([fv_sal(:).ent]');
% plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
% mn2 = mean([fv_cond(:).ent]');
% err = stderr([fv_cond(:).ent]');
% plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
% plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
% set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'});
% ylabel('Change relative to saline');


subtightplot(3,1,3,0.07,0.08,0.15);hold on;
mn1 = mean([fv_sal(:).pcv]');
err = stderr([fv_sal(:).pcv]');
plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
mn2 = mean([fv_cond(:).pcv]');
err = stderr([fv_cond(:).pcv]');
plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
set(gca,'xlim',[0 2],'xtick',[0.5 .75],'xticklabel',{'saline','NASPM'});
ylabel('Change relative to saline');
