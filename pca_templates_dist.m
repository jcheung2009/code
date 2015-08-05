function [out meanVect seVect] = pca_templates_dist(in_struct,nameStr,norm)
%
% [out] = pca_templates(in_struct,nameStr)
%
% performs principle component analysis on templates in 1st and 2nd elements of in_struct & projects all
% other elements into the space defined by 1st 3 resulting eigenvectors.
%
% 1st 2 elements should be tutor & subsong, followed by reference (tutor)
% and then subsong, day1, day2, etc.
%
% [out] is cell array of points projected on to 1st seven PCs; good for
% calculating distance
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

out = {};
temp_out = [];

% deconcatonate, pca, & project:
figure()
start = 1;
%for i=1:length(in_struct);
for i=1:length(in_struct)-1;
    var_str = [nameStr '_' num2str(i) '_pca'];
    if(i == 1)
        start = 1;
        %stop = start + (length(in_struct(i).templates)-2);
        stop = start + (length(in_struct(i).templates)-2 + length(in_struct(i+1).templates)-2);
        [eigens scores] = princomp(in_features_z(start:stop,:));
        assignin('base',var_str,scores');
        scores = scores';
        %scatter3(scores(1,:),scores(2,:),scores(3,:),25,'filled');
        hold on;
        temp_out = [scores(1,:);scores(2,:);scores(3,:);scores(4,:);scores(5,:);scores(6,:);scores(7,:)];
        out = [out;temp_out];
    else
        start = stop+1;
        %stop = start + (length(in_struct(i).templates) - 2);
        stop = start + (length(in_struct(i+1).templates) - 2);
        the_proj = eigens' * in_features_z(start:stop,:)';
        assignin('base',var_str,the_proj);
        scatter3(the_proj(1,:),the_proj(2,:),the_proj(3,:),25,'filled');
        temp_out = [the_proj(1,:);the_proj(2,:);the_proj(3,:);the_proj(4,:);the_proj(5,:);the_proj(6,:);the_proj(7,:)];
        out = [out;temp_out];
    end
end
hold off;

% calculate euclidean distance between elements of in_struct in 7-D PC space
meanVect = zeros(length(in_struct)-2,1);
seVect = zeros(length(in_struct)-2,1);
for i=2:(length(out)-1);
    [neighbors pcDistance] = kNearestNeighbors(out{i}',out{length(out)}',1);
    meanVect(i) = mean(pcDistance);
    seVect(i) = stderr(pcDistance);
end

meanVect = meanVect(2:end); seVect = seVect(2:end);

if(norm)
    meanVect = meanVect / meanVect(1);
    seVect = seVect / meanVect(1);
end

figure();errorbar(meanVect,seVect,'ko-');

end