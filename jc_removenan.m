function invect = jc_removenan(invect);
%removes rows of invect matrix that contain NaNs

for i = 1:size(invect,2)
    ind = find(isnan(invect(:,i)));
    invect(ind,:) = [];
end
