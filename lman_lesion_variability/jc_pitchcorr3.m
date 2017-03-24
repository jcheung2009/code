function [precorr1 postcorr1 shuffpre shuffpost] = jc_pitchcorr3(pre,post, pltit,fig)
%autocorrelation without normalizing to lag 0, taking serial R
%precorr2 and postcorr2 computed using unbiased autocorrelation from xcov
%and normalizing by product of std 


%% auto correlation, one sided, cov/variance at lag 0 
lag = min([min(cellfun(@length,post,'UniformOutput',true)) min(cellfun(@length,pre,'UniformOutput',true))]);

for i = 1:length(pre)
    covar = xcov(pre{i}(:,2),lag,'unbiased');
    covar = covar./var(pre{i}(:,2));
    pre_corr1{i} = covar(ceil(length(covar)/2):end);
end

for i = 1:length(post)
    covar = xcov(post{i}(:,2),lag,'unbiased');
    covar = covar./var(post{i}(:,2));
    post_corr1{i} = covar(ceil(length(covar)/2):end);
end
    
%for i = 1:length(pre)    
%     pre_n = pre{i}(:,2) - mean(pre{i}(:,2));% mean subtract before sliding
%     for ii = 1:length(pre_n) %ii -1 = lag
%         %sum[(x-x)*(y-y)]/N-1/std(x)*std(y)
%         pre_corr1{i}(ii,1) = sum([zeros(ii-1,1);pre_n].*[pre_n;zeros(ii-1,1)])/(length(pre_n)-(ii-1));
%         pre_corr1{i}(ii,1) = pre_corr1{i}(ii)./(std(pre_n)*std(pre_n));
%     end
%end


% for i = 1:length(post)
%     post_n = post{i}(:,2) - mean(post{i}(:,2));
%     for ii = 1:length(post_n)
%         post_corr1{i}(ii,1) = sum([zeros(ii-1,1);post_n].*[post_n;zeros(ii-1,1)])/(length(post_n)-(ii-1));
%         post_corr1{i}(ii,1) = post_corr1{i}(ii)./(std(post_n)*std(post_n));
%     end
% end
    
% pad ends of pre_corr1 and post_corr1 with NaNs to make vector lengths same
[maxlength ind] = max(cellfun(@length, pre_corr1,'UniformOutput',true));
precorr1 = zeros(maxlength,length(pre_corr1));
for i = 1:length(pre_corr1)
    numpad = (maxlength - length(pre_corr1{i}));
    precorr1(:,i) = [pre_corr1{i}; NaN(numpad,1)];
end

[maxlength ind] = max(cellfun(@length, post_corr1,'UniformOutput',true));
postcorr1 = zeros(maxlength,length(post_corr1));
for i = 1:length(post_corr1)
    numpad = (maxlength - length(post_corr1{i}));
    postcorr1(:,i) = [post_corr1{i}; NaN(numpad,1)];
end


%% shuffled 
numbootstraps = 1000;
shuff_precorravg = zeros(length(precorr1),numbootstraps);
shuff_postcorravg = zeros(length(postcorr1),numbootstraps);
for i = 1:numbootstraps
 
    shuffprecorr = zeros(length(precorr1),length(pre));
    for ii = 1:length(pre)
        shuff = pre{ii}((randi(length(pre{ii}),1,length(pre{ii}))),2);
        shuffcorr = xcov(shuff,lag,'unbiased');
        shuffcorr = shuffcorr./(var(shuff));
        shuffcorr = shuffcorr(ceil(length(shuffcorr)/2):end);
        numpad = length(precorr1) - length(shuffcorr);
        shuffprecorr(:,ii) = [shuffcorr; NaN(numpad,1)];
    end
    
    shuff_precorravg(:,i) = nanmean(shuffprecorr,2); %takes average of one round of shuffling pre cell 
    
    shuffpostcorr = zeros(length(postcorr1),length(post));
    for ii = 1:length(post)
        shuff = post{ii}((randi(length(post{ii}),1,length(post{ii}))),2);
        shuffcorr = xcov(shuff,lag,'unbiased');
        shuffcorr = shuffcorr./(var(shuff));
        shuffcorr = shuffcorr(ceil(length(shuffcorr)/2):end);
        numpad = length(postcorr1) - length(shuffcorr);
        shuffpostcorr(:,ii) = [shuffcorr; NaN(numpad,1)];
    end
    
    shuff_postcorravg(:,i) = nanmean(shuffpostcorr,2);
    
end

shuffpre = sort(shuff_precorravg,2);
shuffpost = sort(shuff_postcorravg,2);

%% plot 
if pltit == 1
    figure(fig);hold on;
    plot(nanmean(precorr1,2),'k');hold on;
    plot(nanmean(precorr1,2)+nanstderr(precorr1,2),'k');hold on;
    plot(nanmean(precorr1,2)-nanstderr(precorr1,2),'k');hold on;
    plot(nanmean(postcorr1,2),'r');hold on;
    plot(nanmean(postcorr1,2)+nanstderr(postcorr1,2),'r');hold on;
    plot(nanmean(postcorr1,2)-nanstderr(postcorr1,2),'r');hold on;
    
    plot(shuffpre(:,950),'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(shuffpre(:,50),'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(shuffpost(:,950),'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
    plot(shuffpost(:,50),'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
   
    
end

