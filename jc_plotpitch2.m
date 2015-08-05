%2_19_2015
%plots mean and std pitch of fv values (drug days)
%default = last 100 pts in drug condition

figure(6);hold on;

ans = input('keep plotting? (y/n):','s')

while strcmp(ans,'y')
    npts = input('number of samples/renditions from end:')
    if isempty(npts)
        npts = 100;
    end
    var = input('input variable:')
    markercolor = input('marker color:','s')
    linecolor = input('line color:','s')
    tm = var.fv(end,1);
    if strcmp(npts,'all')
        meanvar = mean(var.fv(:,2));
        stdvar = std(var.fv(:,2));
    else
        meanvar = mean(var.fv(end-npts:end,2));
        stdvar = std(var.fv(end-npts:end,2));
    end
    plot(tm,meanvar,markercolor,'MarkerSize',10);
    hold on;
    plot([tm tm],[meanvar-stdvar,meanvar+stdvar],linecolor);

    ans = input('keep plotting? (y/n):','s')
end
    
   