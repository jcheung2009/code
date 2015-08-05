function [maxtot,ext,subext,maxsub,beta,l] = subextentrp(entrpy_strct,l,do_plot,name)

[maxtot,i] = max(entrpy_strct.tot_vect);

ext = linspace(0,maxtot,i(1));
subext  = entrpy_strct.tot_vect(1:i(1))-ext;

if l  == 0
[maxsub,l] = max(subext);
else
    maxsub = subext(l);
end
beta = nlinfit([1:l],subext(1:l),@mylog2,[subext(1) .5]);

if do_plot
figure; hold on;
% 
plot(entrpy_strct.tot_vect(1:l),'k');
plot(ext(1:l),'r');
plot(subext(1:l),'bo');
plot([1:l],mylog2(beta,[1:l]),'b')
end

save([name '.subext.mat'],'maxtot','entrpy_strct','ext','subext','maxsub','beta','l')