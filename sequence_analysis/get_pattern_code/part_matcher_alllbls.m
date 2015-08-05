 function patternstruct = part_matcher_alllbls(part,labels,ons,offs,total,fname)
%
%function songnmb = part_matcher(part,labels,ons,offs,total)
%searches the string 'labels' for patterns
%
%returns a structure containing the strings matching the pattern, 
%the index of the lables in a matching string (relative to a sound file) 
%with that lable acompanying onset and offset,along
%with the index of the sound file relative to where it is in the batch
%
%underlying idea: using strfind, retrieve indices of parts; then match up
%the indices so that if they are contigious (if part is obligatory) between the first index
%of an occurance of the first part and the last index of an occurance of the final part
%this is a matching pattern, else move on to the next occurance of the
%first part


%a few initial parameters
ptntot = 0;
sndcnt = 1;
sndindx = strfind(labels,'/');
strcnt = 0;
startindx = 0;
while strcnt < total & strcmp(part(strcnt+1).type,'star')  
      strcnt = strcnt +1; 
end

%while there are still files left to search
while sndcnt ~= max(length(sndindx))
      ptncnt = 0;
      lblindx = 0;
%find the indices of all the parts within that soundfile
all_lblscrnt = labels(sndindx(sndcnt)+1:sndindx(sndcnt+1)-1);
    for k = 1:total
        part(k).lblindxs = [];
        part(k).lblindxf = [];
        part(k).lblindxnull = 0;
        for j = 1:part(k).strnum    
                lengths = part(k).stringlength(j);
                if lengths ~= 0
                    part2find = part(k).string{j};
                    fndparts = strfind(char(all_lblscrnt),part2find);
                    part(k).lblindxs = [part(k).lblindxs,fndparts];
                    part(k).lblindxf = [part(k).lblindxf,fndparts+lengths-1];
                else 
                   part(k).lblindxnull = 1;                    
                end    
        end
     end

       % within a sound file, while the current string has contiguous indices, go through all the parts 
    while lblindx ~= sndindx(sndcnt+1)
       % set startindx with respect to the first part
           if strcmp(part(1).type,'star')
               if strcnt == total
                   lblindx = startindx;
                   startindx = startindx+1;
               else
                   startindx = part(strcnt+1).lblindxs;
               end
               i = 1;
               
           elseif strcmp(part(1).type,'neg')
                startindx = part(2).lblindxs;
                i = 2;    
                %used to take care of optional parts occuring as the first
                %part
           elseif strcmp(part(1).type,'opt') | ~isempty(find(part(1).stringlength == 0))
                for w = 2:length(part)
                   if ~strcmp(part(w).type,'opt') & isempty(find(part(w).stringlength == 0))
                        indxs = part(w).lblindxs;
                        indx_oblig = indxs(indxs >lblindx);
                        if isempty(indx_oblig) | (indx_oblig+strcnt+sndindx(sndcnt)-1 >= sndindx(sndcnt+1))
                            lblindx = sndindx(sndcnt+1);
                            break;
                        end
                        indx_oblig = indx_oblig(1);
                    end
                end
                for g = 1:w-1
                    indxT = part(g).lblindxs(part(g).lblindxs >lblindx);
                    if find(indxT < indx_oblig)
                        startindx = indxT(indxT <indx_oblig);
                        startindx = startindx(1);
                        lblindx = startindx-1;
                        i = g;
                        break;
                    end
                end
                if startindx <= lblindx
                    startindx = indx_oblig;
                    i = w;
                end
                       
           else
                startindx = part(1).lblindxs;
                i =1;    
           end
           
           if isempty(find(startindx>lblindx)) | (startindx+strcnt+sndindx(sndcnt)-1 >= sndindx(sndcnt+1))
                lblindx = sndindx(sndcnt+1);
                break;
           elseif strcnt ~= total
                startindx = startindx(startindx > lblindx);
                startindx = startindx(1) - strcnt; 
                lblindx = startindx-1;
           end
            
    not_pattern = 0;
       % go through all the parts, matching indices and incrementing
       % lblindx by the length of the matching string
       
       while i ~= total+1 & ~not_pattern
          
           if strcmp(part(i).type,'star') 
                lblindx = lblindx+1;
                i = i+1;
                if i == total+1
                   endindx = lblindx;
                   break;    
                end
            end
           
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
                   while (k+1 <= length(pidxs)) & (pidxf(k) +1 == pidxs(k+1))
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
        if exist('endindx') & endindx ~= 0
           if endindx == lblindx
               startindxtot = startindx+sndindx(sndcnt);
               if startindxtot > 0
                    endindxtot = endindx+sndindx(sndcnt);
                    if isletter(labels(startindxtot:endindxtot));   
                        ptncnt = ptncnt +1;
                        patternstruct(sndcnt).ptnsngindx{ptncnt} = [startindx:endindx];
                        patternstruct(sndcnt).ptnlblindx{ptncnt} = [startindxtot:endindxtot];
                        patternstruct(sndcnt).ptnlbls{ptncnt} = labels(startindxtot:endindxtot);
                        patternstruct(sndcnt).ptnons{ptncnt} = ons(startindxtot:endindxtot);
                        patternstruct(sndcnt).ptnoffs{ptncnt} = offs(startindxtot:endindxtot); 
                        patternstruct(sndcnt).nxtonset{ptncnt} = ons(endindxtot+1);
                        patternstruct(sndcnt).lstoffset{ptncnt} = offs(startindxtot-1);
                    end
                end
            end
            endindx = 0;    
        end
   end
   patternstruct(sndcnt).totptnsng = ptncnt;
   ptntot = ptntot+ptncnt;
   patternstruct(sndcnt).all_lbls = char(all_lblscrnt);
   patternstruct(sndcnt).fname = fname{sndcnt};
   sndcnt = sndcnt+1;
   startindx = 0;
end
   patternstruct(sndcnt).ptntot = ptntot;                
           