function [part, total] = pattern_parser(pattern, TM, N_M, RMb, RMe, OMb, OMe)
%  pattern_parser: parses "pattern", as inputed by user, into well defined
%  parts that part_matcher screens the list of labels for
%  function [part, total] = pattern_parser(pattern, TM, N_pM, N_tM, RMb, RMe, OMb, OMe)

%iniatilize a few variables
repeat = 1;
strindx = 1;
partnum = 1;
leng = length(pattern);
%the main parsing loop
while strindx ~= leng +1
  
    if pattern(strindx) == '~'              
        part(partnum).type = 'neg';
        part(partnum).strnum = 1;
        if length(N_M) == 2
        part(partnum).string{1} = char(pattern((N_M(1))+1:(N_M(2)-1)));
        part(partnum).stringlength = length(part(partnum).string{1});
        strindx = (N_M(2)+1);
        else 
        part(partnum).string{1} = char(pattern((N_M(3))+1:(N_M(4)-1)));
        part(partnum).stringlength = length(part(partnum).string{1});
        strindx = (N_M(4)+1);
        end
        partnum = partnum+1;
        
    elseif pattern(strindx) =='*'
        part(partnum).type = 'star';
        part(partnum).stringlength = 0;
        part(partnum).strnum = [];
        part(partnum).string = [];
        strindx = strindx +1;
        partnum = partnum +1;
        
    elseif pattern(strindx) == '['
        part(partnum).type = 'rep';
        revpartindx = RMe(strfind(RMb,strindx));
        part(partnum).stringlength = [];
        %searching for nested optionals
        ROMb = strfind(pattern(strindx+1:revpartindx-1),'{');
        if isempty(ROMb) 
            part(partnum).strnum = 1;
            part(partnum).string{1} = char(pattern(strindx+1:revpartindx-1));
            part(partnum).stringlength = length(part(partnum).string{1});
            strindx = revpartindx;
            partnum = partnum +1;
        else ROMe = strfind(pattern(strindx+1:revpartindx-1),'}');
            %create the binary choice matrix 
                n = length(ROMe);
                C = zeros(2^n,n);
                for i = 1:2^n
                    q=i-1;
                    j = 1;
                    while q ~= 0
                    C(i,j) = rem(q,2);
                    q = floor(q/2);
                    j = j+1;
                    end
                end    
            part(partnum).strnum = 2^n;
             %impose binary choice matrix on ROM 
            M_ROMb = kron(ones(2^n,1),ROMb);
            M_ROMe = kron(ones(2^n,1),ROMe);
            CM_ROMb = C.*M_ROMb;
            CM_ROMe = C.*M_ROMe;
              %remove indices of selected optionals from the indices
              %between the repeats
               for j = 1:2^n
                   V = [];
                   for i = 1:n
                       V = [V,[CM_ROMb(j,i):CM_ROMe(j,i)]];
                   end
                   I = setdiff([1:length(strindx+1:revpartindx-1)],V);
                   I = setdiff(I,[ROMe,ROMb]);
                   part(partnum).string{j} = pattern(I+strindx);
                   part(partnum).stringlength = [part(partnum).stringlength, length(pattern(I+strindx))];
               end
            partnum = partnum + 1;
            strindx = revpartindx;      
        end
        
    elseif isletter(pattern(strindx))
        part(partnum).type = 'norm';
        revpartindx = strfind(isletter(pattern) ,0);
        revpartindx = min(revpartindx(revpartindx>strindx));
        part(partnum).stringlength = [];
        %searching for nested optionals
        NOMb = strfind(pattern(strindx:revpartindx-1),'{');
        if isempty(NOMb) 
            part(partnum).strnum = 1;
            %pattern(strindx:revpartindx-1)
            part(partnum).string{1} = pattern(strindx:revpartindx-1);
            part(partnum).stringlength = length(part(partnum).string{1});
            strindx = revpartindx; 
            partnum = partnum +1;
        else NOMe = strfind(pattern(strindx:revpartindx-1),'}');
            %create the binary choice matrix
                n = length(NOMe);
                C = zeros(2^n,n);
                for i = 1:2^n
                    q=i-1;
                    j = 1;
                    while q ~= 0
                    C(i,j) = rem(q,2);
                    q = floor(q/2);
                    j = j+1;
                    end
                end
            part(partnum).strnum = 2^n;
             %impose binary choice matrix on NOM 
            M_NOMb = kron(ones(2^n,1),NOMb);
            M_NOMe = kron(ones(2^n,1),NOMe);
            CM_NOMb = C.*M_NOMb;
            CM_NOMe = C.*M_NOMe;
              %remove indices of selected optionals from the indices
              part(partnum).stringlength = []; 
              for j = 1:2^n
                   V = [];
                   for i = 1:n
                       V = [V,[CM_NOMb(j,i):CM_NOMe(j,i)]];
                   end
                   I = setdiff([1:length(strindx+1:revpartindx-1)],V);
                   I = setdiff(I,[ROMe,ROMb]);
                   part(partnum).string{j} = pattern(I+strindx);
                   part(partnum).stringlength = [part(partnum).stringlength, length(part(partnum).string{j})];
               end
               strindx = revpartindx;  
               partnum = partnum +1;             
        end
     
    elseif pattern(strindx) == '{'
        part(partnum).type = 'opt';
        part(partnum).strnum = 1;
        revpartindx = OMe(strfind(OMb,strindx));
        part(partnum).string{1} = pattern(strindx+1:revpartindx-1);
        part(partnum).stringlength = length(part(partnum).string{1});
        partnum = partnum +1;
        strindx = revpartindx;
        
    elseif pattern(strindx) == '}' | pattern(strindx) == ']'
         strindx = strindx +1;
        
    elseif pattern(strindx) =='$'
        total = partnum-1;
        strindx = strindx+1;
        
    end
    
end




                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   