function [post_psd pre_psd] = jc_psdpitch(pre_cell, post_cell, norm_y_n,pltit)
%does not interpolate, fs = 1 Hz
%absolute power/nfft = power in each frequency bin = power/hz


%% normalize amplitude (mean subtract or zscore norm) 


if strcmp(norm_y_n,'y') == 1
    std_p = mean(cellfun(@(x) std(x(:,2)), pre_cell));
    
    for i = 1:length(pre_cell)
        pre_cell{i}(:,2) = (pre_cell{i}(:,2) - mean(pre_cell{i}(:,2)))/std_p;
    end
    
    for i = 1:length(post_cell);
        post_cell{i}(:,2) = (post_cell{i}(:,2) - mean(post_cell{i}(:,2)))/std_p;
    end
    %     for i = 1:length(pre_cell)
%         pre_cell{i}(:,2) = (pre_cell{i}(:,2)-mean(pre_cell{i}(:,2)));
%     end
% 
%     for i = 1:length(post_cell);
%         post_cell{i}(:,2) = (post_cell{i}(:,2)-mean(post_cell{i}(:,2)));
%     end

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
    if length(pre_cell{i}) == nfft
        %y = fft(pre_cell{i}.*hamming(nfft),nfft);
         y = fft(pre_cell{i}(:,2).*hamming(nfft),nfft);
        y = y(1:nfft/2+1);
        psdx = (1/(fs*nfft)).*abs(y).^2;%normalized by window size and fs before squaring, final result = power/Hz
        psdx(2:end-1) = 2*psdx(2:end-1);%doubling the power because only plotting one side 
        psdx = 10*log10(psdx); %turns into decibels
        prepsd(:,i) = psdx;
        
    elseif length(pre_cell{i}) < nfft %if vector length is less than nfft window, then padd end with 0's so that you can apply the hamming
      %  pad_interp = padarray(pre_cell{i},[nfft-length(pre_cell{i}) 0],'post');
          pad_interp = padarray(pre_cell{i}(:,2),[nfft-length(pre_cell{i}) 0],'post');
        y = fft(pad_interp(1:nfft).*hamming(nfft),nfft);
        y = y(1:nfft/2+1);
        psdx = (1/(fs*nfft)).*abs(y).^2;%normalized by window size and fs, so power = power/hz
        psdx(2:end-1) = 2*psdx(2:end-1); 
        psdx = 10*log10(psdx);
        %psdx = psdx./sum(psdx);
        prepsd(:,i) = psdx;
        
    elseif length(pre_cell{i}) > nfft %if vector length is greater than nfft window, find average PSD from sliding overlapping nfft
        noverlap = nfft/2;% 50% overlap
        %[pre_seg z] = buffer(pre_cell{i},nfft,noverlap,'nodelay');%pre_seg only has full frames, z is leftover buffer
         [pre_seg z] = buffer(pre_cell{i}(:,2),nfft,noverlap,'nodelay');
        fft_preseg = zeros(nfft/2+1,size(pre_seg,2));%find fft for each overalpping segment
        for ii = 1:size(pre_seg,2)
            y = fft(pre_seg(:,ii).*hamming(nfft),nfft);
            y = y(1:nfft/2+1);
            psdx = (1/(fs*nfft)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            %psdx = psdx./sum(psdx);
            fft_preseg(:,ii) = psdx;
        end
        
            prepsd(:,i) = mean(fft_preseg,2);%average fft for each overlapping segment to find average PSD for that vector 
        
    end
    
end

%%find PSD for each vector in post-cell

postpsd = zeros(nfft/2+1,length(post_cell));
for i = 1:length(post_cell)
    if length(post_cell{i}) == nfft
        %y = fft(post_cell{i}.*hamming(nfft),nfft);
        y = fft(post_cell{i}(:,2).*hamming(nfft),nfft);
        
        y = y(1:nfft/2+1);
        psdx = (1/(fs*nfft)).*abs(y).^2;%normalized by window size and fs, so power = power/hz
        psdx(2:end-1) = 2*psdx(2:end-1); 
        psdx = 10*log10(psdx);
        %psdx = psdx./sum(psdx);
        postpsd(:,i) = psdx;
        
    elseif length(post_cell{i}) < nfft
       %pad_interp = padarray(post_cell{i},[nfft-length(post_cell{i}) 0],'post');
      pad_interp = padarray(post_cell{i}(:,2),[nfft-length(post_cell{i}) 0],'post');
       y = fft(pad_interp(1:nfft).*hamming(nfft),nfft);
       y = y(1:nfft/2+1);
       psdx = (1/(fs*nfft)).*abs(y).^2;
       psdx(2:end-1) = 2*psdx(2:end-1); 
       psdx = 10*log10(psdx);
       %psdx = psdx./sum(psdx);
       postpsd(:,i) = psdx;
    
    elseif length(post_cell{i}) > nfft
        noverlap = nfft/2;
        %[post_seg z] = buffer(post_cell{i},nfft,noverlap,'nodelay');%pre_seg only has full frames, z is leftover buffer
        [post_seg z] = buffer(post_cell{i}(:,2),nfft,noverlap,'nodelay');
        fft_postseg = zeros(nfft/2+1,size(post_seg,2));%find fft for each overalpping segment
        for ii = 1:size(post_seg,2)
            y = fft(post_seg(:,ii).*hamming(nfft),nfft);
            y = y(1:nfft/2+1);
            psdx = (1/(fs*nfft)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            %psdx = psdx./sum(psdx);
            fft_postseg(:,ii) = psdx;
        end
        
            postpsd(:,i) = mean(fft_postseg,2);
    
    end
end
    
freq = 0:fs/nfft:fs/2;

%%
%find CI for pre and post by shuffling each vector in each cell to compute
%average shuffled PSDs 
alpha = .95;
repnum = 1000;

shuff_prepsd = zeros(nfft/2+1,1000);%1000 reps of average PSDs from shuffled pre data
for i = 1:repnum
    
    shuffpsd = zeros(nfft/2+1,length(pre_cell));%shuffled vectors
    for ii = 1:length(pre_cell)
        %thesamp = pre_cell{ii}((randi(length(pre_cell{ii}),1,length(pre_cell{ii}))));%shuffle vector
         thesamp = pre_cell{ii}((randi(length(pre_cell{ii}),1,length(pre_cell{ii}))),2);
        if length(thesamp) < nfft
            thesamp = padarray(thesamp,[nfft-length(thesamp) 0],'post');
            y = fft(thesamp(1:nfft).*hamming(nfft),nfft);
            y = y(1:nfft/2+1);
            psdx = (1/(fs*nfft)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            %psdx = psdx./sum(psdx);
            shuffpsd(:,ii) = psdx;
            
        elseif length(thesamp) > nfft
            noverlap = nfft/2;
            [thesamp_seg z] = buffer(thesamp,nfft,noverlap,'nodelay');
            
            fft_thesamp = zeros(nfft/2+1,size(thesamp_seg,2));
            for iii = 1:size(thesamp_seg,2)   
                y = fft(thesamp_seg(:,iii).*hamming(nfft),nfft);
                y = y(1:nfft/2+1);
                psdx = (1/(fs*nfft)).*abs(y).^2;
                psdx(2:end-1) = 2*psdx(2:end-1); 
                psdx = 10*log10(psdx);
                %psdx = psdx./sum(psdx);
                fft_thesamp(:,iii) = psdx;
            end
            
            shuffpsd(:,ii) = mean(fft_thesamp,2); 
            
        end
         
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
        %thesamp = post_cell{ii}((randi(length(post_cell{ii}),1,length(post_cell{ii}))));
        thesamp = post_cell{ii}((randi(length(post_cell{ii}),1,length(post_cell{ii}))),2);
        
           if length(thesamp) < nfft
            thesamp = padarray(thesamp,[nfft-length(thesamp) 0],'post');
            y = fft(thesamp(1:nfft).*hamming(nfft),nfft);
            y = y(1:nfft/2+1);
            psdx = (1/(fs*nfft)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            %psdx = psdx./sum(psdx);
            shuffpsd(:,ii) = psdx;
            
           elseif length(thesamp) > nfft
               noverlap = nfft/2;
               [thesamp_seg z] = buffer(thesamp,nfft,noverlap,'nodelay');
            
               fft_thesamp = zeros(nfft/2+1,size(thesamp_seg,2));
               for iii = 1:size(thesamp_seg,2)   
                    y = fft(thesamp_seg(:,iii).*hamming(nfft),nfft);
                    y = y(1:nfft/2+1);
                    psdx = (1/(fs*nfft)).*abs(y).^2;
                    psdx(2:end-1) = 2*psdx(2:end-1); 
                    psdx = 10*log10(psdx);
                    %psdx = psdx./sum(psdx);
                    
                    fft_thesamp(:,iii) = psdx;
               end

                shuffpsd(:,ii) = mean(fft_thesamp,2); 

           end
        
    end
    
    shuff_postpsd(:,i) = mean(shuffpsd,2);
    
end

shuff_postpsd = sort(shuff_postpsd,2);
shuff_postpsd_hi = shuff_postpsd(:,fix(alpha*repnum));
shuff_postpsd_lo = shuff_postpsd(:,fix((1-alpha)*repnum));

%%
%find difference between average pre PSD and post PSD
% diffpsd = mean(prepsd,2) - mean(postpsd,2);
% 
% 
% %find CI for PSD difference by shuffling pre and post vectors 
% 
% rand_diffpsd = zeros(nfft/2+1,1000);
% for i = 1:repnum
%     
%     shuffsamp1 = zeros(nfft/2+1,length(pre_cell));%shuffle pre vectors
%     for ii = 1:length(pre_cell)
%         thesamp = pre_cell{ii}(randi(length(pre_cell{ii}),1,length(pre_cell{ii})));
%         
%             if length(thesamp) < nfft
%             thesamp = padarray(thesamp,[nfft-length(thesamp) 0],'post');
%             y = fft(thesamp(1:nfft).*hamming(nfft),nfft);
%             y = y(1:nfft/2+1);
%             psdx = (1/nfft).*abs(y).^2;
%             psdx(2:end-1) = 2*psdx(2:end-1); 
%             psdx = 10*log10(psdx);
%             shuffsamp1(:,ii) = psdx;
%             
%             elseif length(thesamp) > nfft
%                 noverlap = nfft/2;
%                [thesamp_seg z] = buffer(thesamp,nfft,noverlap,'nodelay');
%             
%                fft_thesamp = zeros(nfft/2+1,size(thesamp_seg,2));
%                for iii = 1:size(thesamp_seg,2)   
%                     y = fft(thesamp_seg(:,iii).*hamming(nfft),nfft);
%                     y = y(1:nfft/2+1);
%                     psdx = (1/nfft).*abs(y).^2;
%                     psdx(2:end-1) = 2*psdx(2:end-1); 
%                     psdx = 10*log10(psdx);
%                     fft_thesamp(:,iii) = psdx;
%                end
% 
%                 shuffsamp1(:,ii) = mean(fft_thesamp,2); 
%                 
%             end
%         
%     end
%     
%     shuffsamp2 = zeros(nfft/2+1,length(post_cell));%shuffle post vectors
%     for ii = 1:length(post_cell)
%         thesamp = post_cell{ii}(randi(length(post_cell{ii}),1,length(post_cell{ii})));
%         
%             if length(thesamp) < nfft
%                 thesamp = padarray(thesamp,[nfft-length(thesamp) 0],'post');
%                 y = fft(thesamp(1:nfft).*hamming(nfft),nfft);
%                 y = y(1:nfft/2+1);
%                 psdx = (1/nfft).*abs(y).^2;
%                 psdx(2:end-1) = 2*psdx(2:end-1); 
%                 psdx = 10*log10(psdx);
%                 shuffsamp2(:,ii) = psdx;
%                 
%             elseif length(thesamp) > nfft
%                 noverlap = nfft/2;
%                [thesamp_seg z] = buffer(thesamp,nfft,noverlap,'nodelay');
%             
%                fft_thesamp = zeros(nfft/2+1,size(thesamp_seg,2));
%                for iii = 1:size(thesamp_seg,2)   
%                     y = fft(thesamp_seg(:,iii).*hamming(nfft),nfft);
%                     y = y(1:nfft/2+1);
%                     psdx = (1/nfft).*abs(y).^2;
%                     psdx(2:end-1) = 2*psdx(2:end-1); 
%                     psdx = 10*log10(psdx);
%                     fft_thesamp(:,iii) = psdx;
%                end
% 
%                 shuffsamp2(:,ii) = mean(fft_thesamp,2); 
%             end
%             
%     end
%     
%     %find difference between average shuffled pre and average shuffled post
%     samp_diffpsd = mean(shuffsamp1,2) - mean(shuffsamp2,2);
%     rand_diffpsd(:,i) = samp_diffpsd;
%     
% end
% 
% 
% rand_diffpsd = sort(rand_diffpsd,2);
% rand_diffpsd_hi = rand_diffpsd(:,fix(alpha*repnum));
% rand_diffpsd_lo = rand_diffpsd(:,fix((1-alpha)*repnum));

%%
post_psd.psd = postpsd;
post_psd.freq = freq;
post_psd.hi = shuff_postpsd_hi;
post_psd.lo = shuff_postpsd_lo;

pre_psd.psd = prepsd;
pre_psd.freq = freq;
pre_psd.hi = shuff_prepsd_hi;
pre_psd.lo = shuff_prepsd_lo;

% diff_psd.avgdiff = diffpsd;
% diff_psd.hi = rand_diffpsd_hi;
% diff_psd.lo = rand_diffpsd_lo;

%%
% %find CI for PSD difference by randomly drawing 2 vectors from pooled pre
% %and pool 
% comb_cell = [post_cell pre_cell];%combined pre and post vectors into one cell
% 
% rand_diffpsd = zeros(nfft/2+1,1000);
% for i = 1:repnum
%     
%     draw2 = randsample(length(comb_cell),2);%randomly choose two vectors from combined cell
%     samp1 = comb_cell{draw2(1)};
%     samp2 = comb_cell{draw2(2)};
%     
%     %pad random vectors if length less than nfft
%     if length(samp1) < nfft
%         samp1 = padarray(samp1,[nfft-length(samp1) 0],'post');
%     end
%     
%     if length(samp2) < nfft
%         samp2 = padarray(samp2,[nfft-length(samp2) 0],'post');
%     end
%     
%     %PSD for first randomly drawn vector
%     samp1y = fft(samp1(1:nfft).*hamming(nfft),nfft);
%     samp1y = samp1y(1:nfft/2+1);
%     samp1_psdx = (1/nfft).*abs(samp1y).^2;
%     samp1_psdx(2:end-1) = 2*samp1_psdx(2:end-1); 
%     samp1_psdx = 10*log10(samp1_psdx);
%     
%     %PSD for second randomly drawn vector
%     samp2y = fft(samp2(1:nfft).*hamming(nfft),nfft);
%     samp2y = samp2y(1:nfft/2+1);
%     samp2_psdx = (1/nfft).*abs(samp2y).^2;
%     samp2_psdx(2:end-1) = 2*samp2_psdx(2:end-1); 
%     samp2_psdx = 10*log10(samp2_psdx);
%     
%     %difference between PSDs of random vectors
%     samp_diffpsd = samp1_psdx - samp2_psdx;
%     rand_diffpsd(:,i) = samp_diffpsd;
%     
% end
% 
% rand_diffpsd = sort(rand_diffpsd,2);
% rand_diffpsd_hi = rand_diffpsd(:,fix(alpha*repnum));
% rand_diffpsd_lo = rand_diffpsd(:,fix((1-alpha)*repnum));
% 
%     
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

    