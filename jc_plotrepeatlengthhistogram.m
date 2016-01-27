function [fstat tstat] = jc_plotrepeatlengthhistogram(fv_rep_sal, fv_rep_cond,matchtime,fighandle)
%fv_rep is from jc_findrepeat2
%matches time in condition and saline

tb_sal = jc_tb([fv_rep_sal(:).datenm]',7,0);
tb_cond = jc_tb([fv_rep_cond(:).datenm]',7,0);

if matchtime == 'y'
    ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
    runlength1 = [fv_rep_sal(ind).runlength]';
    runlength2 = [fv_rep_cond(:).runlength]';
else
    ind = find(tb_cond > tb_sal(end)+1800); %exclude first half hour of wash in
    runlength1 = [fv_rep_sal(:).runlength]';
    runlength2 = [fv_rep_cond(ind).runlength]';
end


maxlength = max([runlength1; runlength2]);
if ~isempty(fighandle)
    hold(fighandle,'on');
else
    figure;hold on;
end
[n b] = hist(runlength1,[1:maxlength]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(runlength2,[1:maxlength]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
%createPatches(b,n/sum(n),0.5,linecolor,0.5);
%h = findobj(gca,'Type','patch');set(h,'edgecolor','none');
%bar(b,n/sum(n),1,'edgecolor','none','facecolor',linecolor);
%h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);
[h p1 ci tstat] = ttest2(runlength1,runlength2);
[h p2 ci fstat] = vartest2(runlength1,runlength2);
xlabel('Repeat length (number of syllables)','FontWeight','bold')
ylabel('Probability','FontWeight','bold');
title('Probability distribution of repeat length');
xlim([1 maxlength]);
set(gca,'fontweight','bold');

str = {['tstat = ',num2str(tstat.tstat),' ; p = ',num2str(p1)], ...
    ['fstat = ',num2str(fstat.fstat),' ; p = ',num2str(p2)]}
annotation('textbox',[0.5 0.8 .1 .1],'String',str);

