function jc_plotrepeatlengthhistogram(fv_rep,linecolor)
%fv_rep is from jc_findrepeat2
runlength = [fv_rep(:).runlength]';
fignum = input('figure for histogram of repeat lengths:');
maxlength = input('maximum repeat length:');
figure(fignum);hold on;
[n b] = hist(runlength,[1:maxlength]);
stairs(b,n/sum(n),linecolor,'linewidth',2);hold on;
%createPatches(b,n/sum(n),0.5,linecolor,0.5);
%h = findobj(gca,'Type','patch');set(h,'edgecolor','none');
%bar(b,n/sum(n),1,'edgecolor','none','facecolor',linecolor);
%h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);
xlabel('Repeat length (number of syllables)')
ylabel('Probability');
title('Probability distribution of repeat length');

