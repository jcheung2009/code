function [post_psd pre_psd] = jc_psdpitch2(pre_cell, post_cell, tb_pre, tb_post, norm_y_n,eqfs_y_n)
%pre and post cell contain vectors for pitch data before and after lesion,
%unnormalized
%eqfs_y_n = y or n for setting same sampling rate for both conditions
%interpolation based on average singing rate in each condition
%PSD for each vector in each condition stored in prepsd.psd
%post_psd.hi and post_psd.lo are 95% CI for average PSD of shuffled vectors



%% normalize amplitude (mean subtract and then divide by maximum) 
if strcmp(norm_y_n,'y') == 1
    for i = 1:length(pre_cell)
        pre_cell{i}(:,2) = (pre_cell{i}(:,2)-mean(pre_cell{i}(:,2)))/max(pre_cell{i}(:,2)-mean(pre_cell{i}(:,2)));
    end

    for i = 1:length(post_cell);
        post_cell{i}(:,2) = (post_cell{i}(:,2)-mean(post_cell{i}(:,2)))/max(post_cell{i}(:,2)-mean(post_cell{i}(:,2)));
    end
end

%% use one sampling rate for interpolation
%determine mean sampling rates for interpolation
fs_pre = cellfun(@(x) size(x,1)/(x(end)-x(1)), tb_pre,'UniformOutput',false);
fs_pre = cell2mat(fs_pre);
fs_pre = mean(fs_pre);

fs_post = cellfun(@(x) size(x,1)/(x(end)-x(1)), tb_post,'UniformOutput',false);
fs_post = cell2mat(fs_post);
fs_post = mean(fs_post);

%take average of pre and post fs if want to use same sampling rate for both
%conditions
if strcmp(eqfs_y_n, 'y') == 1 
    fs = mean([fs_pre fs_post]);
    fs_pre = fs;
    fs_post = fs;
end


%interpolate with mean sampling rate
for i = 1:length(tb_pre)
    xi = ceil(tb_pre{i}(1)):1/fs_pre:floor(tb_pre{i}(end));%vector of uniformly spaced time points 
    v = interp1(tb_pre{i},pre_cell{i}(:,2),xi);
    interp_pre{i} = [xi' v'];
end

for i = 1:length(tb_post)
    xi = ceil(tb_post{i}(1)):1/fs_post:floor(tb_post{i}(end));
    v = interp1(tb_post{i},post_cell{i}(:,2),xi);
    interp_post{i} = [xi' v'];
end

%% determine nfft window

nfft_pre = pow2(nextpow2(fs_pre*3600*4)); %number of samples for 4 hours
nfft_post = pow2(nextpow2(fs_post*3600*4));

%% find PSD for each vector in cell
prepsd = zeros(nfft_pre/2+1,length(interp_pre));
freq_pre = 0:fs_pre/nfft_pre:fs_pre/2;

