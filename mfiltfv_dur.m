function fv=mfiltfv_dur(fv,mindur,maxdur)
% fv = mfiltfv_dur(fv,mindur,maxdur);
%
% screens instances of syll in struct fv for durations <maxdur and >mindur
% ms and deletes those entries in fv
% 
% note this doesn't change the not.mat file, it just operates on fv struct.
%
%

killpnts=[];
for ii = 1:length(fv)
    theDur = fv(ii).offs(fv(ii).ind) - fv(ii).ons(fv(ii).ind);
    if(theDur < mindur || theDur > maxdur)
        killpnts = [killpnts ii];        
    end
end

fv(killpnts) = [];

return;

