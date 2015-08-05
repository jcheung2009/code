function patternstruct = part_matcher(part,labels,ons,offs,total,fname)
%
%function songnmb = part_matcher(part,labels,ons,offs,total)
%searches the string 'labels' for patterns
%
%returns a structure containing the strings matching the pattern, 
%the index of the lables in a matching string (relative to a sound file) 
%with that lable acompanying onset and offset,along
%with the index of the sound file relative to where it is in the batch
%


%a few initial parameters

sndcnt = 1;
sndindx = strfind(labels,'/');

%while there are still files left to search
while sndcnt ~= max(length(sndindx))
      ptncnt = 0;
      lblindx = 0;
%find the indices of all the parts with in that soundfile
    for i = 1:total
        part(i).lblindxs = [];
        part(i).lblindxf = [];
        part(i).lblindxnull = 0;
        for j = 1:part(i).strnum    
                lengths = part(i).stringlength(j);
                if lengths ~= 0
                    part2find = part(i).string{j};
                    fndparts = strfind(labels(sndindx(sndcnt)+1:sndindx(sndcnt+1)-1),part2find);
                    part(i).lblindxs = [part(i).lblindxs,fndparts];
                    part(i).lblindxf = [part(i).lblindxf,fndparts+lengths-1];
                else 
                   part(i).lblindxnull = 1;                    
                end    
        end
    end
    
       % for  within a sound file, while the current string has contiguous indices, go through all the parts 
    while lblindx ~= sndindx(sndcnt+1)
       % set startindx with respect to the first part
    
           if strcmp(part(1).type,'neg')
                startindx = part(2).lblindxs;
                i = 2;    
           else
                startindx = part(1).lblindxs;
                i =1;    
           end
       
           if isempty(find(startindx>lblindx))
                lblindx = sndindx(sndcnt+1);
                break;
           else
                startindx = startindx(startindx > lblindx);
                startindx = startindx(1); 
           end
            
          lblindx = startindx-1;
        
    not_pattern = 0;
       % go through all the parts, matching indices and incrementing
       % lblindx by the length of the matching string
       
       while i ~= total+1 & ~not_pattern
           
           if strcmp(part(i).type,'star') 
           
           if strcmp(part(i).type,'rep') 
               pidxs = part(i).lblindxs;
               pidxf = part(i).lblindxf(pidxs > lblindx);
               pidxs = pidxs(pidxs > lblindx);
               if isempty(find(pidxs == lblindx+1)) & ~part(i).lblindxnull  
                   not_pattern = 1;
                   break;
               elseif isempty(find(pidxs == lblindx+1)) & part(i).lblindxnull
                   i = i+1;
               else k=1;
                   while (k+1 <= length(pidxs)) && (pidxf(k) +1 == pidxs(k+1))
                       k = k+1;
                   end
                   lblindx = pidxf(k);
                   i = i+1;
               end
              
               if i == total+1
                   endindx = lblindx;
                   break;    
               end
           end
           
           if strcmp(part(i).type,'norm') 
               pidxs = part(i).lblindxs;
               pidxf = part(i).lblindxf(pidxs > lblindx);
               pidxs = pidxs(pidxs > lblindx);
               if isempty(find(pidxs == lblindx+1))
                   not_pattern = 1;
                   break;
               else 
                  lblindx = pidxf(1); 
               end
                i = i+1;
                if i == total +1
                    endindx = lblindx;
                    break;
                end
           end
          
           if strcmp(part(i).type,'opt')
               pidxs = part(i).lblindxs;
               pidxf = part(i).lblindxf(pidxs > lblindx);
               pidxs = pidxs(pidxs > lblindx);
               if isempty(find(pidxs == lblindx+1))
                   i = i+1;
               else 
                  lblindx = pidxf(1); 
                  i = i+1;    
              end
                if i == total +1
                    endindx = lblindx;
                    break;
                end
           end
               
           if strcmp(part(i).type,'neg')
               lk= part(i).lblindxs
               gh= lblindx
               if ~isempty(find(part(i).lblindxs == lblindx+1))
                   not_pattern = 1;
                   break;
               else
                   i = i+1;
                   endindx = lblindx;
                   break;
               end
           end
           
       end
       
        %check to see if ptn is valid given a not marker in the beginning
        
       if strcmp(part(1).type ,'neg') 
          if ~isempty(find(part(1).lblindxf+1 == startindx))  
              endindx = -1;    
          end
       end      
       
       % if the parts had contiguous indices, store pattern and other info
        if exist('endindx') 
           if endindx == lblindx
                ptncnt = ptncnt +1;
                patternstruct(sndcnt).ptnsngindx{ptncnt} = [startindx:endindx];
                startindx = startindx+sndindx(sndcnt);
                endindx = endindx+sndindx(sndcnt);
                patternstruct(sndcnt).ptnlblindx{ptncnt} = [startindx:endindx];
                patternstruct(sndcnt).ptnlbls{ptncnt} = labels(startindx:endindx);
                patternstruct(sndcnt).ptnons{ptncnt} = ons(startindx:endindx);
                patternstruct(sndcnt).ptnoffs{ptncnt} = offs(startindx:endindx);
                patternstruct(sndcnt)    
            end
        end
   patternstruct(sndcnt).ptntot = ptncnt
   patternstruct(sndcnt).fname = fname{sndcnt};
   sndcnt = sndcnt+1
end
                   
           