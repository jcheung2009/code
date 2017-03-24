%pairwise correlation across birds, each point = repeat trial (if no spec
%measurements for repeat syllable, use average effects of other syllables
%in song) 

ff = load_batchf('naspm_birds');

replen_fv = [];
replen_vol = [];
replen_ent = [];
replen_pcv = [];

repacorr_fv = [];
repacorr_vol = [];
repacorr_ent = [];
repacorr_pcv = [];

repsdur_fv = [];
repsdur_vol = [];
repsdur_ent = [];
repsdur_pcv = [];

repgdur_fv = [];
repgdur_vol = [];
repgdur_ent = [];
repgdur_pcv = [];

replen_fv_sal = [];
replen_vol_sal = [];
replen_ent_sal = [];
replen_pcv_sal = [];

repacorr_fv_sal = [];
repacorr_vol_sal = [];
repacorr_ent_sal = [];
repacorr_pcv_sal = [];

repsdur_fv_sal = [];
repsdur_vol_sal = [];
repsdur_ent_sal = [];
repsdur_pcv_sal = [];

repgdur_fv_sal = [];
repgdur_vol_sal = [];
repgdur_ent_sal = [];
repgdur_pcv_sal = [];

for i = 1:length(ff)
     load([ff(i).name,'/analysis/data_structures/summary']);
     
     if exist(['repnaspm_',ff(i).name])
         x = eval(['repnaspm_',ff(i).name]);
     elseif exist(['repiem_',ff(i).name]) 
        x = eval(['repiem_',ff(i).name]);
     else
         continue
     end
     
      if exist(['fvnaspm_',ff(i).name])
         x2 = eval(['fvnaspm_',ff(i).name]);
     elseif exist(['fviem_',ff(i).name]) 
        x2 = eval(['fviem_',ff(i).name]);
     end
     
     if exist(['fvsal_',ff(i).name])
         y2 = eval(['fvsal_',ff(i).name]);
     end
     
     if exist(['repsal_',ff(i).name])
         y = eval(['repsal_',ff(i).name]);
     end
     
    repeats = fieldnames(x);
    syllables = fieldnames(x2); 
    for ii = 1:length(repeats)
        xdata = [x(:).([repeats{ii}])];
        ydata = [y(:).([repeats{ii}])];
        
        if all(cellfun(@isempty,strfind(syllables,repeats{ii}))) == 0 %syllable in repeat is present in fv
            x2data = [x2(:).(['syll',repeats{ii}])];
            y2data = [y2(:).(['syll',repeats{ii}])];
            
            replen_fv = [replen_fv;[[xdata(:).rep]' [x2data(:).fv]']];
            replen_vol = [replen_vol;[[xdata(:).rep]' [x2data(:).vol]']];
            replen_ent = [replen_ent;[[xdata(:).rep]' [x2data(:).ent]']];
            replen_pcv = [replen_pcv;[[xdata(:).rep]' [x2data(:).pcv]'-1]];
            
            replen_fv_sal = [replen_fv_sal;[[ydata(:).rep]' [y2data(:).fv]']];
            replen_vol_sal = [replen_vol_sal;[[ydata(:).rep]' [y2data(:).vol]']];
            replen_ent_sal = [replen_ent_sal;[[ydata(:).rep]' [y2data(:).ent]']];
            replen_pcv_sal = [replen_pcv_sal;[[ydata(:).rep]' [y2data(:).pcv]'-1]];
            
            repacorr_fv = [repacorr_fv;[[xdata(:).acorr]' [x2data(:).fv]']];
            repacorr_vol = [repacorr_vol;[[xdata(:).acorr]' [x2data(:).vol]']];
            repacorr_ent = [repacorr_ent;[[xdata(:).acorr]' [x2data(:).ent]']];
            repacorr_pcv = [repacorr_pcv;[[xdata(:).acorr]' [x2data(:).pcv]'-1]];
            
            repacorr_fv_sal = [repacorr_fv_sal;[[ydata(:).acorr]' [y2data(:).fv]']];
            repacorr_vol_sal = [repacorr_vol_sal;[[ydata(:).acorr]' [y2data(:).vol]']];
            repacorr_ent_sal = [repacorr_ent_sal;[[ydata(:).acorr]' [y2data(:).ent]']];
            repacorr_pcv_sal = [repacorr_pcv_sal;[[ydata(:).acorr]' [y2data(:).pcv]'-1]];
            
            repsdur_fv = [repsdur_fv;[[xdata(:).sdur]' [x2data(:).fv]']];
            repsdur_vol = [repsdur_vol;[[xdata(:).sdur]' [x2data(:).vol]']];
            repsdur_ent = [repsdur_ent;[[xdata(:).sdur]' [x2data(:).ent]']];
            repsdur_pcv = [repsdur_pcv;[[xdata(:).sdur]' [x2data(:).pcv]'-1]];
            
            repsdur_fv_sal = [repsdur_fv_sal;[[ydata(:).sdur]' [y2data(:).fv]']];
            repsdur_vol_sal = [repsdur_vol_sal;[[ydata(:).sdur]' [y2data(:).vol]']];
            repsdur_ent_sal = [repsdur_ent_sal;[[ydata(:).sdur]' [y2data(:).ent]']];
            repsdur_pcv_sal = [repsdur_pcv_sal;[[ydata(:).sdur]' [y2data(:).pcv]'-1]];
            
            repgdur_fv = [repgdur_fv;[[xdata(:).gdur]' [x2data(:).fv]']];
            repgdur_vol = [repgdur_vol;[[xdata(:).gdur]' [x2data(:).vol]']];
            repgdur_ent = [repgdur_ent;[[xdata(:).gdur]' [x2data(:).ent]']];
            repgdur_pcv = [repgdur_pcv;[[xdata(:).gdur]' [x2data(:).pcv]'-1]];
            
            repgdur_fv_sal = [repgdur_fv_sal;[[ydata(:).gdur]' [y2data(:).fv]']];
            repgdur_vol_sal = [repgdur_vol_sal;[[ydata(:).gdur]' [y2data(:).vol]']];
            repgdur_ent_sal = [repgdur_ent_sal;[[ydata(:).gdur]' [y2data(:).ent]']];
            repgdur_pcv_sal = [repgdur_pcv_sal;[[ydata(:).gdur]' [y2data(:).pcv]'-1]];
        else
            fv = [];vol = [];ent = [];pcv = [];
            for m = 1:length(x2)
                x2data = x2(m);
                fv = [fv; nanmean(structfun(@(x) x.fv,x2data))];
                vol = [vol; nanmean(structfun(@(x) x.vol,x2data))];
                ent = [ent; nanmean(structfun(@(x) x.ent,x2data))];
                pcv = [pcv; nanmean(structfun(@(x) x.pcv,x2data))-1];
            end
            
            fv_sal = [];vol_sal = [];ent_sal = [];pcv_sal = [];
            for m = 1:length(y2)
                y2data = y2(m);
                fv_sal = [fv_sal; nanmean(structfun(@(x) x.fv,y2data))];
                vol_sal = [vol_sal; nanmean(structfun(@(x) x.vol,y2data))];
                ent_sal = [ent_sal; nanmean(structfun(@(x) x.ent,y2data))];
                pcv_sal = [pcv_sal; nanmean(structfun(@(x) x.pcv,y2data))-1];
            end
            
            replen_fv = [replen_fv;[[xdata(:).rep]' fv]];
            replen_vol = [replen_vol;[[xdata(:).rep]' vol]];
            replen_ent = [replen_ent;[[xdata(:).rep]' ent]];
            replen_pcv = [replen_pcv;[[xdata(:).rep]' pcv]];
            
            replen_fv_sal = [replen_fv_sal;[[ydata(:).rep]' fv_sal]];
            replen_vol_sal = [replen_vol_sal;[[ydata(:).rep]' vol_sal]];
            replen_ent_sal = [replen_ent_sal;[[ydata(:).rep]' ent_sal]];
            replen_pcv_sal = [replen_pcv_sal;[[ydata(:).rep]' pcv_sal]];
            
            repacorr_fv = [repacorr_fv;[[xdata(:).acorr]' fv]];
            repacorr_vol = [repacorr_vol;[[xdata(:).acorr]' vol]];
            repacorr_ent = [repacorr_ent;[[xdata(:).acorr]' ent]];
            repacorr_pcv = [repacorr_pcv;[[xdata(:).acorr]' pcv]];
            
            repacorr_fv_sal = [repacorr_fv_sal;[[ydata(:).acorr]' fv_sal]];
            repacorr_vol_sal = [repacorr_vol_sal;[[ydata(:).acorr]' vol_sal]];
            repacorr_ent_sal = [repacorr_ent_sal;[[ydata(:).acorr]' ent_sal]];
            repacorr_pcv_sal = [repacorr_pcv_sal;[[ydata(:).acorr]' pcv_sal]];
            
            repsdur_fv = [repsdur_fv;[[xdata(:).sdur]' fv]];
            repsdur_vol = [repsdur_vol;[[xdata(:).sdur]' vol]];
            repsdur_ent = [repsdur_ent;[[xdata(:).sdur]' ent]];
            repsdur_pcv = [repsdur_pcv;[[xdata(:).sdur]' pcv]];
            
            repsdur_fv_sal = [repsdur_fv_sal;[[ydata(:).sdur]' fv_sal]];
            repsdur_vol_sal = [repsdur_vol_sal;[[ydata(:).sdur]' vol_sal]];
            repsdur_ent_sal = [repsdur_ent_sal;[[ydata(:).sdur]' ent_sal]];
            repsdur_pcv_sal = [repsdur_pcv_sal;[[ydata(:).sdur]' pcv_sal]];
            
            repgdur_fv = [repgdur_fv;[[xdata(:).gdur]' fv]];
            repgdur_vol = [repgdur_vol;[[xdata(:).gdur]' vol]];
            repgdur_ent = [repgdur_ent;[[xdata(:).gdur]' ent]];
            repgdur_pcv = [repgdur_pcv;[[xdata(:).gdur]' pcv]];
            
            repgdur_fv_sal = [repgdur_fv_sal;[[ydata(:).gdur]' fv_sal]];
            repgdur_vol_sal = [repgdur_vol_sal;[[ydata(:).gdur]' vol_sal]];
            repgdur_ent_sal = [repgdur_ent_sal;[[ydata(:).gdur]' ent_sal]];
            repgdur_pcv_sal = [repgdur_pcv_sal;[[ydata(:).gdur]' pcv_sal]];
                
        end   

    end
    
end

figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,replen_fv(:,1),replen_fv(:,2),'or','markersize',8);
[r p] = corrcoef(replen_fv(:,1),replen_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'repeat length');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,replen_vol(:,1),replen_vol(:,2),'or','markersize',8);
[r p] = corrcoef(replen_vol(:,1),replen_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'repeat length');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,replen_ent(:,1),replen_ent(:,2),'or','markersize',8);
[r p] = corrcoef(replen_ent(:,1),replen_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'repeat length');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,replen_pcv(:,1),replen_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(replen_pcv(:,1),replen_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'repeat length');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,replen_fv_sal(:,1),replen_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(replen_fv_sal(:,1),replen_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'repeat length');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,replen_vol_sal(:,1),replen_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(replen_vol_sal(:,1),replen_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'repeat length');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,replen_ent_sal(:,1),replen_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(replen_ent_sal(:,1),replen_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'repeat length');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,replen_pcv_sal(:,1),replen_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(replen_pcv_sal(:,1),replen_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'repeat length');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,repacorr_fv(:,1),repacorr_fv(:,2),'or','markersize',8);
[r p] = corrcoef(repacorr_fv(:,1),repacorr_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'repeat acorr');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,repacorr_vol(:,1),repacorr_vol(:,2),'or','markersize',8);
[r p] = corrcoef(repacorr_vol(:,1),repacorr_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'repeat acorr');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,repacorr_ent(:,1),repacorr_ent(:,2),'or','markersize',8);
[r p] = corrcoef(repacorr_ent(:,1),repacorr_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'repeat acorr');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,repacorr_pcv(:,1),repacorr_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(repacorr_pcv(:,1),repacorr_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'repeat acorr');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,repacorr_fv_sal(:,1),repacorr_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repacorr_fv_sal(:,1),repacorr_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'repeat acorr');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,repacorr_vol_sal(:,1),repacorr_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repacorr_vol_sal(:,1),repacorr_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'repeat acorr');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,repacorr_ent_sal(:,1),repacorr_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repacorr_ent_sal(:,1),repacorr_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'repeat acorr');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,repacorr_pcv_sal(:,1),repacorr_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repacorr_pcv_sal(:,1),repacorr_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'repeat acorr');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,repsdur_fv(:,1),repsdur_fv(:,2),'or','markersize',8);
[r p] = corrcoef(repsdur_fv(:,1),repsdur_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'repeat syll dur');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,repsdur_vol(:,1),repsdur_vol(:,2),'or','markersize',8);
[r p] = corrcoef(repsdur_vol(:,1),repsdur_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'repeat syll dur');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,repsdur_ent(:,1),repsdur_ent(:,2),'or','markersize',8);
[r p] = corrcoef(repsdur_ent(:,1),repsdur_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'repeat syll dur');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,repsdur_pcv(:,1),repsdur_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(repsdur_pcv(:,1),repsdur_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'repeat syll dur');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,repsdur_fv_sal(:,1),repsdur_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repsdur_fv_sal(:,1),repsdur_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'repeat syll dur');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,repsdur_vol_sal(:,1),repsdur_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repsdur_vol_sal(:,1),repsdur_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'repeat syll dur');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,repsdur_ent_sal(:,1),repsdur_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repsdur_ent_sal(:,1),repsdur_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'repeat syll dur');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,repsdur_pcv_sal(:,1),repsdur_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repsdur_pcv_sal(:,1),repsdur_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'repeat syll dur');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(2,4,1,[0.15 0.05],0.08,0.08);
plot(h1,repgdur_fv(:,1),repgdur_fv(:,2),'or','markersize',8);
[r p] = corrcoef(repgdur_fv(:,1),repgdur_fv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h1,str);
xlabel(h1,'repeat gap dur');
ylabel(h1,'pitch');
set(h1,'fontweight','bold');

h2 = subtightplot(2,4,2,[0.15 0.05],0.08,0.08);
plot(h2,repgdur_vol(:,1),repgdur_vol(:,2),'or','markersize',8);
[r p] = corrcoef(repgdur_vol(:,1),repgdur_vol(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h2,str);
xlabel(h2,'repeat gap dur');
ylabel(h2,'volume');
set(h2,'fontweight','bold')

h3 = subtightplot(2,4,3,[0.15 0.05],0.08,0.08);
plot(h3,repgdur_ent(:,1),repgdur_ent(:,2),'or','markersize',8);
[r p] = corrcoef(repgdur_ent(:,1),repgdur_ent(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h3,str);
xlabel(h3,'repeat gap dur');
ylabel(h3,'entropy');
set(h3,'fontweight','bold');

h4 = subtightplot(2,4,4,[0.15 0.05],0.08,0.08);
plot(h4,repgdur_pcv(:,1),repgdur_pcv(:,2),'or','markersize',8);
[r p] = corrcoef(repgdur_pcv(:,1),repgdur_pcv(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h4,str);
xlabel(h4,'repeat gap dur');
ylabel(h4,'pitch cv');
set(h4,'fontweight','bold');

h5 = subtightplot(2,4,5,[0.15 0.05],0.08,0.08);
plot(h5,repgdur_fv_sal(:,1),repgdur_fv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repgdur_fv_sal(:,1),repgdur_fv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h5,str);
xlabel(h5,'repeat gap dur');
ylabel(h5,'pitch');
set(h5,'fontweight','bold');

h6 = subtightplot(2,4,6,[0.15 0.05],0.08,0.08);
plot(h6,repgdur_vol_sal(:,1),repgdur_vol_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repgdur_vol_sal(:,1),repgdur_vol_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h6,str);
xlabel(h6,'repeat gap dur');
ylabel(h6,'volume');
set(h6,'fontweight','bold');

h7 = subtightplot(2,4,7,[0.15 0.05],0.08,0.08);
plot(h7,repgdur_ent_sal(:,1),repgdur_ent_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repgdur_ent_sal(:,1),repgdur_ent_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h7,str);
xlabel(h7,'repeat gap dur');
ylabel(h7,'entropy');
set(h7,'fontweight','bold');

h8 = subtightplot(2,4,8,[0.15 0.05],0.08,0.08);
plot(h8,repgdur_pcv_sal(:,1),repgdur_pcv_sal(:,2),'ok','markersize',8);
[r p] = corrcoef(repgdur_pcv_sal(:,1),repgdur_pcv_sal(:,2));
str = {['r = ',num2str(r(2)),' ; p = ',num2str(p(2))]};
title(h8,str);
xlabel(h8,'repeat gap dur');
ylabel(h8,'pitch cv');
set(h8,'fontweight','bold');