for i = 1:length(interp_pre)
    
    if length(interp_pre{i}) < nfft_pre %if vector length is less than nfft window, then padd end with 0's so that you can apply the hamming
        pad_interp = padarray(interp_pre{i}(:,2),[nfft_pre-length(interp_pre{i}) 0],'post');
        y = fft(pad_interp(1:nfft_pre).*hamming(nfft_pre),nfft_pre);
        y = y(1:nfft_pre/2+1);
        psdx = (1/(fs_pre*nfft_pre)).*abs(y).^2;
        psdx(2:end-1) = 2*psdx(2:end-1); 
        psdx = 10*log10(psdx);
        prepsd(:,i) = psdx;
        
    elseif length(interp_pre{i}) > nfft_pre %if vector length is greater than nfft window, find average PSD from sliding overlapping nfft
        noverlap = nfft_pre/2;% 50% overlap
        [pre_seg z] = buffer(interp_pre{i}(:,2),nfft_pre,noverlap,'nodelay');%pre_seg only has full frames, z is leftover buffer
        
        fft_preseg = zeros(nfft_pre/2+1,size(pre_seg,2));%find fft for each overalpping segment
        for ii = 1:size(pre_seg,2)
            y = fft(pre_seg(:,ii).*hamming(nfft_pre),nfft_pre);
            y = y(1:nfft_pre/2+1);
            psdx = (1/(fs_pre*nfft_pre)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            fft_preseg(:,ii) = psdx;
        end
        
            prepsd(:,i) = mean(fft_preseg,2);%average fft for each overlapping segment to find average PSD for that vector 
       
    end
    
end

postpsd = zeros(nfft_post/2+1,length(interp_post));
freq_post = 0:fs_post/nfft_post:fs_post/2;

for i = 1:length(interp_post)
    
    if length(interp_post{i}) < nfft_post
       pad_interp = padarray(interp_post{i}(:,2),[nfft_post-length(interp_post{i}) 0],'post');
       y = fft(pad_interp(1:nfft_post).*hamming(nfft_post),nfft_post);
       y = y(1:nfft_post/2+1);
       psdx = (1/(fs_post*nfft_post)).*abs(y).^2;
       psdx(2:end-1) = 2*psdx(2:end-1); 
       psdx = 10*log10(psdx);
       postpsd(:,i) = psdx;
    
    elseif length(interp_post{i}) > nfft_post
        noverlap = nfft_post/2;
        [post_seg z] = buffer(interp_post{i}(:,2),nfft_post,noverlap,'nodelay');%pre_seg only has full frames, z is leftover buffer
        
        fft_postseg = zeros(nfft_post/2+1,size(post_seg,2));%find fft for each overalpping segment
        for ii = 1:size(post_seg,2)
            y = fft(post_seg(:,ii).*hamming(nfft_post),nfft_post);
            y = y(1:nfft_post/2+1);
            psdx = (1/(fs_post*nfft_post)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            fft_postseg(:,ii) = psdx;
        end
        
            postpsd(:,i) = mean(fft_postseg,2);
    
    end
end

%% bootstrap to find average PSD of shuffled vectors
alpha = .95;
repnum = 1000;

shuff_prepsd = zeros(nfft_pre/2+1,1000);%1000 reps of average PSDs from shuffled pre data
for i = 1:repnum
    
    shuffpsd = zeros(nfft_pre/2+1,length(interp_pre));%shuffled vectors
    for ii = 1:length(interp_pre)
        thesamp = interp_pre{ii}((randi(length(interp_pre{ii}),1,length(interp_pre{ii}))),2);%shuffle vector
        
        if length(thesamp) < nfft_pre
            thesamp = padarray(thesamp,[nfft_pre-length(thesamp) 0],'post');
            y = fft(thesamp(1:nfft_pre).*hamming(nfft_pre),nfft_pre);
            y = y(1:nfft_pre/2+1);
            psdx = (1/(fs_pre*nfft_pre)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            shuffpsd(:,ii) = psdx;
            
        elseif length(thesamp) > nfft_pre
            noverlap = nfft_pre/2;
            [thesamp_seg z] = buffer(thesamp,nfft_pre,noverlap,'nodelay');
            
            fft_thesamp = zeros(nfft_pre/2+1,size(thesamp_seg,2));
            for iii = 1:size(thesamp_seg,2)   
                y = fft(thesamp_seg(:,iii).*hamming(nfft_pre),nfft_pre);
                y = y(1:nfft_pre/2+1);
                psdx = (1/(fs_pre*nfft_pre)).*abs(y).^2;
                psdx(2:end-1) = 2*psdx(2:end-1); 
                psdx = 10*log10(psdx);
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


shuff_postpsd = zeros(nfft_post/2+1,1000); %1000 reps of averaged PSDs from shuffled post data
for i = 1:repnum
    
    shuffpsd = zeros(nfft_post/2+1,length(interp_post));
    for ii = 1:length(interp_post)
        thesamp = interp_post{ii}((randi(length(interp_post{ii}),1,length(interp_post{ii}))),2);
        
           if length(thesamp) < nfft_post
            thesamp = padarray(thesamp,[nfft_post-length(thesamp) 0],'post');
            y = fft(thesamp(1:nfft_post).*hamming(nfft_post),nfft_post);
            y = y(1:nfft_post/2+1);
            psdx = (1/(fs_post*nfft_post)).*abs(y).^2;
            psdx(2:end-1) = 2*psdx(2:end-1); 
            psdx = 10*log10(psdx);
            shuffpsd(:,ii) = psdx;
            
           elseif length(thesamp) > nfft_post
               noverlap = nfft_post/2;
               [thesamp_seg z] = buffer(thesamp,nfft_post,noverlap,'nodelay');
            
               fft_thesamp = zeros(nfft_post/2+1,size(thesamp_seg,2));
               for iii = 1:size(thesamp_seg,2)   
                    y = fft(thesamp_seg(:,iii).*hamming(nfft_post),nfft_post);
                    y = y(1:nfft_post/2+1);
                    psdx = (1/(fs_post*nfft_post)).*abs(y).^2;
                    psdx(2:end-1) = 2*psdx(2:end-1); 
                    psdx = 10*log10(psdx);
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
pre_psd.psd = prepsd;
pre_psd.freq = freq_pre;
pre_psd.hi = shuff_prepsd_hi;
pre_psd.lo = shuff_prepsd_lo;

post_psd.psd = postpsd;
post_psd.freq = freq_post;
post_psd.hi = shuff_postpsd_hi;
post_psd.lo = shuff_postpsd_lo;


