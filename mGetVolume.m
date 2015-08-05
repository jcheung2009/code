function [vols] = mGetVolume(batch,note)
%
% [vols] = mGetVolume(batch,note)
%
% returns structure with volume and time for each note in Batch
%

 fv=findwnote4(batch,note,'','',.01,[1000 4000],512,1,'obs0');
 vols=getvols(fv,1,'TRIG');
 vols(:,2) = log10(vols(:,2));