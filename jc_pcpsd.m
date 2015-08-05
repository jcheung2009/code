function [pcpre_psd pcpost_psd freq nfft] = jc_pcpsd(pc_pre, pc_post, tm, timebins, norm_y_n)

%% select pitch contour segment containing timebins

downsamplesize = 5;
seg = find(tm>timebins(1) & tm<timebins(2));
seg = downsample(seg,downsamplesize);

for i = 1:length(pc_pre)
    pc_pre{i} = pc_pre{i}(seg,:);
end

for i = 1:length(pc_post)
    pc_post{i} = pc_post{i}(seg,:);
end



%% normalize amplitude zscore, keeping difference in variance between pre and post by normalizing with pre std

if strcmp(norm_y_n,'y') == 1
    std_p = mean(cell2mat(cellfun(@(x) nanstd(x,0,2),pc_pre,'UniformOutput',false)),2);%column vector of mean std for each row of timebins
      
    for i = 1:length(pc_pre)
        pc_pre{i} = detrend(pc_pre{i}','constant')'; %mean subtract each row
        pc_pre{i} = pc_pre{i}./repmat(std_p,1,size(pc_pre{i},2));%divide column vector of stdp from each row 
    end
    
    for i = 1:length(pc_post)
        pc_post{i} = detrend(pc_post{i}','constant')';
        pc_post{i} = pc_post{i}./repmat(std_p,1,size(pc_post{i},2));
    end 
end


%% Determine nfft length: smallest number of renditions from both conditions

nfft = min([min(cellfun(@(x) size(x,2),pc_pre)), min(cellfun(@(x) size(x,2), pc_post))]);
if mod(nfft,2) == 1
    nfft = nfft - 1;
end


%% find PSD for each row in pitch contour in each cell and take average 
noverlap = nfft/2; % 50% overlap 
fs = 1; %1 sample per rendition
pcpre_psd = zeros(nfft/2+1,length(pc_pre));
for i = 1:length(pc_pre)  
    pc_pre{i} = pc_pre{i}';%fft computes down columns, renditions x timebins 
    indvec = 1:1:size(pc_pre{i},1);%vector of consecutive numbers up to length of matrix
    [blck z]= buffer(indvec,nfft,noverlap,'nodelay');% partitions indvec into overlapping segments into columns of block
    fft_block = zeros(nfft/2+1,size(blck,2));
    for ii = 1:size(blck,2)
        y = fft(pc_pre{i}(blck(:,ii),:).*repmat(hamming(nfft),1,size(pc_pre{i},2)),nfft);
        y = y(1:nfft/2+1,:);
        psdx = (1/(fs*nfft)).*abs(y).^2;
        psdx(2:end-1,:) = 2*psdx(2:end-1,:);
        psdx = 10*log10(psdx);
        fft_block(:,ii) = mean(psdx,2);%take the average fft across time bins in block
    end
    pcpre_psd(:,i) = mean(fft_block,2);%takes the overall average fft of all blocks for each cell 
end

pcpost_psd = zeros(nfft/2+1,length(pc_post));
for i = 1:length(pc_post)
    pc_post{i} = pc_post{i}';
    indvec = 1:1:size(pc_post{i},1);
    [blck z] = buffer(indvec,nfft,noverlap,'nodelay');
    fft_block = zeros(nfft/2+1,size(blck,2));
    for ii = 1:size(blck,2)
        y = fft(pc_post{i}(blck(:,ii),:).*(repmat(hamming(nfft),1,size(pc_post{i},2))),nfft);
        y = y(1:nfft/2+1,:);
        psdx = (1/(fs*nfft)).*abs(y).^2;
        psdx(2:end-1,:) = 2*psdx(2:end-1,:);
        psdx = 10*log10(psdx);
        fft_block(:,ii) = mean(psdx,2);
    end
    pcpost_psd(:,i) = mean(fft_block,2);
end

freq = 0:fs/nfft:fs/2;

    
        
        
        

