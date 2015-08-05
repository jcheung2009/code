function [HVCy LMANy]=LMANchange(x)

LMANxc(1)=-100;
LMANxc(2)=46.68;
LMANA(1)=-0.49161;
LMANA(2)=0.30232;
LMANw(1)=21.41526;
LMANw(2)=45.68601;


HVCxc(1)=0.95611
HVCxc(2)=0;
HVCA(1)=0.25462;
HVCA(2)=-0.68668;
HVCw(1)=40.82262;
HVCw(2)=31.17482;



LMANy=(1+LMANA(1).*exp(-0.5.*((x-LMANxc(1))./LMANw(1)).^2))+(LMANA(2).*exp(-0.5.*((x-LMANxc(2))./LMANw(2)).^2))

HVCy=(1+HVCA(1).*exp(-0.5.*((x-HVCxc(1))./HVCw(1)).^2))+(HVCA(2).*exp(-0.5.*((x-HVCxc(2))./HVCw(2)).^2))

figure;
hold on;
plot(x,LMANy,'r');
plot(x,HVCy,'k');