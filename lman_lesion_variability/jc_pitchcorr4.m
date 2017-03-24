function [precov1 postcov1 shuffpre shuffpost] = jc_pitchcorr4(pre,post, pltit)
%pre and post are pooled zscores for all trials across all birds,
%normalized variance in both conditions
%cross covariance 

lag = min([min(cellfun(@length,post,'UniformOutput',true)) min(cellfun(@length,pre,'UniformOutput',true))]);



%cross covariance
for i = 1:length(pre)
    covar = xcov(pre{i},lag,'unbiased');
    precov{i} = covar(ceil(length(covar)/2):end);
end

for i = 1:length(post)
    covar = xcov(post{i},lag,'unbiased');
    postcov{i} = covar(ceil(length(covar)/2):end);
end

%pad ends of precov and postcov with NaNs
[maxlength ind] = max(cellfun(@length, precov,'UniformOutput',true));
precov1 = zeros(maxlength,length(precov));
for i = 1:length(precov)
    numpad = (maxlength - length(precov{i}));
    precov1(:,i) = [precov{i}; NaN(numpad,1)];
end

[maxlength ind] = max(cellfun(@length, postcov,'UniformOutput',true));
postcov1 = zeros(maxlength,length(postcov));
for i = 1:length(postcov)
    numpad = (maxlength - length(postcov{i}));
    postcov1(:,i) = [postcov{i}; NaN(numpad,1)];
end

% shuffled 
numbootstraps = 1000;
shuff_precorravg = zeros(length(precov1),numbootstraps);
shuff_postcorravg = zeros(length(postcov1),numbootstraps);
for i = 1:numbootstraps
 
    shuffprecorr = zeros(length(precov1),length(pre));
    for ii = 1:length(pre)
        shuff = pre{ii}((randi(length(pre{ii}),1,length(pre{ii}))));
        shuffcorr = xcov(shuff,lag,'unbiased');
        shuffcorr = shuffcorr(ceil(length(shuffcorr)/2):end);
        numpad = length(precov1) - length(shuffcorr);
        shuffprecorr(:,ii) = [shuffcorr; NaN(numpad,1)];
    end
    
    shuff_precorravg(:,i) = nanmean(shuffprecorr,2); %takes average of one round of shuffling pre cell 
    
    shuffpostcorr = zeros(length(postcov1),length(post));
    for ii = 1:length(post)
        shuff = post{ii}((randi(length(post{ii}),1,length(post{ii}))));
        shuffcorr = xcov(shuff,lag,'unbiased');
        shuffcorr = shuffcorr(ceil(length(shuffcorr)/2):end);
        numpad = length(postcov1) - length(shuffcorr);
        shuffpostcorr(:,ii) = [shuffcorr; NaN(numpad,1)];
    end
    
    shuff_postcorravg(:,i) = nanmean(shuffpostcorr,2);
    
end

shuffpre = sort(shuff_precorravg,2);
shuffpost = sort(shuff_postcorravg,2);

%% plot 
if pltit == 1
    figure(1);hold on;
    plot(nanmean(precov1,2),'k');hold on;
    plot(nanmean(precov1,2)+nanstderr(precov1,2),'k');hold on;
    plot(nanmean(precov1,2)-nanstderr(precov1,2),'k');hold on;
    plot(nanmean(postcov1,2),'r');hold on;
    plot(nanmean(postcov1,2)+nanstderr(postcov1,2),'r');hold on;
    plot(nanmean(postcov1,2)-nanstderr(postcov1,2),'r');hold on;
    
    plot(shuffpre(:,950),'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(shuffpre(:,50),'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(shuffpost(:,950),'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
    plot(shuffpost(:,50),'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
   
    
end
