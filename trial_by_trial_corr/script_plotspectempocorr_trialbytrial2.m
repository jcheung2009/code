%plot every trial in saline vs naspm trial by trial corr of spec features 

birdname = 'o52o51';
load('analysis/data_structures/summary.mat');

x = eval(['spectempocorr_',birdname]);
syllables = fieldnames(x);
numtrials = length(x);
h1 = figure;%pitch vs volume
h2 = figure;%paired 
cnt = 1;
cmap = hsv(length(syllables));
h3 = [];
for i = 1:length(syllables)
    for ii = 1:numtrials
        set(0,'CurrentFigure',h1);
        ax = subtightplot(length(syllables),numtrials,cnt,[0.15 0.07],0.1,0.1);
        plot(ax,x(ii).([syllables{i}]).sal.abs(:,1),x(ii).([syllables{i}]).sal.abs(:,2),'ok');hold on;
        plot(ax,x(ii).([syllables{i}]).cond.abs(:,1),x(ii).([syllables{i}]).cond.abs(:,2),'or');hold on;
        xlabel(ax,'pitch (Hz)');
        ylabel(ax,'volume');
        set(ax,'fontweight','bold');
        str = [syllables{i},' trial ',num2str(ii)];
        title(ax,str);
        
        set(0,'CurrentFigure',h2);
        ax = gca;
        [r p] = corrcoef(x(ii).([syllables{i}]).sal.abs(:,1),x(ii).([syllables{i}]).sal.abs(:,2),'rows','complete');
        [r2 p2] = corrcoef(x(ii).([syllables{i}]).cond.abs(:,1),x(ii).([syllables{i}]).cond.abs(:,2),'rows','complete');
        if ii == 1
            h = plot(ax,[0.5 1.5],[r(2) r2(2)],'o-','markersize',8,'linewidth',2,'color',cmap(i,:));hold on;
            h3 = [h3 h];
        else
            plot(ax,[0.5 1.5],[r(2) r2(2)],'o-','markersize',8,'linewidth',2,'color',cmap(i,:));hold on;
        end
        
        cnt = cnt+1;
    end     
end

hold(ax,'on');
plot(ax,[0 2],[0 0],'c','linewidth',2);
xlim(ax,[0 2]);
ylabel('Correlation');
title(ax,'pitch vs volume');
legend(h3,syllables);
set(ax,'fontweight','bold','xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'});
        
        
        
