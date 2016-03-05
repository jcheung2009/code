%plot absolute values of pitch, volume, entropy, pitch cv against changes
%(z-scores) under NASPM

ff = load_batchf('naspm_birds');
figure;hold on;
h1 = subtightplot(4,1,1,[0.1 0.08],0.08,0.3);
h2 = subtightplot(4,1,2,[0.1 0.08],0.08,0.3);
h3 = subtightplot(4,1,3,[0.1 0.08],0.08,0.3);
h4 = subtightplot(4,1,4,[0.1 0.08],0.08,0.3);
pitch = [];
vol = [];
ent = [];
pcv = [];
c = hsv(length(ff));
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/summary']);
    
    if exist(['fvnaspm_',ff(i).name])
         x = eval(['fvnaspm_',ff(i).name]);
     elseif exist(['fviem_',ff(i).name]) 
        x = eval(['fviem_',ff(i).name]);
    end
     
    syllables = fieldnames(x);
    cd(ff(i).name)
    fvsal = load_batchf('batchnaspm');
    fvsal = fvsal(1).name;
 
    for ii = 1:length(syllables)
        load(['analysis/data_structures/fv_',syllables{ii},'_',fvsal]);
        y = eval(['fv_',syllables{ii},'_',fvsal]);
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).fv];
        xdata = nanmean(100*([xdata(:).rel]));    
        pitch = [pitch; nanmean([y(:).mxvals]),xdata];
        axes(h1);hold on;
        plot(h1,nanmean([y(:).mxvals]),xdata,'o','color',c(i,:),'markersize',8,'DisplayName',ff(i).name);hold on;
        axes(h2);hold on;
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).vol];
        xdata = nanmean(100*([xdata(:).rel]));  
        vol = [vol; log10(nanmean([y(:).maxvol])) xdata];
        plot(h2,log10(nanmean([y(:).maxvol])),xdata,'o','color',c(i,:),'markersize',8,'DisplayName',ff(i).name);hold on;
        axes(h3);hold on;
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).ent];
        xdata = nanmean(100*([xdata(:).rel]));  
        ent = [ent; nanmean([y(:).spent]) xdata];
        plot(h3,nanmean([y(:).spent]),xdata,'o','color',c(i,:),'markersize',8,'DisplayName',ff(i).name);hold on;
        axes(h4);hold on;
        xdata = [x(:).([syllables{ii}])];
        xdata = 100*(nanmean([xdata(:).pcv])-1);
        pcv = [pcv; cv([y(:).mxvals]) xdata];
        plot(h4,cv([y(:).mxvals]),xdata,'o','color',c(i,:),'markersize',8,'DisplayName',ff(i).name);hold on;
    end
    cd ..
end

[r p] = corrcoef(pitch);
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'pitch (fv)');
ylabel(h1,'percent change');
set(h1,'fontweight','bold');
legend(h1,'show')

[r p] = corrcoef(vol);
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'volume');
ylabel(h2,'percent change');
set(h2,'fontweight','bold');

[r p] = corrcoef(ent);
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'entropy');
ylabel(h3,'percent change');
set(h3,'fontweight','bold');

[r p] = corrcoef(pcv);
str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'pitch cv');
ylabel(h4,'percent change');
set(h4,'fontweight','bold');
        
        
        