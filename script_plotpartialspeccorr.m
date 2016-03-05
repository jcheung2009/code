%partial corr of pitch vs vol vs tempo
ff = load_batchf('naspm_birds');

pitch_vol_acorr = [];%[p_v, p_t, v_t]
pitch_vol_acorr_sal = [];

cmap = [];
lname = {};
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/summary']);
    x = eval(['spectempocorr_',ff(i).name]);
    syllables = fieldnames(x);
    cmap = [cmap;repmat(hsv(length(syllables)),length(x),1)];
    for ii = 1:length(syllables)
        lname = [lname;{ff(i).name}];
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).cond];
        xdata = arrayfun(@(x) x.abs,xdata,'unif',0)';
        xdata = cell2mat(xdata);
        
        ydata = [x(:).([syllables{ii}])];
        ydata = [ydata(:).sal];
        ydata = arrayfun(@(x) x.abs,ydata,'unif',0)';
        ydata = cell2mat(ydata);
        
         r = partialcorr([ydata(:,1:2),...
                ydata(:,4)],'rows','complete');
         r2 = partialcorr([xdata(:,1:2),...
                xdata(:,4)],'rows','complete');
       
       pitch_vol_acorr_sal = [pitch_vol_acorr_sal; r(2) r(3) r(6)];
       pitch_vol_acorr = [pitch_vol_acorr; r2(2) r2(3) r2(6)]; 
        
%         for k = 1:length(x)
%             r = partialcorr([x(k).([syllables{ii}]).sal.abs(:,1:2),...
%                 x(k).([syllables{ii}]).sal.abs(:,4)],'rows','complete');
%             r2 = partialcorr([x(k).([syllables{ii}]).cond.abs(:,1:2),...
%                 x(k).([syllables{ii}]).cond.abs(:,4)],'rows','complete');
%        
%            pitch_vol_acorr_sal = [pitch_vol_acorr_sal; r(2) r(3) r(6)];
%            pitch_vol_acorr = [pitch_vol_acorr; r2(2) r2(3) r2(6)]; 
%         end
    end
end

figure;hold on;
h1 = subtightplot(1,3,1,[0.1 0.07],0.2,0.15);%pitch vs vol
h2 = subtightplot(1,3,2,[0.1 0.07],0.2,0.15);%pitch vs tempo
h3 = subtightplot(1,3,3,[0.1 0.07],0.2,0.15);%vol vs tempo

axes(h1);hold on;
set(h1, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h1,[0.5 1.5],[pitch_vol_acorr_sal(:,1) pitch_vol_acorr(:,1)],'o-','Markersize',8,...
    'linewidth',2);hold on;
plot(h1,[0 2],[0 0],'c','linewidth',2);hold on;
p1 = signrank(pitch_vol_acorr(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_acorr_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_acorr(:,1),pitch_vol_acorr_sal(:,1));
str3 = ['{\color{black}p sal vs naspm= ',num2str(p1),'}'];
str = {str str2 str3};
title(h1,['pitch vs volume',str]);
ylabel(h1,'correlation')
set(h1,'fontweight','bold','xtick',[0.5 1.5],'xticklabel',...
    {'saline','{\color{red}NASPM}'},'xlim',[0 2]);

axes(h2);hold on;
set(h2, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h2,[0.5 1.5],[pitch_vol_acorr_sal(:,2) pitch_vol_acorr(:,2)],'o-','Markersize',8,...
    'linewidth',2);hold on;
plot(h2,[0 2],[0 0],'c','linewidth',2);hold on;
p1 = signrank(pitch_vol_acorr(:,2));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_acorr_sal(:,2));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_acorr(:,2),pitch_vol_acorr_sal(:,2));
str3 = ['{\color{black}p sal vs naspm= ',num2str(p1),'}'];
str = {str str2 str3};
title(h2,['pitch vs tempo',str]);
ylabel(h2,'correlation')
set(h2,'fontweight','bold','xtick',[0.5 1.5],'xticklabel',...
    {'saline','{\color{red}NASPM}'},'xlim',[0 2]);

axes(h3);hold on;
set(h3, 'ColorOrder',cmap,'NextPlot','replacechildren');
plot(h3,[0.5 1.5],[pitch_vol_acorr_sal(:,3) pitch_vol_acorr(:,3)],'o-','Markersize',8,...
    'linewidth',2);hold on;
plot(h3,[0 2],[0 0],'c','linewidth',2);hold on;
p1 = signrank(pitch_vol_acorr(:,3));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_acorr_sal(:,3));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signrank(pitch_vol_acorr(:,3),pitch_vol_acorr_sal(:,3));
str3 = ['{\color{black}p sal vs naspm= ',num2str(p1),'}'];
str = {str str2 str3};
title(h3,['volume vs tempo',str]);
ylabel(h3,'correlation')
set(h3,'fontweight','bold','xtick',[0.5 1.5],'xticklabel',...
    {'saline','{\color{red}NASPM}'},'xlim',[0 2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
h1 = subtightplot(1,3,1,[0.1 0.07],0.2,0.15);%pitch vs vol
h2 = subtightplot(1,3,2,[0.1 0.07],0.2,0.15);%pitch vs tempo
h3 = subtightplot(1,3,3,[0.1 0.07],0.2,0.15);%vol vs tempo

plot(h1,pitch_vol_acorr_sal(:,1),pitch_vol_acorr(:,1),'ok','markersize',8);
refline(h1,1,0);
xlabel(h1,'correlation at baseline');
ylabel(h1,'correlation in NASPM');
title(h1,'pitch vs volume');
set(h1,'fontweight','bold');

plot(h2,pitch_vol_acorr_sal(:,2),pitch_vol_acorr(:,2),'ok','markersize',8);
refline(h2,1,0);
xlabel(h2,'correlation at baseline');
ylabel(h2,'correlation in NASPM');
title(h2,'pitch vs tempo');
set(h2,'fontweight','bold');

plot(h3,pitch_vol_acorr_sal(:,3),pitch_vol_acorr(:,3),'ok','markersize',8);
refline(h3,1,0);
xlabel(h3,'correlation at baseline');
ylabel(h3,'correlation in NASPM');
title(h3,'volume vs tempo');
set(h3,'fontweight','bold');


