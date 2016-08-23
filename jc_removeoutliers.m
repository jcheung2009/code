function invect = jc_removeoutliers(invect,nstd)

for i = 1:size(invect,2)
    removeind = jc_findoutliers(invect(:,i),nstd);
    invect(removeind,i) = NaN;
end


