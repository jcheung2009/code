%DISTRIBUTION of average singing rate by bird 

ff = load_batchf('naspm_birds');

singrate = [];
singrate_sal = [];
lname = {};
for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     x = eval(['meansingingrate']);

     if ~isempty(strfind(cell2mat(fieldnames(x)'),'naspm'));
         singrate = [singrate; x.naspm];
         singrate_sal = [singrate_sal; x.saline];
         lname = [lname; ff(i).name];
     else
         continue
     end
     
end
         
figure;hold on;
plot(repmat([0.5 1.5]',1,length(singrate)),[singrate_sal singrate]',...
    'marker','o','markersize',8,'linewidth',2);hold on;
[p h stat] = signrank(singrate_sal,singrate);
str = {['stat = ',num2str(stat.signedrank)],['p = ',num2str(p)]};
title(str);
xlim([0 2]);
legend(gca,lname);
set(gca,'xtick',[0.5 1.5],'xticklabel',{'saline','NASPM only'},'fontweight','bold');
ylabel({'Average singing rate', '(number of songs/half hour)'});