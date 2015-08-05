function [out] = mFeaturesByDay(featureNum,structList,dayvect)
%
%
%
%
%
%

fighandle = figure();
set(fighandle,'Color','white');

if(isempty(dayvect))
    dayvect = 0:1:length(structList);
    disp('making arbitrary time axis');
end

hold on;
for i=1:length(structList)
    plot(dayvect(i),structList(i).templates(:,featureNum),'k.');
end
theFeatureName = feature_vect_name(featureNum);
titleStr = theFeatureName;
title(titleStr);
xlabel('day number');
hold off;
