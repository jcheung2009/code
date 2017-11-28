function shuffmat = permute_rowel(mat);
%shuffle elements within rows in matrix

[~,permmat] = sort(rand(size(mat,1),size(mat,2)),2);
permmat = (permmat-1)*size(mat,1)+ndgrid(1:size(mat,1),1:size(mat,2));
shuffmat = mat(permmat);
