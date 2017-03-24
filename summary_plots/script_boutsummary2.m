%takes the motifsummary structure from jc_plotmotifsummary
marker = 'k.';
linecolor = 'k';
fignum = input('figure number:');
figure(fignum);hold on;
jitter = (-1+2*rand)/10;
xpt = 1.5 + jitter;
mn = mean([bout(:).rate]');
err = stderr([bout(:).rate]');
plot(xpt,mn,marker,[xpt xpt],[mn+err mn-err],linecolor,'linewidth',2,'markersize',15);
set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'NASPM','saline'});
ylabel('Rate change');
title('Change in singing rate relative to saline');