ff = load_batchf('naspm_birds');

numsylls = 0;
numgapsfor = [];
numgapsback = [];
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/summary']);
    
    x = eval(['pitchgapcorr_',ff(i).name]); 
    syllables = fieldnames(x);
    numsylls = numsylls+length(syllables);
    for ii = 1:length(syllables)
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).sal];
        numgapsfor = [numgapsfor; arrayfun(@(x) size(x.gapsfor,2),xdata(1))];
        numgapsback = [numgapsback; arrayfun(@(x) size(x.gapsback,2),xdata(1))];
    end
end

pitch_gapfor = NaN(numsylls,max(numgapsfor));
pitch_gapback = NaN(numsylls,max(numgapsback));
pitch_gapfor_sal = NaN(numsylls,max(numgapsfor));
pitch_gapback_sal = NaN(numsylls,max(numgapsback));

syllcnt = 1;
for i = 1:length(ff)
    x = eval(['pitchgapcorr_',ff(i).name]); 
    syllables = fieldnames(x);
    for ii = 1:length(syllables)
        xdata = [x(:).([syllables{ii}])];
        xdata = [xdata(:).sal];
        
        ydata = [x(:).([syllables{ii}])];
        ydata = [ydata(:).cond];
    
        pitch = cell2mat(arrayfun(@(x) x.pitch,xdata,'unif',0)');
        gapfor = cell2mat(arrayfun(@(x) x.gapsfor,xdata,'unif',0)');
        gapback = cell2mat(arrayfun(@(x) x.gapsback,xdata,'unif',0)');
        
        for ind = 1:size(gapfor,2)
            [r p] = corrcoef(pitch,gapfor(:,ind),'rows','complete');
            pitch_gapfor_sal(syllcnt,ind) = r(2);
        end
        
        for ind = 1:size(gapback,2)
            [r p] = corrcoef(pitch,gapback(:,ind),'rows','complete');
            pitch_gapback_sal(syllcnt,ind) = r(2);
        end
        
        pitch = cell2mat(arrayfun(@(x) x.pitch,ydata,'unif',0)');
        gapfor = cell2mat(arrayfun(@(x) x.gapsfor,ydata,'unif',0)');
        gapback = cell2mat(arrayfun(@(x) x.gapsback,ydata,'unif',0)');
        
        for ind = 1:size(gapfor,2)
            [r p] = corrcoef(pitch,gapfor(:,ind),'rows','complete');
            pitch_gapfor(syllcnt,ind) = r(2);
        end
        
        for ind = 1:size(gapback,2)
            [r p] = corrcoef(pitch,gapback(:,ind),'rows','complete');
            pitch_gapback(syllcnt,ind) = r(2);
        end
        
        syllcnt = syllcnt+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
for i = 1:max(numgapsfor)
    h = subtightplot(1,max(numgapsfor),i,[0.1 0.04],0.25,0.04);
    plot(h,[0.5 1.5],[pitch_gapfor_sal(:,i),pitch_gapfor(:,i)],'o-',...
        'markersize',8,'linewidth',2);hold on;
    plot(h,[0 2],[0 0],'c','linewidth',2);
    p1 = signrank(pitch_gapfor(:,i));
    str = ['{\color{red}p = ',num2str(p1),'}'];
    p1 = signrank(pitch_gapfor_sal(:,i));
    str2 = ['{\color{black}p = ',num2str(p1),'}'];
    p1 = signtest(pitch_gapfor_sal(:,i),pitch_gapfor(:,i));
    str3 = {'p sal vs naspm=',num2str(p1)};
    title(h,[['Pitch vs Gap+',num2str(i)],str,str2,str3]);
    ylabel('Correlation');
    set(h,'xtick',[0.5 1.5],'xlim',[0 2],'xticklabel',{'saline','{\color{red}NASPM}'},...
        'fontweight','bold','ylim',[-.6 .6]);
end

figure;hold on;
for i = 1:max(numgapsback)
    h = subtightplot(1,max(numgapsback),i,[0.1 0.04],0.25,0.04);
    plot(h,[0.5 1.5],[pitch_gapback_sal(:,i),pitch_gapback(:,i)],'o-',...
        'markersize',8,'linewidth',2);hold on;
    plot(h,[0 2],[0 0],'c','linewidth',2);
    p1 = signrank(pitch_gapback(:,i));
    str = ['{\color{red}p = ',num2str(p1),'}'];
    p1 = signrank(pitch_gapback_sal(:,i));
    str2 = ['{\color{black}p = ',num2str(p1),'}'];
    p1 = signtest(pitch_gapback_sal(:,i),pitch_gapback(:,i));
    str3 = {'p sal vs naspm=',num2str(p1)};
    title(h,[['Pitch vs Gap-',num2str(i)],str,str2,str3]);
    ylabel('Correlation');
    set(h,'xtick',[0.5 1.5],'xlim',[0 2],'xticklabel',{'saline','{\color{red}NASPM}'},...
        'fontweight','bold','ylim',[-.8 .8]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;hold on;
h = subtightplot(1,2,1,[0.1 0.1],0.25,0.1);
plot(h,[0.5 1.5],[pitch_gapfor_sal(:,1),pitch_gapfor(:,1)],'o-',...
    'markersize',8,'linewidth',2);hold on;
plot(h,[0 2],[0 0],'c','linewidth',2);
p1 = signrank(pitch_gapfor(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_gapfor_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(pitch_gapfor_sal(:,1),pitch_gapfor(:,1));
str3 = {'p sal vs naspm=',num2str(p1)};
title(h,['Pitch vs Gap+1',str,str2,str3]);
ylabel('Correlation');
set(h,'xtick',[0.5 1.5],'xlim',[0 2],'xticklabel',{'saline','{\color{red}NASPM}'},...
    'fontweight','bold','ylim',[-.6 .6]);

h = subtightplot(1,2,2,[0.1 0.1],0.25,0.1);
plot(h,[0.5 1.5],[reshape(pitch_gapfor_sal(:,2:end),[],1),...
    reshape(pitch_gapfor(:,2:end),[],1)],'o-','markersize',8,'linewidth',2);hold on;
plot(h,[0 2],[0 0],'c','linewidth',2);
p1 = signrank(reshape(pitch_gapfor(:,2:end),[],1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(reshape(pitch_gapfor_sal(:,2:end),[],1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(reshape(pitch_gapfor_sal(:,2:end),[],1),...
    reshape(pitch_gapfor(:,2:end),[],1));
str3 = {'p sal vs naspm=',num2str(p1)};
title(h,[['Pitch vs Gap+2+'],str,str2,str3]);
ylabel('Correlation');
set(h,'xtick',[0.5 1.5],'xlim',[0 2],'xticklabel',{'saline','{\color{red}NASPM}'},...
    'fontweight','bold','ylim',[-.6 .6]);


figure;hold on;
h = subtightplot(1,2,1,[0.1 0.1],0.25,0.1);
plot(h,[0.5 1.5],[pitch_gapback_sal(:,1),pitch_gapback(:,1)],'o-',...
    'markersize',8,'linewidth',2);hold on;
plot(h,[0 2],[0 0],'c','linewidth',2);
p1 = signrank(pitch_gapback(:,1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(pitch_gapback_sal(:,1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(pitch_gapback_sal(:,1),pitch_gapback(:,1));
str3 = {'p sal vs naspm=',num2str(p1)};
title(h,['Pitch vs Gap-1',str,str2,str3]);
ylabel('Correlation');
set(h,'xtick',[0.5 1.5],'xlim',[0 2],'xticklabel',{'saline','{\color{red}NASPM}'},...
    'fontweight','bold','ylim',[-.8 .8]);

h = subtightplot(1,2,2,[0.1 0.1],0.25,0.1);
plot(h,[0.5 1.5],[reshape(pitch_gapback_sal(:,2:end),[],1),...
    reshape(pitch_gapback(:,2:end),[],1)],'o-','markersize',8,'linewidth',2);hold on;
plot(h,[0 2],[0 0],'c','linewidth',2);
p1 = signrank(reshape(pitch_gapback(:,2:end),[],1));
str = ['{\color{red}p = ',num2str(p1),'}'];
p1 = signrank(reshape(pitch_gapback_sal(:,2:end),[],1));
str2 = ['{\color{black}p = ',num2str(p1),'}'];
p1 = signtest(reshape(pitch_gapback_sal(:,2:end),[],1),...
    reshape(pitch_gapback(:,2:end),[],1));
str3 = {'p sal vs naspm=',num2str(p1)};
title(h,[['Pitch vs Gap-2+'],str,str2,str3]);
ylabel('Correlation');
set(h,'xtick',[0.5 1.5],'xlim',[0 2],'xticklabel',{'saline','{\color{red}NASPM}'},...
    'fontweight','bold','ylim',[-.8 .8]);
