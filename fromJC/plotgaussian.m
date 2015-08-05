function plotgaussian(axh,xbnds,mu,sigma,color,lstyle,flip)
axes(axh);
pt1=1/(sigma*sqrt(2*pi))
pt2=exp(-((xbnds-mu).^2)/(2*(sigma^2)));
y=pt1*pt2*[xbnds(2)-xbnds(1)];
if(flip)
   if(exist('lstyle'))
        plot(y,xbnds,'Color',color,'Linestyle',lstyle,'Linewidth',4);
    else
        plot(y,xbnds,'Color',color);
    end    
else
    if(exist('lstyle'))
        plot(xbnds,y,'Color',color,'Linestyle',lstyle,'Linewidth',4);
    else
        plot(xbnds,y,'Color',color);
    end
end