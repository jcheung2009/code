%DISTRIBUTION of singing rate by bird

ff = load_batchf('naspm_birds');

singrate = [];
singrate_sal = [];

for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['boutnaspm_',ff(i).name])
         x = eval(['boutnaspm_',ff(i).name]);
     elseif exist(['boutiem_',ff(i).name]) 
        x = eval(['boutiem_',ff(i).name]);
     end
     
     if exist(['boutsal_',ff(i).name])
         y = eval(['boutsal_',ff(i).name]);
     end

     singrate = [singrate; 100*(nanmean([x(:).singrate]')-1)];
     
     singrate_sal = [singrate_sal; 100*(nanmean([y(:).singrate]')-1)];
end
         
figure;hold on;
plot(repmat([0.5 1.5]',1,length(singrate)),[singrate_sal singrate]',...
    'marker','o','markersize',8,'linewidth',2);hold on;
plot([0 2],[0 0],'c','linewidth',2);hold on;
[p h stat] = signrank(singrate_sal,singrate);
str = {['peak singing rate'],['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
title(str);
xlim([0 2]);
legend(gca,{ff(:).name});
set(gca,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM'},'fontweight','bold');
ylabel('percent change');