function invect = jc_removeoutliers(invect,nstd,varargin)
%this function replaces outliers in invect with NaN
%varargin{1} = vector of indices of column in invect to exclude 
for i = 1:size(invect,2)
    if ~isempty(varargin)
        if ismember(i,varargin{1})
            continue
        end
    end
    removeind = jc_findoutliers(invect(:,i),nstd);
    invect(removeind,i) = NaN;
end


