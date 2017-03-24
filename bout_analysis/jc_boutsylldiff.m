function [boutsyll cumboutdiff first2sylldiff adjsylldiff] = jc_boutsylldiff(indCell,incell,pltit,lstyle)
%boutsyll: finds the pitch of each syllable in every bout
% cumboutdiff: finds the overall pitch difference in each bout 
% first2sylldiff: finds the difference between the first two syllables in a
% bout
%adjsylldiff: finds the pitch difference between all adjacent syllables in
%each bout

%each cell in boutsylldiffindCell/incell represents a day of song
%each cell within a cell in boutsylldiff is a vector of pitches for each
%syllable in a bout, number of subcells = number of bouts
boutsyll = cell(size(indCell));
for i = 1:length(indCell)
    boutsyll{i} = cell(size(max(indCell{i})));
    for ii = 1:max(indCell{i})
        boutsyll{i}{ii} = incell{i}(find(indCell{i}==ii),2);
    end
end

%cumulative pitch differences in each bout
%pitch difference in first and second syllables in each bout
cumboutdiff = cell(size(indCell));
first2sylldiff = cell(size(indCell));
adjsylldiff = cell(size(indCell));
%cumsumsylldiff = cell(size(indCell));
for i = 1:length(boutsyll)
    cumboutdiff{i} = cell(size(boutsyll{i}));
    first2sylldiff{i} = cell(size(boutsyll{i}));
    adjsylldiff{i} = cell(size(boutsyll{i}));
    %cumsumsylldiff{i} = cell(size(boutsyll{i}));
    for ii = 1:length(boutsyll{i})
        if length(boutsyll{i}{ii}) < 2
            cumboutdiff{i}{ii} = [];
            first2sylldiff{i}{ii} = [];
            adjsylldiff{i}{ii} = [];
            %cumsumsylldiff{i}{ii} = [];
        else
            cumboutdiff{i}{ii} = sum(diff(boutsyll{i}{ii}));
            first2sylldiff{i}{ii} = diff(boutsyll{i}{ii}(1:2))/sum(diff(boutsyll{i}{ii}));
            adjsylldiff{i}{ii} = diff(boutsyll{i}{ii})/sum(diff(boutsyll{i}{ii}));
            %cumsumsylldiff{i}{ii} = cumsum(diff(boutsyll{i}{ii}))/sum(diff(boutsyll{i}{ii}));
        end
    end
    cumboutdiff{i} = vertcat(cumboutdiff{i}{:});
    first2sylldiff{i} = vertcat(first2sylldiff{i}{:});
    adjsylldiff{i} = vertcat(adjsylldiff{i}{:});
    
    %maxlength = max(cellfun(@length, cumsumsylldiff{i})); 
    %cumsumsylldiff{i} = cellfun(@(x) [x;NaN(maxlength-length(x),1)],cumsumsylldiff{i},'UniformOutput',false);
    %cumsumsylldiff{i} = horzcat(cumsumsylldiff{i}{:});
end
cumboutdiff = vertcat(cumboutdiff{:});
first2sylldiff = vertcat(first2sylldiff{:});
adjsylldiff = vertcat(adjsylldiff{:});

adjsylldiff = adjsylldiff(find(adjsylldiff>-3 & adjsylldiff<3));
first2sylldiff = first2sylldiff(find(first2sylldiff>-3 & first2sylldiff<3))

%plot distribution of pitch differences in bout
if ~isempty(pltit)
%     maxdiff = max(cumboutdiff);
%     mindiff = min(cumboutdiff);
%     figure(pltit);hold on;subplot(1,2,1);
%     [n b] = hist(cumboutdiff,[mindiff:5:maxdiff]);
%     stairs(b,n/sum(n),'k','LineWidth',3);
%     figure(pltit);hold on;subplot(1,2,1);
%     [n b] = hist(first2sylldiff,[mindiff:5:maxdiff]);
%     stairs(b,n/sum(n),'r','LineWidth',3);
%     figure(pltit);hold on;subplot(1,2,1);
%     [n b] = hist(adjsylldiff,[mindiff:5:maxdiff]);
%     stairs(b,n/sum(n),'b','LineWidth',3);
%     
%     maxdiff = max(adjsylldiff);
%     mindiff = min(first2sylldiff);
    maxdiff = max(cumboutdiff);
    mindiff = min(cumboutdiff);
    figure(pltit);hold on;subplot(1,2,1);
    [n b] = hist(cumboutdiff,[mindiff:5:maxdiff]);
    if lstyle == 1
        stairs(b,n/sum(n),'k','LineWidth',3);
    elseif lstyle == 2
        stairs(b,n/sum(n),'k','LineWidth',3,'LineStyle',':');
    end
    figure(pltit);hold on;subplot(1,2,2);
    [n b] = hist(first2sylldiff,[-3:0.1:3]);
    if lstyle == 1
        stairs(b,n/sum(n),'r','LineWidth',3);
    elseif lstyle == 2
        stairs(b,n/sum(n),'r','LineWidth',3,'LineStyle',':');
    end
    figure(pltit);hold on;subplot(1,2,2);
    [n b] = hist(adjsylldiff,[-3:0.1:3]);
    if lstyle == 1
        stairs(b,n/sum(n),'b','LineWidth',3);
    elseif lstyle == 2
        stairs(b,n/sum(n),'b','LineWidth',3,'LineStyle',':');
    end
%     cmap = hsv(length(cumsumsylldiff));
%     for i = 1:length(cumsumsylldiff)
%         figure(pltit);hold on;subplot(1,2,2);
%         plot(nanmean(cumsumsylldiff{i},2),'color',cmap(i,:));
%         plot(nanmean(cumsumsylldiff{i},2)+nanstderr(cumsumsylldiff{i},2),'color',cmap(i,:));
%         plot(nanmean(cumsumsylldiff{i},2)-nanstderr(cumsumsylldiff{i},2),'color',cmap(i,:));
%     end
end
    
   