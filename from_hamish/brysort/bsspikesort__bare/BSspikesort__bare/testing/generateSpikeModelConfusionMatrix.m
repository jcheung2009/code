function [matrix, classes] = generateSpikeModelConfusionMatrix(trueClass,classes)
%[matrix, newClasses] = generateSpikeModelConfusionMatrix(trueClass,classes)
%constructs a normalized confusion matrix out of the true classes and identified
%assignments. (each value scaled individually This will reassign the values
%in classes (provided in newClasses). 

%find unique elements in the list
utc = unique(trueClass);

classes = classes-min(classes)+1; %reset so 1 is the first class
uc = unique(classes);

if(length(trueClass) ~= length(classes))
    disp('THIS LINE SHOULDN''T NEED TO BE HERE');
    trueClass = trueClass(1:length(classes));
end

% create the confusion matrix
matrix = zeros(max(utc),max(uc));

for i = 1:max(utc)
    for j = 1:max(uc)
        matrix(i,j) = sum((classes(trueClass == i)) == j)/sum(trueClass == i);
    end
end

%reorder so it looks like a confusion matrix
for i = 1:min(max(utc),max(uc))
    [v, ind] = max(matrix(i,i:end)); %don't look in those we've sorted already
    
    ind = ind + i-1; %add in the offset we removed above
    
    %do a swap to temp space
    temp = matrix(:,i); 
    matrix(:,i) = matrix(:,ind);
    matrix(:,ind) = temp;
    
    %also swap class assignments
    classes(classes == i) = inf;
    classes(classes == ind) = i;
    classes(classes == inf) = ind;
end
