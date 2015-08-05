

function [result]=Avg_Traces(Input,range)

        temp=Input{range(1)}-mean(Input{range(1)}(1:100));
        for i=1:length(range)
           temp=temp+(Input{i}-mean(Input{range(i)}(1:100)));
        end;
        
        temp=temp./length(range);   
        
        result=temp;
        



