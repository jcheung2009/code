function jc_plotdata(invect)

if isstruct(invect)
    names = fieldnames(invect)
    for i = 1:length(names)
        mean_fv = mean(invect.(names{i})(:,2));
        [hi lo] = mBootstrapCI(invect.(names{i})(:,2),'');
        figure(4);hold on;
        plot([mean(invect.(names{i})(:,1)) mean(invect.(names{i})(:,1)) ],[hi lo],'b');hold on;
        plot(mean(invect.(names{i})(:,1)),mean_fv,'ob','MarkerSize',10);
    end
    
    
   
elseif iscell(invect)
    for i = 1:length(invect)
        mean_fv = mean(invect{i}(:,2));
        [hi lo] = mBootstrapCI(invect{i}(:,2),'');
        figure(4);hold on;
        plot([mean(invect{i}(:,1)) mean(invect{i}(:,1))],[hi lo],'b');hold on;
        plot(mean(invect{i}(:,1)),mean_fv,'ob','MarkerSize',10);
    end
end

