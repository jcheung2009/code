%plot initial correlation with sign change

ff = load_batchf('naspm_birds');

figure;hold on;
ax = gca;
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/summary.mat']);
    
    x = eval(['spectempocorr_',ff(i).name]);
    syllables = fieldnames(x);
    numtrials = length(x);
    for ii = 1:length(syllables)
        for k = 1:numtrials
            [r p] = corrcoef(x(k).([syllables{ii}]).sal.abs(:,1),...
                x(k).([syllables{ii}]).sal.abs(:,2),'rows','complete');
            [r2 p2] = corrcoef(x(k).([syllables{ii}]).cond.abs(:,1),...
                x(k).([syllables{ii}]).cond.abs(:,2),'rows','complete');
            plot(ax,abs(r(2)),abs(r2(2)),'ok','markersize',8);

        end
    end
end

plot(ax,[-1 1],[0 0],'c',[0 0],[-1 1],'c','linewidth',2);
title(ax,'absolute value of pitch vs volume');
ylabel(ax,'NASPM correlation');
xlabel(ax,'initial correlation')
set(ax,'fontweight','bold');
          