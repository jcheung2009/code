%2_19_2015
%plots mean and std pitch for morning and evening
%if less than 50 pts in the morning or evening, just takes day's mean/std


figure(6);hold on;
ans = input('keep plotting? (y/n):','s')

while strcmp(ans,'y')
        var = input('input variable:')
        colorst = input('st color marker:','s')
        stlncolor = input('st line color:','s')
        colorend = input('end color marker:','s')
        endlncolor = input('end line color:','s')
        x = datevec(var.fv(:,1));
        stind = find(x(:,4) >= 6 & x(:,4) <= 10);
        endind = find(x(:,4) >= 16 & x(:,4) <= 23);

            if length(stind) > 50 & length(endind) > 50
                stmean = mean(var.fv(stind,2));
                ststd = std(var.fv(stind,2));
                endmean = mean(var.fv(endind,2));
                endstd = std(var.fv(endind,2));

                sttime = var.fv(stind(1),1);
                endtime = var.fv(endind(end),1);

                plot(sttime,stmean,colorst,'MarkerSize',10);
                hold on;
                plot([sttime sttime],[stmean-ststd,stmean+ststd],stlncolor);
                hold on;
                plot(endtime,endmean,colorend,'MarkerSize',10);
                hold on;
                plot([endtime endtime],[endmean-endstd,endmean+endstd],endlncolor);
                hold on;
                plot([sttime endtime],[stmean endmean],'k');
                hold on;

                label = input('date label:','s')
                gtext(label)

            elseif length(stind) < 50 | length(endind) < 50
                daymean = mean(var.fv(:,2));
                tm = var.fv(floor(length(var.fv)/2),1);
                daystd = std(var.fv(:,2));

                plot(tm,daymean,colorst,'MarkerSize',10);
                hold on;
                plot([tm tm],[daymean-daystd,daymean+daystd],'k');
                hold on;

                label = input('date label:','s')
                gtext(label)
            end  
            
        ans = input('keep plotting? (y/n):','s')
end

           
            
         