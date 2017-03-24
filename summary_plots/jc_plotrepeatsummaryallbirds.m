function jc_plotrepeatsummaryallbirds(fvrep_sal,fvrep_cond,marker,linecolor)

jitter = (-1+2*rand)/20;
xpt1 = 0.5 + jitter;
xpt2 = .75+jitter;

fignum = input('figure number:');
figure(fignum);hold on;
%subtightplot(3,1,1,0.07,0.08,0.15);hold on;
mn1 = mean([fvrep_sal(:).rep]');
err = stderr([fvrep_sal(:).rep]');
plot(xpt1,mn1,'ko',[xpt1 xpt1],[mn1+err mn1-err],'k','linewidth',2,'markersize',10);
mn2 = mean([fvrep_cond(:).rep]');
err = stderr([fvrep_cond(:).rep]');
plot(xpt2,mn2,marker,[xpt2 xpt2],[mn2+err mn2-err],linecolor,'linewidth',2,'markersize',10);
plot([xpt1 xpt2],[mn1 mn2],'color',[.5 .5 .5],'linewidth',2);
set(gca,'xlim',[0.45 .85],'xtick',[0.5 .75],'xticklabel',{'saline','NASPM'});
ylabel('Relative Change');
