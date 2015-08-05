for i=1:length(bad)    
    delete(bad{i});
   
    delete([bad{i} '.rec'])
end;