function [precorr postcorr shuffpre shuffpost] = jc_pitchcorr6(pre,post, pltit)
%9_5_2014
%cross covariance (mean subtracts) and divides by product of STD adjusted
%for lag = correlation coefficient 

lag = min([min(cellfun(@length,post,'UniformOutput',true)) min(cellfun(@length,pre,'UniformOutput',true))]);%uses minimum renditions produced in either pre and post condition 

precorr = jc_pitchcorr5(pre,lag);
postcorr = jc_pitchcorr5(post,lag);

%shuffled
numbootstraps = 1000;
shuff_precorravg = zeros(length(precorr),numbootstraps);
shuff_postcorravg = zeros(length(postcorr),numbootstraps);

for i = 1:numbootstraps
 
    shuffprecorr = zeros(length(precorr),length(pre));
    for ii = 1:length(pre)
        shuff = pre{ii}((randi(length(pre{ii}),1,length(pre{ii}))),2);
        shuffcorr = jc_pitchcorr5(shuff,lag);
        shuffprecorr(:,ii) = shuffcorr;
    end
    
    shuff_precorravg(:,i) = nanmean(shuffprecorr,2);%takes average of one round of shuffling pre cell 
    
     shuffpostcorr = zeros(length(postcorr),length(post));
    for ii = 1:length(post)
        shuff = post{ii}((randi(length(post{ii}),1,length(post{ii}))),2);
        shuffcorr = jc_pitchcorr5(shuff,lag);
        shuffpostcorr(:,ii) = shuffcorr;
    end
    
    shuff_postcorravg(:,i) = nanmean(shuffpostcorr,2);
    
end

shuffpre = sort(shuff_precorravg,2);
shuffpost = sort(shuff_postcorravg,2);

%% plot 
if pltit ~= 0
    figure(pltit);hold on;
    plot(nanmean(precorr,2),'k');hold on;
    plot(nanmean(precorr,2)+nanstderr(precorr,2),'k');hold on;
    plot(nanmean(precorr,2)-nanstderr(precorr,2),'k');hold on;
    plot(nanmean(postcorr,2),'r');hold on;
    plot(nanmean(postcorr,2)+nanstderr(postcorr,2),'r');hold on;
    plot(nanmean(postcorr,2)-nanstderr(postcorr,2),'r');hold on;
    
    plot(shuffpre(:,950),'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(shuffpre(:,50),'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(shuffpost(:,950),'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
    plot(shuffpost(:,50),'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
   
    
end