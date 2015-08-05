function [out] = mTwoFeatures(feat1,feat2,featureStruct)
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

scatter(featureStruct(:,feat1),featureStruct(:,feat2),20,colorVect,'filled');
titleStr = [FeatureName1 ' vs ' FeatureName2];
title(titleStr);


out = [];