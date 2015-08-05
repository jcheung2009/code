function [cv_pre cvrun_pre cv_post cvrun_post] = cv_runavg(pre,post,pltit);
%trial by trial variability: measures CV by ssd of each point from running average computed from all
%possible window sizes 
%drift: measures the ssd of runavg from 0 

%% for pre data
if ~iscell(pre)
    pre = pre - mean(pre); %mean subtract
    cv_pre = zeros(length(pre),2); %vector for sum squared deviation from running average
    cvrun_pre = zeros(length(pre),2); %vector for sum squared deviation from within day average (0)
    for i = 1:length(pre)
        runavg = conv(pre,ones(i,1)/i,'same');%zero pads the ends 
        sqdev = (pre - runavg).^2;
        ssd = sum(sqdev)/(length(pre)-1);
        cv_pre(i,:) = [i, ssd];
        cvrun_pre(i,:) = [i, sum(runavg.^2)/(length(pre)-1)];
    end

else
     cv_pre = {};
     cvrun_pre = {};
    for i = 1:length(pre)
            cv_pre{i} = zeros(length(pre{i}),1);
            cvrun_pre{i} = zeros(length(pre{i}),1);
            pre{i}(:,2) = pre{i}(:,2) - mean(pre{i}(:,2)); %mean subtract
        for ii = 1:length(pre{i})
            runavg = conv(pre{i}(:,2),ones(ii,1)/ii,'same');
            sqdev = (pre{i}(:,2) - runavg).^2;
            ssd = sum(sqdev)/(length(pre{i})-1);%cv
            cv_pre{i}(ii) = ssd;
            cvrun_pre{i}(ii) = sum(runavg.^2)/(length(pre{i}-1));%ssd of runavg from '0'
        end
    end
    
    maxlength_x = max(cellfun(@(x)length(x),cv_pre));
    cv_pre = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlength_x-length(x),1)),cv_pre,'UniformOutput',false));
    maxlength_y = max(cellfun(@(x)length(x),cvrun_pre));
    cvrun_pre = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlength_x-length(x),1)),cvrun_pre,'UniformOutput',false));
end

%% for post data
if ~iscell(post)
    post = post - mean(post);
    cv_post = zeros(length(post),2); %vector for sum squared deviation from running average
    cvrun_post = zeros(length(post),2); %vector for sum squared deviation from within day average (0)
    for i = 1:length(post)
        runavg = conv(post,ones(i,1)/i,'same');
        sqdev = (post - runavg).^2;
        ssd = sum(sqdev)/(length(post)-1);
        cv_post(i,:) = [i, ssd];
        cvrun_post(i,:) = [i, sum(runavg.^2)/(length(post)-1)];
    end

else
     cv_post = {};
     cvrun_post = {};
    for i = 1:length(post)
            cv_post{i} = zeros(length(post{i}),1);
            cvrun_post{i} = zeros(length(post{i}),1);
            post{i}(:,2) = post{i}(:,2) - mean(post{i}(:,2)); %mean subtract
        for ii = 1:length(post{i})
            runavg = conv(post{i}(:,2),ones(ii,1)/ii,'same');
            sqdev = (post{i}(:,2) - runavg).^2;
            ssd = sum(sqdev)/(length(post{i})-1);%cv
            cv_post{i}(ii) = ssd;
            cvrun_post{i}(ii) = sum(runavg.^2)/(length(post{i}-1));%ssd of runavg from '0'
        end
    end
    
    maxlength_x = max(cellfun(@(x)length(x),cv_post));
    cv_post = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlength_x-length(x),1)),cv_post,'UniformOutput',false));
    maxlength_y = max(cellfun(@(x)length(x),cvrun_post));
    cvrun_post = cell2mat(cellfun(@(x)cat(1,x,NaN(maxlength_x-length(x),1)),cvrun_post,'UniformOutput',false));
end


if pltit ~= 0
    %normalize to pre 
    cv_pre_n = cv_pre./nanmean(cv_pre(end,:));
    cv_post_n = cv_post./nanmean(cv_pre(end,:));
    cvrun_pre_n = cvrun_pre./nanmean(cvrun_pre(1,:));
    cvrun_post_n = cvrun_post./nanmean(cvrun_pre(1,:));
    
    figure(pltit);hold on;
    plot(nanmean(cv_pre_n,2),'k');hold on;
    plot(nanmean(cv_pre_n,2)+nanstderr(cv_pre_n,2),'k');hold on;
    plot(nanmean(cv_pre_n,2)-nanstderr(cv_pre_n,2),'k');hold on;
    plot(nanmean(cv_post_n,2),'r');hold on;
    plot(nanmean(cv_post_n,2)+nanstderr(cv_post_n,2),'r');hold on;
    plot(nanmean(cv_post_n,2)-nanstderr(cv_post_n,2),'r');hold on;
    
    plot(nanmean(cvrun_pre_n,2),'k');hold on;
    plot(nanmean(cvrun_pre_n,2)+nanstderr(cvrun_pre_n,2),'k');hold on;
    plot(nanmean(cvrun_pre_n,2)-nanstderr(cvrun_pre_n,2),'k');hold on;
    plot(nanmean(cvrun_post_n,2),'r');hold on;
    plot(nanmean(cvrun_post_n,2)+nanstderr(cvrun_post_n,2),'r');hold on;
    plot(nanmean(cvrun_post_n,2)-nanstderr(cvrun_post_n,2),'r');hold on;
    
end


