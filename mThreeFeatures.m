function [out] = mThreeFeatures(feat1,feat2,feat3,featureStruct)
%
%
%
%
%

fighandle = figure();
set(fighandle,'Color','white');

[featureStruct colorVect] = makeScatterIn(featureStruct);

FeatureName1 = feature_vect_name(feat1); %
FeatureName2 = feature_vect_name(feat2);
FeatureName3 = feature_vect_name(feat3);

scatter3(featureStruct(:,feat1),featureStruct(:,feat2),featureStruct(:,feat3),20,colorVect,'filled');
titleStr = [FeatureName1 ' vs ' FeatureName2 ' vs ' FeatureName3];
title(titleStr);


out = [];