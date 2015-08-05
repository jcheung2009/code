 function fv=transval(fv,offset);
%[datsvnt,datsv]=repanal(bt,NT);
% datsvnt - data for single specified note
%     [which rep indx in song, fix(label), datenum of song,rep cnt]
%
% datsv - data for all repeated notes
%       [datenum,btfulenum,fix(label), repcnt];
%

for ntcnt=1:length(fv)
    
    lblen=length(fv(ntcnt).lbl);
    indvl=fv(ntcnt).ind;
    if ((indvl+offset)>lblen)
        fv(ntcnt).trans='nd';
    
    else
        for ii=1:length(offset)
            fv(ntcnt).trans(ii)=fv(ntcnt).lbl(indvl+ii);
            
        end
        end    
end       
        
        
     
