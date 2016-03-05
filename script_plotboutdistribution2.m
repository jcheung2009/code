%DISTRIBUTION of singing rate by experiments

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

     singrate = [singrate; [x(:).singrate]'-1];
     
     singrate_sal = [singrate_sal; [y(:).singrate]'-1];
end
         
figure;hold on;
[n b] = hist(singrate_sal,[-1:0.2:5]);stairs(b,n/sum(n),'k','linewidth',2)
[n b] = hist(singrate,[-1:0.2:5]);stairs(b,n/sum(n),'r','linewidth',2)
ylimits = get(gca,'ylim');
plot(mean(singrate_sal),ylimits(2),'kV','markersize',8);
plot(mean(singrate),ylimits(2),'rV','markersize',8);
[h p1 ci tstat] = ttest2(singrate,singrate_sal);
str = {['tstat = ',num2str(tstat.tstat)],['p = ',num2str(p1)]};
text(0,0,str);


set(gca,'fontweight','bold');
ylabel('probability');
xlabel('percent change');
title('peak singing rate');
