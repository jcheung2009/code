function jc_pitchvariability(boutinfo,marker,linecolor,motif,fignum1,fignum2)
%this function generates two figures. One plots the pitch cv for each
%target syllable in boutinfo for every rendition and compares it to the
%pitch cv when controlling by bout position. The second correlates pitch
%and bout position to determine how much variability in pitch can be
%explained by bout position.

%% plot pitch cv before and after controlling for bout position
maxnummotifs = max(arrayfun(@(x) x.nummotifs,boutinfo));
numsylls = size(boutinfo(1).boutpitch,2);
all_pitch = cell2mat(arrayfun(@(x) x.boutpitch,boutinfo,'unif',0)');
pitchbyposition = cell(1,maxnummotifs);
for i = 1:maxnummotifs
    for ii = 1:length(boutinfo)
        if size(boutinfo(ii).boutpitch,1) >= i
            pitchbyposition{i} = [pitchbyposition{i};boutinfo(ii).boutpitch(i,:)];
        end
    end
end

figure(fignum1);hold on;
for ii = 1:numsylls
    subtightplot(numsylls,1,ii,[0.08 0.08],[0.08 0.08],0.15);hold on;
    [mn hi lo] = mBootstrapCI_CV(all_pitch(:,ii));
    plot([1 1],[hi lo],linecolor,'linewidth',2);hold on;
    bar(1,mn,'facecolor','none','edgecolor',linecolor,'linewidth',2);hold on;
    for i = 1:3
        [mn1 hi1 lo1] = mBootstrapCI_CV(pitchbyposition{i}(:,ii));
        plot([i+1 i+1],[hi1 lo1],linecolor,'linewidth',2);hold on;
        bar(i+1,mn1,'facecolor','none','edgecolor',linecolor,'linewidth',2);hold on;
    end
    ylabel('pitch CV');
    title(['bout ',motif]);
    set(gca,'fontweight','bold','xlim',[0 5],'xtick',[1:4],'xticklabel',{'all','1','2','3'});
end
    
    

%% correlate pitch by serial position to get percent variability explained by bout position
figure(fignum2);hold on;
for ii = 1:numsylls
    subtightplot(numsylls,1,ii,[0.08 0.08],[0.08 0.08],0.15);hold on;
    corrdata = [];
    for i = 1:maxnummotifs
        plot(i,pitchbyposition{i}(:,ii),marker);hold on;
        corrdata = [corrdata; i*ones(length(pitchbyposition{i}(:,ii)),1) pitchbyposition{i}(:,ii)];
    end
    removeind = find(isnan(corrdata(:,2)));
    corrdata(removeind,:) = [];
    [r p] = corr(corrdata);
    ylabel('pitch');xlabel('bout position');
    title(['bout ',motif]);
    set(gca,'fontweight','bold');
    m = polyfit(corrdata(:,1), corrdata(:,2),1);
    refline(m(1),m(2));hold on;
    ylim = get(gca,'ylim');
    xlim = get(gca,'xlim');
    text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
end
