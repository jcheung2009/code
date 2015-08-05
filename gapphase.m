function [g0,g1] = gapphase(fv,fignum)
%
% function [g0,g1] = gapphase(fv)
%
% returns normalized gap and gap+1 durations for phase plot
%
%
figure(fignum);hold on;
g0=zeros([length(fv),2]);
g1=zeros([length(fv),2]);
for i = 1:length(fv)
    ons = fv(i).ons;
    offs = fv(i).offs;
    durs = offs-ons;
    durs = durs(1:length(durs)-1);
    ons1 = ons(1:length(ons)-1);
    ons2 = ons(2:length(ons));
    gaps = (ons2-ons1)-durs;
    gaps1 = gaps(1:length(gaps)-1);
    gaps2 = gaps(2:length(gaps));
    plot(gaps1,gaps2,'ro-');    
end
hold off;
return;