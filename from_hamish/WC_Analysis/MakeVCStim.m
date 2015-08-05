function [Out]=MakeStim(StepOn,V,VStep,Dur,Repeat,dt);

   for i=1:Repeat      
        
        for j=1:length(V);
               StimPt{j}=ones(1,Dur(j)/dt)*(V(j)+(VStep(j)*(i-1)));
        end;
              
        [a b]=find(StepOn==1);
        Out(:,i)=[StimPt{a}];
             
    end;