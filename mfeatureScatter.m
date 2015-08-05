function mfeatureScatter(featureNum,structList)
%
%
%
%
%

fighandle = figure();
set(fighandle,'Color','white');

[featureStruct colorVect] = makeScatterIn(structList);

theFeatureName = feature_vect_name(featureNum); % the feature common to all scatter plots

for plotnum = 1:1:16; % plot each of the other features against theFeatureName
    theFeature = plotnum;
    if(theFeature == featureNum);
        theFeature = theFeature +1;
    else
        featureName2 = feature_vect_name(theFeature);
        subplot(4,4,theFeature);
        scatter(featureStruct(:,featureNum),featureStruct(:,theFeature),12,colorVect);
        titleStr = [theFeatureName ' vs ' featureName2];
        title(titleStr);

    end

end

