function [out] = pca_templates(in_struct,nameStr)
%
% [out] = pca_templates(in_struct,nameStr)
%
% performs PCA on templates in 1st element of in_struct & projects all
% other elements into the space defined by 1st 3 resulting eigenvectors. 
%

for i=1:length(in_struct)
    the_struct = in_struct(i);
    % clean templates of amplitude columns & empty last row:
    the_struct.templates = the_struct.templates(1:end-1,:);
    the_struct.templates(:,3) = [];
    the_struct.templates(:,15) = [];

    % concatonate them:
    if(i == 1)
        in_features = the_struct.templates;
    else
        in_features = vertcat(in_features,the_struct.templates);
    end
end

% normalize by converting to z-scores:
in_features_z = zscore(in_features);

% deconcatonate, pca, & project:
figure()
start = 1;
for i=1:length(in_struct);
    var_str = [nameStr '_' num2str(i) '_pca'];
    if(i == 1)
        start = 1;
        stop = start + (length(in_struct(i).templates)-2);
        [eigens scores] = princomp(in_features_z(start:stop,:));
        assignin('base',var_str,scores');
        scores = scores';
        scatter3(scores(1,:),scores(2,:),scores(3,:),25,'filled');
        hold on;
    else
        start = stop+1;
        stop = start + (length(in_struct(i).templates) - 2);
        the_proj = eigens' * in_features_z(start:stop,:)';
        assignin('base',var_str,the_proj);
        scatter3(the_proj(1,:),the_proj(2,:),the_proj(3,:),25,'filled');
    end
end
hold off;



end