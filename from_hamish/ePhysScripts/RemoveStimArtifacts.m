function data=RemoveStimArtifacts(data)

     diffwave=diff(data);
                    
     [idx]=find(abs(diffwave)>5*std((diffwave)));
     data(idx)=NaN;


                

