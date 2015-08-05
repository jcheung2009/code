function [t, wv] = WvClusThresholding(filename,varargin)

    load(filename);  
    t=cluster_class(:,2);
    
    %WV must be in n x 4 x 32
    
    wv=spikes(:,17:64-16); clear spikes;

    temp(1:size(wv,1),1,1:32)=wv;
    temp(1:size(wv,1),2:4,1:32)=0;
    wv=temp;clear temp;

%     keyboard;

     if nargin > 1
         records_to_get=varargin{1}; %can select a range
     else
         records_to_get=1:size(wv,1); %or all if blank
     end;

     if nargin > 2
         
         record_units=varargin{2};
    
         % %    	record_units = a flag taking one of 5 cases (1,2,3,4 or 5)
    % % 1.	implies that records_to_get is a timestamp list.  
    % % 2.	implies that records_to_get  is a record number list 
    % % 3.	implies that records_to_get  is range of timestamps (a vector with 2 elements: a start and an end timestamp)
    % % 4.	implies that records_to_get  is a range of records (a vector with 2 elements: a start and an end record number)
    % % 5.	asks to return the count of spikes (records_to_get should be [] in this case)
    
        switch record_units
            case 1
                idx=[];
                for i=1:length(records_to_get)
                    idx=[idx find(t==records_to_get(i),1)];
                end
                wv=wv(idx,:,:);
                t=t(:);
                keyboard
            case 2
                wv=wv(records_to_get,:,:);
                t=t(records_to_get,:,:);
            case 3
                start=find(t>records_to_get(1),1);
                stop=find(t>records_to_get(2),1)          
                wv=wv(start:stop,:,:);
                t=t(start:stop);
            case 4    
                wv=wv(records_to_get(1):records_to_get(2),:,:);
                t=t(records_to_get(1):records_to_get(2));
            case 5      
                t=size(wv,1);
                wv=[];
        end;
        

     end;

end

