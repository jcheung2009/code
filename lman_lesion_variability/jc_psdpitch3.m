function [post_psd pre_psd] = jc_psdpitch3(pre_cell, post_cell, norm,pltit)
%9_7_2014
%uses pwelch to find psd for each vector in pre and post
%slides nfft sized hamming window across input with 50% overlap
%norm is either 'z' or 'm' for zscore or mean subtract normalization


%% normalize amplitude (mean subtract or zscore norm) 
if strcmp(norm,'z') == 1 %z score
    std_p = mean(cellfun(@(x) std(x(:,2)), pre_cell));%taking average standard deviation of pre lesion condition, maintains relative change in variability between pre and post
    
    for i = 1:length(pre_cell)
        pre_cell{i}(:,2) = (pre_cell{i}(:,2) - mean(pre_cell{i}(:,2)))/std_p;
    end
    
    for i = 1:length(post_cell);
        post_cell{i}(:,2) = (post_cell{i}(:,2) - mean(post_cell{i}(:,2)))/std_p;
    end
elseif strcmp(norm,'m') == 1 %mean subtract
        
    for i = 1:length(pre_cell)
        pre_cell{i}(:,2) = (pre_cell{i}(:,2)-mean(pre_cell{i}(:,2)));
    end

    for i = 1:length(post_cell);
        post_cell{i}(:,2) = (post_cell{i}(:,2)-mean(post_cell{i}(:,2)));
    end

end

%% Determine nfft length: smallest vector length from both conditions

nfft = min([min(cellfun(@length,pre_cell)), min(cellfun(@length, post_cell))]);
if mod(nfft,2) == 1
    nfft = nfft - 1;
end

%% find PSD for each vector in cell

prepsd = zeros(nfft/2+1,length(pre_cell));
fs = 1; %1 sample per rendition 

for i = 1:length(pre_cell)
        [pxx f] = pwelch(pre_cell{i}(:,2),nfft,'',nfft,fs);
        prepsd(:,i) = 10*log10(pxx);
end

postpsd = zeros(nfft/2+1,length(post_cell));
fs = 1; %1 sample per rendition 

for i = 1:length(post_cell)
        [pxx f] = pwelch(post_cell{i}(:,2),nfft,'',nfft,fs);
        postpsd(:,i) = 10*log10(pxx);
end

%% find average PSDs of shuffled vectors in each cell
alpha = 0.95;
repnum = 1000;

shuff_prepsd = zeros(nfft/2+1,1000);%1000 reps of average PSDs from shuffled pre data
for i = 1:repnum
    shuffpsd = zeros(nfft/2+1,length(pre_cell));%shuffled vectors
    for ii = 1:length(pre_cell)
        thesamp = pre_cell{ii}((randi(length(pre_cell{ii}),1,length(pre_cell{ii}))),2);
        [pxx f] = pwelch(thesamp,nfft,'',nfft,fs);
        shuffpsd(:,ii) = 10*log10(pxx);
    end
    shuff_prepsd(:,i) = mean(shuffpsd,2); %average shuffled vectors
end

shuff_prepsd = sort(shuff_prepsd,2);
shuff_prepsd_hi = shuff_prepsd(:,fix(alpha*repnum));
shuff_prepsd_lo = shuff_prepsd(:,fix((1-alpha)*repnum));


shuff_postpsd = zeros(nfft/2+1,1000); %1000 reps of averaged PSDs from shuffled post data
for i = 1:repnum
    
    shuffpsd = zeros(nfft/2+1,length(post_cell));
    for ii = 1:length(post_cell)
        thesamp = post_cell{ii}((randi(length(post_cell{ii}),1,length(post_cell{ii}))),2);
        [pxx f] = pwelch(thesamp,nfft,'',nfft,fs);
        shuffpsd(:,ii) = 10*log10(pxx);
    end
    shuff_postpsd(:,i) = mean(shuffpsd,2);
end

shuff_postpsd = sort(shuff_postpsd,2);
shuff_postpsd_hi = shuff_postpsd(:,fix(alpha*repnum));
shuff_postpsd_lo = shuff_postpsd(:,fix((1-alpha)*repnum));

post_psd.psd = postpsd;
post_psd.freq = f;
post_psd.hi = shuff_postpsd_hi;
post_psd.lo = shuff_postpsd_lo;

pre_psd.psd = prepsd;
pre_psd.freq = f;
pre_psd.hi = shuff_prepsd_hi;
pre_psd.lo = shuff_prepsd_lo;

%% plot it
if pltit ~= 0
    figure(pltit);hold on;
    plot(pre_psd.freq,mean(pre_psd.psd,2),'k');hold on;
    plot(pre_psd.freq,mean(pre_psd.psd,2)+stderr(pre_psd.psd,2),'k');hold on;
    plot(pre_psd.freq,mean(pre_psd.psd,2)-stderr(pre_psd.psd,2),'k');hold on;
    
    plot(post_psd.freq,mean(post_psd.psd,2),'r');hold on;
    plot(post_psd.freq,mean(post_psd.psd,2)+stderr(post_psd.psd,2),'r');hold on;
    plot(post_psd.freq,mean(post_psd.psd,2)-stderr(post_psd.psd,2),'r');hold on;
    
        
    plot(pre_psd.freq,pre_psd.hi,'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(pre_psd.freq,pre_psd.lo,'Color',[0.8 0.8 0.8],'LineWidth',2);hold on;
    plot(post_psd.freq,post_psd.hi,'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
    plot(post_psd.freq,post_psd.lo,'Color',[255/255 160/255 122/255],'LineWidth',2);hold on;
   
end

    


    

        
        
    
