function [indCell gapdistr] = jc_clusterbouts(tb,pitchdata,restlength,plthist,pltraster,pltbouts,pltboutrend)
%LMAN data
%tb is the timebase for vectors in inCell 
%gapdistr: distribution of interval times between consecutive renditions of
%target syllable, used to find cutoff for bout clusters
%indCell: cell with indices for bout clusters for tb and pitchdata 
%restlength = in seconds, time elapsed between bouts 
%plthist = plots distribution of gaps to determine restlength
%pltraster = plots syllable times by bout number 
%pltbouts = plots bouts by time
%pltboutrend = plots bouts by rendition

if isempty(restlength)
    gapdistr = [];
    for i = 1:length(tb)
        gapdistr = [gapdistr; diff(tb{i})];
    end
    
    if ~isempty(plthist)
        %gapdistr = gapdistr(gapdistr > 5);
        figure(plthist);subplot(1,2,1);hold on;
        [n b] = hist(gapdistr,[0:1:2000]);plot(b,n/sum(n),'k');
        figure(plthist);subplot(1,2,2);hold on;
        plot(b,cumsum(n/sum(n)),'k');
%         [n b] = hist(gapdistr,[0:1:2000]);plot(log10(b),log10(n/sum(n)),'k');
%         set(gca,'XTick',[0:1:4],'XTickLabel',strtrim(cellstr(num2str(10.^[0:4]'))));
%         figure(plthist);subplot(1,2,2);hold on;
%         plot(log10(b),cumsum(n/sum(n)),'k');
%         set(gca,'XTick',[0:4],'XTickLabel',strtrim(cellstr(num2str(10.^[0:4]'))));
    end
    
    [n b] = hist(gapdistr,[0:1:2000]);
    ind = find(cumsum(n/sum(n)) <= 0.95);
    fprintf('95 percent cutoff: %f\r',b(ind(end)));
    s = input('restlength?');
    restlength = s;
    
else    
    restlength = 300;%use 5 minute intervals to define bouts 
end


for i = 1:length(tb)
    ind = find(diff(tb{i})>= restlength);
    endpts = [ind;length(tb{i})];
    stpts = 1+[0;ind];
    if length(stpts) == length(endpts)
        indCell{i} = NaN(1,length(tb{i}));
        for ii = 1:length(stpts)
            indCell{i}(stpts(ii):endpts(ii)) = ii*ones(1,endpts(ii)-stpts(ii)+1);
        end
    else
        disp('number of bout endpoints and start points do not match, cell number:');
        disp(i);
    end
end

%use same colormap for all plots
for i = 1:length(tb)
    cmap{i} = hsv(max(indCell{i}));
    cmap{i} = cmap{i}(randperm(max(indCell{i})),:);
end

%plot syllable times vs bout number
if ~isempty(pltraster)
    for i = 1:length(tb)
        for ii = 1:max(indCell{i})
            figure(pltraster);subtightplot(length(tb),1,i);hold on;
            plot(tb{i}(indCell{i}==ii),ii*ones(sum(indCell{i}==ii)),'.','color',cmap{i}(ii,:));
        end
    end
end

%plotting bouts by time
if ~isempty(pltbouts)
    for i = 1:length(tb)
        for ii = 1:max(indCell{i})
            figure(pltbouts);subtightplot(length(tb),1,i);hold on;
            plot(tb{i}(indCell{i}==ii),pitchdata{i}(indCell{i}==ii,2),'.','color',cmap{i}(ii,:));
        end
    end
end

%plot bouts by renditions
if ~isempty(pltboutrend)
    for i = 1:length(tb);
        xvals = 1:1:length(indCell{i});
        for ii = 1:max(indCell{i})
            figure(pltboutrend);subtightplot(length(tb),1,i);hold on;
            plot(xvals(indCell{i}==ii),pitchdata{i}(indCell{i}==ii,2),'.','color',cmap{i}(ii,:));
            plot(xvals(indCell{i}==ii),pitchdata{i}(indCell{i}==ii,2),'color',cmap{i}(ii,:));
        end
    end
end

    





%% cluster using kmeans
% numclustmin = 5;
% numclustmax = 20;
% indCell = cell(length(tb));
% for i = 1:length(tb)
%     silh = [];
%     %get silhouette scores across different number of clusters
%     for ii = numclustmin:numclustmax 
%         [ind, ~, sumD] = kmeans(tb{i},ii);
%         silh = cat(1,silh,[mean(silhouette(tb{i},ind)) cv(silhouette(tb{i},ind)) mean(sumD)]);
%     end
%     
%     [c idx] = max(silh(:,1));
%     ind = kmeans(tb{i},numclustmin+idx-1);%use cluster number with max silhouette score for kmeans 
%     
%     cmap = hsv(max(ind));
%     xvals = 1:1:length(tb{i});
%     figure(1);clf
%     for ii = 1:max(ind)
%         %clustsize = sum(ind == ii);
%         figure(1);hold on;
%         plot(xvals(ind==ii),tb{i}(ind == ii),'.','color',cmap(ii,:),'MarkerSize',20);hold on;
%     end
%     
%     str = input('Is the number of clusters ok? Y/N:','s');
%         if str == 'Y'
%             indCell{i} = ind;
%         else 
%             while str == 'N'
%             result = input('Use how many clusters?:');
%             ind = kmeans(tb{i},result);
%             indCell{i} = ind;
%             cmap = hsv(max(ind));
%                 for iii = 1:max(ind)
%                     figure(1);hold on;
%                     plot(xvals(ind==iii),tb{i}(ind == iii),'.','color',cmap(iii,:),'MarkerSize',20);hold on;
%                 end
%             str = input('Is the number of clusters ok? Y/N:','s')
%             end
%         end
% end


    

        
            
        