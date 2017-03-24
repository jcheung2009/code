%takes the motifsummary structure from jc_plotmotifsummary
marker = 'k.';
linecolor = 'k';
fignum = input('figure number:');
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.07,0.1);hold on;
jitter = (-1+2*rand)/10;
xpt = 1.5 + jitter;
mn = mean([motif(:).mdur]');
err = stderr([motif(:).mdur]');
plot(xpt,mn,marker,[xpt xpt],[mn+err mn-err],linecolor,'linewidth',2,'markersize',15);
set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'NASPM','saline'});
ylabel('Motif duration change');
title('Change in motif duration relative to saline');

subtightplot(3,1,2,0.07,0.07,0.1);hold on;
mn = mean([motif(:).sdur]');
err = stderr([motif(:).sdur]');
plot(xpt,mn,marker,[xpt xpt],[mn+err mn-err],linecolor,'linewidth',2,'markersize',15);
set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'NASPM','saline'});
ylabel('Syllable duration change');
title('Change in syllable duration relative to saline');

subtightplot(3,1,3,0.07,0.07,0.1);hold on;
mn = mean([motif(:).gdur]');
err = stderr([motif(:).gdur]');
plot(xpt,mn,marker,[xpt xpt],[mn+err mn-err],linecolor,'linewidth',2,'markersize',15);
set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'NASPM','saline'});
ylabel('Gap duration change');
title('Change in gap duration relative to saline');

% subtightplot(4,1,4,0.07,0.07,0.1);hold on;
% mn = mean([motif(:).mcv]');
% err = stderr([motif(:).mcv]');
% plot(xpt,mn,marker,[xpt xpt],[mn+err mn-err],linecolor,'linewidth',2,'markersize',15);
% set(gca,'xlim',[0 2],'xtick',[0.5 1.5],'xticklabel',{'NASPM','saline'});
% ylabel('Pitch CV change');
% title('Change in pitch CV relative to saline');