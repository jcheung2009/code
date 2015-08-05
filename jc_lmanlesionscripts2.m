tb = post_tb;
datcell = post;
indCell = ind;

%plot mean-subtracted pitch data with bouts in different colors
figure(6);hold on;
for i = 1:length(tb)
    ynorm = datcell{i}(:,2) - mean(datcell{i}(:,2));
    cmap = hsv(max(indCell{i}));
    xvals = 1:1:length(tb{i});
    for ii = 1:max(indCell{i})
        figure(6);hold on;subplot(length(datcell),1,i);
        plot(xvals(indCell{i}==ii),ynorm(indCell{i}==ii),'color',cmap(ii,:));
    end
end

%overlay mean-subtracted pitch data on top of each other 
figure(5);hold on;
for i = 1:length(datcell)
    ynorm = datcell{i}(:,2) - mean(datcell{i}(:,2));
    cmap = hsv(max(indCell{i}));
    for ii = 1:max(indCell{i})
        boutvals = ynorm(indCell{i}==ii);
        boutvals = boutvals - boutvals(1);
        figure(5);hold on;
        plot([1 2],[boutvals(1) boutvals(end)],'color',cmap(ii,:));xlim([0.5 2.5])
    end
end

%plot abs difference between bout start and last bout end 
diff_btwn_bouts = [];
for i = 1:length(indCell)
    ynorm = datcell{i}(:,2) - mean(datcell{i}(:,2));
    endpts = find(diff(indCell{i})==1);
    endpts = [endpts length(tb{i})];
    stpts = 1+[0 find(diff(indCell{i})==1)];
    
    for ii = 1:max(indCell{i})-1
        diff_btwn_bouts = cat(2,diff_btwn_bouts,abs(stpts(ii+1)-endpts(ii)));
    end 
end

        