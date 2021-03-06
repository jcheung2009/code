function [fighandle] = jc_plotrepeatlengthhistogram(fv_rep,mrk,maxlen,title1,fighandle)
%fv_rep is from jc_findrepeats

runlength = [fv_rep(:).runlength]';
if isempty(maxlen)
    maxlen = max([runlength]);
end
if ~isempty(fighandle)
    figure(fighandle);hold on;;
else
    fighandle = figure;hold on;
end
[n b] = hist(runlength,[1:maxlen]);
stairs(b,n/sum(n),mrk,'linewidth',2);hold on;
xlabel('Repeat length (number of syllables)','FontWeight','bold')
ylabel('Probability','FontWeight','bold');
title(title1,'interpreter','none');
xlim([1 maxlen]);
set(gca,'fontweight','bold');
y = get(gca,'ylim');
plot(mean(runlength),y(1),'^','color',mrk,'linewidth',2);hold on;

