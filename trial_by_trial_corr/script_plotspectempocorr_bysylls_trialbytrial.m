ff = load_batchf('naspm_birds');

pitch_acorr = [];pitch_acorr_sal = [];
pitch_sdur = [];pitch_sdur_sal = [];
pitch_g0dur = [];pitch_g0dur_sal = [];
pitch_g1dur = [];pitch_g1dur_sal = [];

vol_acorr = [];vol_acorr_sal = [];
vol_sdur = [];vol_sdur_sal = [];
vol_g0dur = [];vol_g0dur_sal = [];
vol_g1dur = [];vol_g1dur_sal = [];

ent_acorr = [];ent_acorr_sal = [];
ent_sdur = [];ent_sdur_sal = [];
ent_g0dur = [];ent_g0dur_sal = [];
ent_g1dur = [];ent_g1dur_sal = [];

pitch_vol = [];pitch_vol_sal = [];
pitch_ent = []; pitch_ent_sal = [];
vol_ent = []; vol_ent_sal = [];

acorr_sdur = []; acorr_sdur_sal = [];
acorr_g0dur = []; acorr_g0dur_sal = [];
acorr_g1dur = []; acorr_g1dur_sal = [];
sdur_g0dur = []; sdur_g0dur_sal = [];
sdur_g1dur = []; sdur_g1dur_sal = [];
cmap = [];
lname = {};
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/summary']);
    
    x = eval(['spectempocorr_',ff(i).name]);
    
    syllables = fieldnames(x);
    cmap = [cmap; repmat(rand(1,3),length(syllables),1)];
    for ii = 1:length(syllables)
        lname = [lname; {ff(i).name}];
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).cond];
        xdata = arrayfun(@(x) x.abs,xdata,'unif',0)';
        xdata = cell2mat(xdata);
        
        [r p] = corrcoef(xdata(:,1),xdata(:,4),'rows','complete');
        pitch_acorr = [pitch_acorr; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,1),xdata(:,5),'rows','complete');
        pitch_sdur = [pitch_sdur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,1),xdata(:,6),'rows','complete');
        pitch_g0dur = [pitch_g0dur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,1),xdata(:,7),'rows','complete');
        pitch_g1dur = [pitch_g1dur; [r(2) p(2)]];
        
        [r p] = corrcoef(xdata(:,2),xdata(:,4),'rows','complete');
        vol_acorr = [vol_acorr; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,2),xdata(:,5),'rows','complete');
        vol_sdur = [vol_sdur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,2),xdata(:,6),'rows','complete');
        vol_g0dur = [vol_g0dur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,2),xdata(:,7),'rows','complete');
        vol_g1dur = [vol_g1dur; [r(2) p(2)]];
        
        [r p] = corrcoef(xdata(:,3),xdata(:,4),'rows','complete');
        ent_acorr = [ent_acorr; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,3),xdata(:,5),'rows','complete');
        ent_sdur = [ent_sdur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,3),xdata(:,6),'rows','complete');
        ent_g0dur = [ent_g0dur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,3),xdata(:,7),'rows','complete');
        ent_g1dur = [ent_g1dur; [r(2) p(2)]];
        
        [r p] = corrcoef(xdata(:,1),xdata(:,2),'rows','complete');
        pitch_vol = [pitch_vol; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,1),xdata(:,3),'rows','complete');
        pitch_ent = [pitch_ent; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,2),xdata(:,3),'rows','complete');
        vol_ent = [vol_ent; [r(2) p(2)]];
       
        [r p] = corrcoef(xdata(:,4),xdata(:,5),'rows','complete');
        acorr_sdur = [acorr_sdur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,4),xdata(:,6),'rows','complete');
        acorr_g0dur = [acorr_g0dur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,4),xdata(:,7),'rows','complete');
        acorr_g1dur = [acorr_g1dur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,5),xdata(:,6),'rows','complete');
        sdur_g0dur = [sdur_g0dur; [r(2) p(2)]];
        [r p] = corrcoef(xdata(:,5),xdata(:,7),'rows','complete');
        sdur_g1dur = [sdur_g1dur; [r(2) p(2)]];
        
        ydata = [x(:).([syllables{ii}])];
        ydata = [ydata(:).sal];
        ydata = arrayfun(@(x) x.abs,ydata,'unif',0)';
        ydata = cell2mat(ydata);
        
        [r p] = corrcoef(ydata(:,1),ydata(:,4),'rows','complete');
        pitch_acorr_sal = [pitch_acorr_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,1),ydata(:,5),'rows','complete');
        pitch_sdur_sal = [pitch_sdur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,1),ydata(:,6),'rows','complete');
        pitch_g0dur_sal = [pitch_g0dur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,1),ydata(:,7),'rows','complete');
        pitch_g1dur_sal = [pitch_g1dur_sal; [r(2) p(2)]];
        
        [r p] = corrcoef(ydata(:,2),ydata(:,4),'rows','complete');
        vol_acorr_sal = [vol_acorr_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,2),ydata(:,5),'rows','complete');
        vol_sdur_sal = [vol_sdur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,2),ydata(:,6),'rows','complete');
        vol_g0dur_sal = [vol_g0dur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,2),ydata(:,7),'rows','complete');
        vol_g1dur_sal = [vol_g1dur_sal; [r(2) p(2)]];
        
        [r p] = corrcoef(ydata(:,3),ydata(:,4),'rows','complete');
        ent_acorr_sal = [ent_acorr_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,3),ydata(:,5),'rows','complete');
        ent_sdur_sal = [ent_sdur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,3),ydata(:,6),'rows','complete');
        ent_g0dur_sal = [ent_g0dur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,3),ydata(:,7),'rows','complete');
        ent_g1dur_sal = [ent_g1dur_sal; [r(2) p(2)]];
        
        [r p] = corrcoef(ydata(:,1),ydata(:,2),'rows','complete');
        pitch_vol_sal = [pitch_vol_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,1),ydata(:,3),'rows','complete');
        pitch_ent_sal = [pitch_ent_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,2),ydata(:,3),'rows','complete');
        vol_ent_sal = [vol_ent_sal; [r(2) p(2)]];
       
        [r p] = corrcoef(ydata(:,4),ydata(:,5),'rows','complete');
        acorr_sdur_sal = [acorr_sdur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,4),ydata(:,6),'rows','complete');
        acorr_g0dur_sal = [acorr_g0dur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,4),ydata(:,7),'rows','complete');
        acorr_g1dur_sal = [acorr_g1dur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,5),ydata(:,6),'rows','complete');
        sdur_g0dur_sal = [sdur_g0dur_sal; [r(2) p(2)]];
        [r p] = corrcoef(ydata(:,5),ydata(:,7),'rows','complete');
        sdur_g1dur_sal = [sdur_g1dur_sal; [r(2) p(2)]];
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%spec, paired
figure;hold on;
h1 = subtightplot(1,3,1,[0.1,0.05],0.15,0.1);
set(h1, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h1,repmat([0.5 1.5]',1,length(pitch_vol)),[pitch_vol_sal(:,1) ...
    pitch_vol(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h1,[0 2],[0 0],'c','linewidth',2);
xlim(h1,[0 2]);
ylabel(h1,'pitch vs volume');
set(h1,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(pitch_vol(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h1,str)
legend(h1,lname);


h2 = subtightplot(1,3,2,[0.1,0.05],0.15,0.1);
set(h2, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h2,repmat([0.5 1.5]',1,length(pitch_ent)),[pitch_ent_sal(:,1) ...
    pitch_ent(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h2,[0 2],[0 0],'c','linewidth',2);
xlim(h2,[0 2]);
ylabel(h2,'pitch vs entropy');
set(h2,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(pitch_ent(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_ent_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h2,str)

h3 = subtightplot(1,3,3,[0.1,0.05],0.15,0.1);
set(h3, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h3,repmat([0.5 1.5]',1,length(vol_ent)),[vol_ent_sal(:,1) ...
    vol_ent(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h3,[0 2],[0 0],'c','linewidth',2);
xlim(h3,[0 2]);
ylabel(h3,'volume vs entropy');
set(h3,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(vol_ent(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(vol_ent_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h3,str)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tempo, paired

figure;hold on;
h1 = subtightplot(1,5,1,[0.1,0.05],0.15,0.1);
set(h1, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h1,repmat([0.5 1.5]',1,length(acorr_sdur)),[acorr_sdur_sal(:,1) ...
    acorr_sdur(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h1,[0 2],[0 0],'c','linewidth',2);
xlim(h1,[0 2]);
ylabel(h1,'acorr vs syll dur');
set(h1,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(acorr_sdur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(acorr_sdur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(acorr_sdur(:,1),acorr_sdur_sal(:,1));
str3 = ['p sal vs naspm=',num2str(p1)];
str = {str str2 str3}
title(h1,str)
legend(h1,lname);


h2 = subtightplot(1,5,2,[0.1,0.05],0.15,0.1);
set(h2, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h2,repmat([0.5 1.5]',1,length(acorr_g0dur)),[acorr_g0dur_sal(:,1) ...
    acorr_g0dur(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h2,[0 2],[0 0],'c','linewidth',2);
xlim(h2,[0 2]);
ylabel(h2,'acorr vs pre gap');
set(h2,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(acorr_g0dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(acorr_g0dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(acorr_g0dur(:,1),acorr_g0dur_sal(:,1));
str3 = ['p sal vs naspm=',num2str(p1)];
str = {str str2 str3}
title(h2,str)

h3 = subtightplot(1,5,3,[0.1,0.05],0.15,0.1);
set(h3, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h3,repmat([0.5 1.5]',1,length(acorr_g1dur)),[acorr_g1dur_sal(:,1) ...
    acorr_g1dur(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h3,[0 2],[0 0],'c','linewidth',2);
xlim(h3,[0 2]);
ylabel(h3,'acorr vs gap');
set(h3,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(acorr_g1dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(acorr_g1dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(acorr_g1dur(:,1),acorr_g1dur_sal(:,1));
str3 = ['p sal vs naspm=',num2str(p1)];
str = {str str2 str3}
title(h3,str)

h4 = subtightplot(1,5,4,[0.1,0.05],0.15,0.1);
set(h4, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h4,repmat([0.5 1.5]',1,length(sdur_g0dur)),[sdur_g0dur_sal(:,1) ...
    sdur_g0dur(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h4,[0 2],[0 0],'c','linewidth',2);
xlim(h4,[0 2]);
ylabel(h4,'syll vs pre gap');
set(h4,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(sdur_g0dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(sdur_g0dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h4,str)

h5 = subtightplot(1,5,5,[0.1,0.05],0.15,0.1);
set(h5, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h5,repmat([0.5 1.5]',1,length(sdur_g1dur)),[sdur_g1dur_sal(:,1) ...
    sdur_g1dur(:,1)]','marker','o','Markersize',8,'linewidth',2);hold on;
plot(h5,[0 2],[0 0],'c','linewidth',2);
xlim(h5,[0 2]);
ylabel(h5,'syll vs gap');
set(h5,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(sdur_g1dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(sdur_g1dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h5,str)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%spec vs tempo paired
figure;hold on;
h1 = subtightplot(3,4,1,[0.1,0.07],0.15,0.1);
set(h1,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h1,[0.5 1.5],[pitch_acorr_sal(:,1) ...
    pitch_acorr(:,1)]','marker','o','Markersize',8);hold on;
plot(h1,[0 2],[0 0],'c','linewidth',2);
xlim(h1,[0 2]);
ylabel(h1,'pitch vs acorr');
set(h1,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(pitch_acorr(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_acorr_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h1,str)
legend(h1,lname);

h2 = subtightplot(3,4,2,[0.1,0.07],0.15,0.1);
set(h2,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h2,repmat([0.5 1.5]',1,length(pitch_sdur)),[pitch_sdur_sal(:,1) ...
    pitch_sdur(:,1)]','marker','o','Markersize',8);hold on;
plot(h2,[0 2],[0 0],'c','linewidth',2);
xlim(h2,[0 2]);
ylabel(h2,'pitch vs syll dur');
set(h2,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(pitch_sdur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_sdur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h2,str)

h3 = subtightplot(3,4,3,[0.1,0.07],0.15,0.1);
set(h3,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h3,[0.5 1.5]',[pitch_g0dur_sal(:,1) ...
    pitch_g0dur(:,1)],'marker','o','Markersize',8);hold on;
plot(h3,[0 2],[0 0],'c','linewidth',2);
xlim(h3,[0 2]);
ylabel(h3,'pitch vs pre gap');
set(h3,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(pitch_g0dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_g0dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h3,str)

h4 = subtightplot(3,4,4,[0.1,0.07],0.15,0.1);
set(h4,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h4,repmat([0.5 1.5]',1,length(pitch_g1dur)),[pitch_g1dur_sal(:,1) ...
    pitch_g1dur(:,1)]','marker','o','Markersize',8);hold on;
plot(h4,[0 2],[0 0],'c','linewidth',2);
xlim(h4,[0 2]);
ylabel(h4,'pitch vs gap');
set(h4,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(pitch_g1dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_g1dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h4,str)

h5 = subtightplot(3,4,5,[0.1,0.07],0.15,0.1);
set(h5,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h5,repmat([0.5 1.5]',1,length(vol_acorr)),[vol_acorr_sal(:,1) ...
    vol_acorr(:,1)]','marker','o','Markersize',8);hold on;
plot(h5,[0 2],[0 0],'c','linewidth',2);
xlim(h5,[0 2]);
ylabel(h5,'volume vs acorr');
set(h5,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(vol_acorr(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(vol_acorr_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h5,str)

h6 = subtightplot(3,4,6,[0.1,0.07],0.15,0.1);
set(h6,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h6,repmat([0.5 1.5]',1,length(vol_sdur)),[vol_sdur_sal(:,1) ...
    vol_sdur(:,1)]','marker','o','Markersize',8);hold on;
plot(h6,[0 2],[0 0],'c','linewidth',2);
xlim(h6,[0 2]);
ylabel(h6,'volume vs syll dur');
set(h6,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(vol_sdur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(vol_sdur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h6,str)


h7 = subtightplot(3,4,7,[0.1,0.07],0.15,0.1);
set(h7,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h7,repmat([0.5 1.5]',1,length(vol_g0dur)),[vol_g0dur_sal(:,1) ...
    vol_g0dur(:,1)]','marker','o','Markersize',8);hold on;
plot(h7,[0 2],[0 0],'c','linewidth',2);
xlim(h7,[0 2]);
ylabel(h7,'volume vs pre gap');
set(h7,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(vol_g0dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(vol_g0dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h7,str)

h8 = subtightplot(3,4,8,[0.1,0.07],0.15,0.1);
set(h8,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h8,repmat([0.5 1.5]',1,length(vol_g1dur)),[vol_g1dur_sal(:,1) ...
    vol_g1dur(:,1)]','marker','o','Markersize',8);hold on;
plot(h8,[0 2],[0 0],'c','linewidth',2);
xlim(h8,[0 2]);
ylabel(h8,'volume vs gap');
set(h8,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(vol_g1dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(vol_g1dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h8,str)

h9 = subtightplot(3,4,9,[0.1,0.07],0.15,0.1);
set(h9,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h9,repmat([0.5 1.5]',1,length(ent_acorr)),[ent_acorr_sal(:,1) ...
    ent_acorr(:,1)]','marker','o','Markersize',8);hold on;
plot(h9,[0 2],[0 0],'c','linewidth',2);
xlim(h9,[0 2]);
ylabel(h9,'entropy vs acorr');
set(h9,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(ent_acorr(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(ent_acorr_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h9,str)

h10 = subtightplot(3,4,10,[0.1,0.07],0.15,0.1);
set(h10,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h10,repmat([0.5 1.5]',1,length(ent_sdur)),[ent_sdur_sal(:,1) ...
    ent_sdur(:,1)]','marker','o','Markersize',8);hold on;
plot(h10,[0 2],[0 0],'c','linewidth',2);
xlim(h10,[0 2]);
ylabel(h10,'entropy vs syll dur');
set(h10,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(ent_sdur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(ent_sdur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h10,str)

h11 = subtightplot(3,4,11,[0.1,0.07],0.15,0.1);
set(h11,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h11,repmat([0.5 1.5]',1,length(ent_g0dur)),[ent_g0dur_sal(:,1) ...
    ent_g0dur(:,1)]','marker','o','Markersize',8);hold on;
plot(h11,[0 2],[0 0],'c','linewidth',2);
xlim(h11,[0 2]);
ylabel(h11,'entropy vs pre gap');
set(h11,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(ent_g0dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(ent_g0dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h11,str)

h12 = subtightplot(3,4,12,[0.1,0.07],0.15,0.1);
set(h12,'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h12,repmat([0.5 1.5]',1,length(ent_g1dur)),[ent_g1dur_sal(:,1) ...
    ent_g1dur(:,1)]','marker','o','Markersize',8);hold on;
plot(h12,[0 2],[0 0],'c','linewidth',2);
xlim(h12,[0 2]);
ylabel(h12,'entropy vs gap');
set(h12,'xtick',[0.5 1.5],'xticklabel',{'saline','{\color{red}NASPM}'},'fontweight','bold');
p1 = signrank(ent_g1dur(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(ent_g1dur_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
str = {str str2}
title(h12,str)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pitch_acorr = pitch_acorr(find(pitch_acorr(:,2)<=0.05),:);
% pitch_sdur = pitch_sdur(find(pitch_sdur(:,2)<=0.05),:);
% pitch_g0dur = pitch_g0dur(find(pitch_g0dur(:,2)<=0.05),:);
% pitch_g1dur = pitch_g1dur(find(pitch_g1dur(:,2)<=0.05),:);
% vol_acorr = vol_acorr(find(vol_acorr(:,2)<=0.05),:);
% vol_sdur = vol_sdur(find(vol_sdur(:,2)<=0.05),:);
% vol_g0dur = vol_g0dur(find(vol_g0dur(:,2)<=0.05),:);
% vol_g1dur = vol_g1dur(find(vol_g1dur(:,2)<=0.05),:);
% ent_acorr = ent_acorr(find(ent_acorr(:,2)<=0.05),:);
% ent_sdur = ent_sdur(find(ent_sdur(:,2)<=0.05),:);
% ent_g0dur = ent_g0dur(find(ent_g0dur(:,2)<=0.05),:);
% ent_g1dur = ent_g1dur(find(ent_g1dur(:,2)<=0.05),:);
% 
% pitch_acorr_sal = pitch_acorr_sal(find(pitch_acorr_sal(:,2)<=0.05),:);
% pitch_sdur_sal = pitch_sdur_sal(find(pitch_sdur_sal(:,2)<=0.05),:);
% pitch_g0dur_sal = pitch_g0dur_sal(find(pitch_g0dur_sal(:,2)<=0.05),:);
% pitch_g1dur_sal = pitch_g1dur_sal(find(pitch_g1dur_sal(:,2)<=0.05),:);
% vol_acorr_sal = vol_acorr_sal(find(vol_acorr_sal(:,2)<=0.05),:);
% vol_sdur_sal = vol_sdur_sal(find(vol_sdur_sal(:,2)<=0.05),:);
% vol_g0dur_sal = vol_g0dur_sal(find(vol_g0dur_sal(:,2)<=0.05),:);
% vol_g1dur_sal = vol_g1dur_sal(find(vol_g1dur_sal(:,2)<=0.05),:);
% ent_acorr_sal = ent_acorr_sal(find(ent_acorr_sal(:,2)<=0.05),:);
% ent_sdur_sal = ent_sdur_sal(find(ent_sdur_sal(:,2)<=0.05),:);
% ent_g0dur_sal = ent_g0dur_sal(find(ent_g0dur_sal(:,2)<=0.05),:);
% ent_g1dur_sal = ent_g1dur_sal(find(ent_g1dur_sal(:,2)<=0.05),:);
% 
% 
% figure;hold on;
% h1 = subtightplot(3,4,1,[0.15,0.07],0.08,0.08);
% [n b] = hist(pitch_acorr(:,1),[-1:0.1:1]);
% stairs(h1,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(pitch_acorr_sal(:,1),[-1:0.1:1]);
% hold(h1,'on');
% stairs(h1,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h1,'ylim');
% plot(h1,nanmean(pitch_acorr_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h1,nanmean(pitch_acorr(:,1)),ylimits(2),'rV','markersize',8);
% plot(h1,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(pitch_acorr(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(pitch_acorr_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h1,str);
% xlabel(h1,'r: pitch vs motif acorr');
% ylabel(h1,'probability');
% set(h1,'fontweight','bold');
% 
% h2 = subtightplot(3,4,2,[0.15,0.07],0.08,0.08);
% [n b] = hist(pitch_sdur(:,1),[-1:0.1:1]);
% stairs(h2,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(pitch_sdur_sal(:,1),[-1:0.1:1]);
% hold(h2,'on');
% stairs(h2,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h2,'ylim');
% plot(h2,nanmean(pitch_sdur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h2,nanmean(pitch_sdur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h2,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(pitch_sdur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(pitch_sdur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h2,str);
% xlabel(h2,'r: pitch vs syll dur');
% ylabel(h2,'probability');
% set(h2,'fontweight','bold');
% 
% h3 = subtightplot(3,4,3,[0.15,0.07],0.08,0.08);
% [n b] = hist(pitch_g0dur(:,1),[-1:0.1:1]);
% stairs(h3,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(pitch_g0dur_sal(:,1),[-1:0.1:1]);
% hold(h3,'on');
% stairs(h3,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h3,'ylim');
% plot(h3,nanmean(pitch_g0dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h3,nanmean(pitch_g0dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h3,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(pitch_g0dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(pitch_g0dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h3,str);
% xlabel(h3,'r: pitch vs pre gap');
% ylabel(h3,'probability');
% set(h3,'fontweight','bold');
% 
% h4 = subtightplot(3,4,4,[0.15,0.07],0.08,0.08);
% [n b] = hist(pitch_g1dur(:,1),[-1:0.1:1]);
% stairs(h4,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(pitch_g1dur_sal(:,1),[-1:0.1:1]);
% hold(h4,'on');
% stairs(h4,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h4,'ylim');
% plot(h4,nanmean(pitch_g1dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h4,nanmean(pitch_g1dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h4,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(pitch_g1dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(pitch_g1dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h4,str);
% xlabel(h4,'r: pitch vs gap');
% ylabel(h4,'probability');
% set(h4,'fontweight','bold');
% 
% h5 = subtightplot(3,4,5,[0.15,0.07],0.08,0.08);
% [n b] = hist(vol_acorr(:,1),[-1:0.1:1]);
% stairs(h5,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(vol_acorr_sal(:,1),[-1:0.1:1]);
% hold(h5,'on');
% stairs(h5,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h5,'ylim');
% plot(h5,nanmean(vol_acorr_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h5,nanmean(vol_acorr(:,1)),ylimits(2),'rV','markersize',8);
% plot(h5,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(vol_acorr(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(vol_acorr_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h5,str);
% xlabel(h5,'r: volume vs motif acorr');
% ylabel(h5,'probability');
% set(h5,'fontweight','bold');
% 
% h6 = subtightplot(3,4,6,[0.15,0.07],0.08,0.08);
% [n b] = hist(vol_sdur(:,1),[-1:0.1:1]);
% stairs(h6,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(vol_sdur_sal(:,1),[-1:0.1:1]);
% hold(h6,'on');
% stairs(h6,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h6,'ylim');
% plot(h6,nanmean(vol_sdur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h6,nanmean(vol_sdur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h6,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(vol_sdur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(vol_sdur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h6,str);
% xlabel(h6,'r: volume vs syll dur');
% ylabel(h6,'probability');
% set(h6,'fontweight','bold');
% 
% h7 = subtightplot(3,4,7,[0.15,0.07],0.08,0.08);
% [n b] = hist(vol_g0dur(:,1),[-1:0.1:1]);
% stairs(h7,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(vol_g0dur_sal(:,1),[-1:0.1:1]);
% hold(h7,'on');
% stairs(h7,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h7,'ylim');
% plot(h7,nanmean(vol_g0dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h7,nanmean(vol_g0dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h7,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(vol_g0dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(vol_g0dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h7,str);
% xlabel(h7,'r: volume vs pre gap');
% ylabel(h7,'probability');
% set(h7,'fontweight','bold');
% 
% h8 = subtightplot(3,4,8,[0.15,0.07],0.08,0.08);
% [n b] = hist(vol_g1dur(:,1),[-1:0.1:1]);
% stairs(h8,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(vol_g1dur_sal(:,1),[-1:0.1:1]);
% hold(h8,'on');
% stairs(h8,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h8,'ylim');
% plot(h8,nanmean(vol_g1dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h8,nanmean(vol_g1dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h8,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(vol_g1dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(vol_g1dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h8,str);
% xlabel(h8,'r: volume vs gap');
% ylabel(h8,'probability');
% set(h8,'fontweight','bold');
% 
% h9 = subtightplot(3,4,9,[0.15,0.07],0.08,0.08);
% [n b] = hist(ent_acorr(:,1),[-1:0.1:1]);
% stairs(h9,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(ent_acorr_sal(:,1),[-1:0.1:1]);
% hold(h9,'on');
% stairs(h9,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h9,'ylim');
% plot(h9,nanmean(ent_acorr_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h9,nanmean(ent_acorr(:,1)),ylimits(2),'rV','markersize',8);
% plot(h9,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(ent_acorr(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(ent_acorr_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h9,str);
% xlabel(h9,'r: entropy vs motif acorr');
% ylabel(h9,'probability');
% set(h9,'fontweight','bold');
% 
% h10 = subtightplot(3,4,10,[0.15,0.07],0.08,0.08);
% [n b] = hist(ent_sdur(:,1),[-1:0.1:1]);
% stairs(h10,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(ent_sdur_sal(:,1),[-1:0.1:1]);
% hold(h10,'on');
% stairs(h10,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h10,'ylim');
% plot(h10,nanmean(ent_sdur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h10,nanmean(ent_sdur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h10,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(ent_sdur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(ent_sdur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h10,str);
% xlabel(h10,'r: entropy vs syll dur');
% ylabel(h10,'probability');
% set(h10,'fontweight','bold');
% 
% h11 = subtightplot(3,4,11,[0.15,0.07],0.08,0.08);
% [n b] = hist(ent_g0dur(:,1),[-1:0.1:1]);
% stairs(h11,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(ent_g0dur_sal(:,1),[-1:0.1:1]);
% hold(h11,'on');
% stairs(h11,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h11,'ylim');
% plot(h11,nanmean(ent_g0dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h11,nanmean(ent_g0dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h11,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(ent_g0dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(ent_g0dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h11,str);
% xlabel(h11,'r: entropy vs pre gap');
% ylabel(h11,'probability');
% set(h11,'fontweight','bold');
% 
% h12 = subtightplot(3,4,12,[0.15,0.07],0.08,0.08);
% [n b] = hist(ent_g1dur(:,1),[-1:0.1:1]);
% stairs(h12,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(ent_g1dur_sal(:,1),[-1:0.1:1]);
% hold(h12,'on');
% stairs(h12,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h12,'ylim');
% plot(h12,nanmean(ent_g1dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h12,nanmean(ent_g1dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h12,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(ent_g1dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(ent_g1dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h12,str);
% xlabel(h12,'r: entropy vs gap');
% ylabel(h12,'probability');
% set(h12,'fontweight','bold');
% 
% %%%%%%%%%%%%%%%%%%%%%%
% pitch_vol = pitch_vol(find(pitch_vol(:,2)<=0.05),:);
% pitch_ent = pitch_ent(find(pitch_ent(:,2)<=0.05),:);
% vol_ent = vol_ent(find(vol_ent(:,2)<=0.05),:);
% 
% pitch_vol_sal = pitch_vol_sal(find(pitch_vol_sal(:,2)<=0.05),:);
% pitch_ent_sal = pitch_ent_sal(find(pitch_ent_sal(:,2)<=0.05),:);
% vol_ent_sal = vol_ent_sal(find(vol_ent_sal(:,2)<=0.05),:);
% 
% figure;hold on;
% h1 = subtightplot(1,3,1,[0.15,0.07],0.15,0.08);
% [n b] = hist(pitch_vol(:,1),[-1:0.1:1]);
% stairs(h1,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(pitch_vol_sal(:,1),[-1:0.1:1]);
% hold(h1,'on');
% stairs(h1,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h1,'ylim');
% plot(h1,nanmean(pitch_vol_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h1,nanmean(pitch_vol(:,1)),ylimits(2),'rV','markersize',8);
% plot(h1,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(pitch_vol(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(pitch_vol_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h1,str);
% xlabel(h1,'r: pitch vs volume');
% ylabel(h1,'probability');
% set(h1,'fontweight','bold');
% 
% h2 = subtightplot(1,3,2,[0.15,0.07],0.15,0.08);
% [n b] = hist(pitch_ent(:,1),[-1:0.1:1]);
% stairs(h2,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(pitch_ent_sal(:,1),[-1:0.1:1]);
% hold(h2,'on');
% stairs(h2,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h2,'ylim');
% plot(h2,nanmean(pitch_ent_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h2,nanmean(pitch_ent(:,1)),ylimits(2),'rV','markersize',8);
% plot(h2,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(pitch_ent(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(pitch_ent_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h2,str);
% xlabel(h2,'r: pitch vs entropy');
% ylabel(h2,'probability');
% set(h2,'fontweight','bold');
% 
% h3 = subtightplot(1,3,3,[0.15,0.07],0.15,0.08);
% [n b] = hist(vol_ent(:,1),[-1:0.1:1]);
% stairs(h3,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(vol_ent_sal(:,1),[-1:0.1:1]);
% hold(h3,'on');
% stairs(h3,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h3,'ylim');
% plot(h3,nanmean(vol_ent_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h3,nanmean(vol_ent(:,1)),ylimits(2),'rV','markersize',8);
% plot(h3,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(vol_ent(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(vol_ent_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h3,str);
% xlabel(h3,'r: volume vs entropy');
% ylabel(h3,'probability');
% set(h3,'fontweight','bold');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  acorr_sdur = acorr_sdur(find(acorr_sdur(:,2)<=0.05),:);
% acorr_g0dur = acorr_g0dur(find(acorr_g0dur(:,2)<=0.05),:);
% acorr_g1dur = acorr_g1dur(find(acorr_g1dur(:,2)<=0.05),:);
% sdur_g0dur = sdur_g0dur(find(sdur_g0dur(:,2)<=0.05),:);
% sdur_g1dur = sdur_g0dur(find(sdur_g0dur(:,2)<=0.05),:);
% 
% acorr_sdur_sal = acorr_sdur_sal(find(acorr_sdur_sal(:,2)<=0.05),:);
% acorr_g0dur_sal = acorr_g0dur_sal(find(acorr_g0dur_sal(:,2)<=0.05),:);
% acorr_g1dur_sal = acorr_g1dur_sal(find(acorr_g1dur_sal(:,2)<=0.05),:);
% sdur_g0dur_sal = sdur_g0dur_sal(find(sdur_g0dur_sal(:,2)<=0.05),:);
% sdur_g1dur_sal = sdur_g0dur_sal(find(sdur_g0dur_sal(:,2)<=0.05),:);
% 
% figure;hold on;
% h1 = subtightplot(1,5,1,[0.15,0.07],0.15,0.08);
% [n b] = hist(acorr_sdur(:,1),[-1:0.1:1]);
% stairs(h1,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(acorr_sdur_sal(:,1),[-1:0.1:1]);
% hold(h1,'on');
% stairs(h1,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h1,'ylim');
% plot(h1,nanmean(acorr_sdur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h1,nanmean(acorr_sdur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h1,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(acorr_sdur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(acorr_sdur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h1,str);
% xlabel(h1,'r: acorr vs syll dur');
% ylabel(h1,'probability');
% set(h1,'fontweight','bold');
% 
% h2 = subtightplot(1,5,2,[0.15,0.07],0.15,0.08);
% [n b] = hist(acorr_g0dur(:,1),[-1:0.1:1]);
% stairs(h2,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(acorr_g0dur_sal(:,1),[-1:0.1:1]);
% hold(h2,'on');
% stairs(h2,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h2,'ylim');
% plot(h2,nanmean(acorr_g0dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h2,nanmean(acorr_g0dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h2,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(acorr_g0dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(acorr_g0dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h2,str);
% xlabel(h2,'r: acorr vs pre gap');
% ylabel(h2,'probability');
% set(h2,'fontweight','bold');
% 
% h3 = subtightplot(1,5,3,[0.15,0.07],0.15,0.08);
% [n b] = hist(acorr_g1dur(:,1),[-1:0.1:1]);
% stairs(h3,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(acorr_g1dur_sal(:,1),[-1:0.1:1]);
% hold(h3,'on');
% stairs(h3,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h3,'ylim');
% plot(h3,nanmean(acorr_g1dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h3,nanmean(acorr_g1dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h3,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(acorr_g1dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(acorr_g1dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h3,str);
% xlabel(h3,'r: acorr vs gap');
% ylabel(h3,'probability');
% set(h3,'fontweight','bold');
% 
% h4 = subtightplot(1,5,4,[0.15,0.07],0.15,0.08);
% [n b] = hist(sdur_g0dur(:,1),[-1:0.1:1]);
% stairs(h4,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(sdur_g0dur_sal(:,1),[-1:0.1:1]);
% hold(h4,'on');
% stairs(h4,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h4,'ylim');
% plot(h4,nanmean(sdur_g0dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h4,nanmean(sdur_g0dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h4,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(sdur_g0dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(sdur_g0dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h4,str);
% xlabel(h4,'r: syll vs pre gap dur');
% ylabel(h4,'probability');
% set(h4,'fontweight','bold');
% 
% h5 = subtightplot(1,5,5,[0.15,0.07],0.15,0.08);
% [n b] = hist(sdur_g1dur(:,1),[-1:0.1:1]);
% stairs(h5,b,n/sum(n),'r','linewidth',2);
% [n b] = hist(sdur_g1dur_sal(:,1),[-1:0.1:1]);
% hold(h5,'on');
% stairs(h5,b,n/sum(n),'k','linewidth',2);
% ylimits = get(h5,'ylim');
% plot(h5,nanmean(sdur_g1dur_sal(:,1)),ylimits(2),'kV','markersize',8);
% plot(h5,nanmean(sdur_g1dur(:,1)),ylimits(2),'rV','markersize',8);
% plot(h5,[0 0],[ylimits(1) ylimits(2)],'c','linewidth',2);
% p1 = signrank(sdur_g1dur(:,1));
% str = ['{\color{red}p = ',num2str(p1),'}'];
% p1 = signrank(sdur_g1dur_sal(:,1));
% str2 = ['{\color{black}p = ',num2str(p1),'}'];
% str = {str str2}
% title(h5,str);
% xlabel(h5,'r: syll vs gap dur');
% ylabel(h5,'probability');
% set(h5,'fontweight','bold');