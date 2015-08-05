function shuffled_tiff = mShuffleTiff(tiff_file)
%
%   loops through each z-slice (plane) in a tiff stack & shuffles the x-y coordinates
%   of each point in the slice. Useful for generating a shuffled, spatially
%   unstructured stimulus that preserves intensity distributions in the original image
%   for testing deconvolution & other post-processing. 
%
%

tiff_info = imfinfo(tiff_file);
num_slices = numel(tiff_info);
xsize = getfield(tiff_info,{1,1},'Width');
ysize = getfield(tiff_info,{1,1},'Height');

saveStr = ['shuff_' tiff_file];

%shuffled_tiff = zeros(xsize,ysize,num_slices);
disp('working...');
for index=1:num_slices
    yrand = randperm(ysize);    
    theTiff = imread(tiff_file,index);
        
    for yindex = 1:ysize
        xrand = randperm(xsize);
        for xindex = 1:xsize
            theTiff(xindex,yindex) = theTiff(xrand(xindex),yrand(xindex));
        end;
    end;
    if(index==1)
        imwrite(theTiff,saveStr,'tiff');
    else
        imwrite(theTiff,saveStr,'tiff','WriteMode','append');
    end;
    %shuffled_tiff(:,:,index) = theTiff;
    shuffled_tiff = theTiff;
end;
disp('done');



