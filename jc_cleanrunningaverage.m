function invect = jc_cleanrunningaverage(invect,winsize);

halfwinsize = winsize/2;
jogsize = halfwinsize;
for i = 1+halfwinsize:jogsize:length(invect)-halfwinsize
    ind = jc_findoutliers(invect(i-halfwinsize:i+halfwinsize),3);
    removeind = ind + (i-halfwinsize)-1;
    invect(removeind) = NaN;
end



