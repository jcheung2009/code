function [shuffcorravg] = jc_shuffpccorr(pc,tm,numboot,timebins,maxlag)
%shuffl
%pc = cell with pitch contours for all days in condition
%tm = cell with all time bases for pitch contours 

tic
shuffcorravg = NaN(maxlag+1,numboot); %each column is average correlation of shuffled data in pc 
for i = 1:numboot
    shuffcorr = NaN(maxlag+1,length(pc)); %each colunn is shuffled correlation for each day in 
    
    for ii = 1:length(pc)
        shuffpc = pc{ii}(:,randperm(size(pc{ii},2)));
        shuffcorr(:,ii) = jc_pccorr(shuffpc,tm{ii},timebins,maxlag);
    end
    
    shuffcorravg(:,i) = mean(shuffcorr,2);    
    
end

 
shuffcorravg = sort(shuffcorravg,2);
toc
    