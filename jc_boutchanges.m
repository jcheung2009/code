function [boutfits] = jc_boutchanges(indCell,incell,fittype,shuff_y_n,time_o_rend,pltit,subplt,pre_o_post)
%indCell from jc_clusterbouts, should correspond to cell used to make
%indCell
%fittype = 'l' for linear regression, 'e' for exponential fit
%shuff_y_n = 'y' shuffles renditions in each bout to compute random fits,
%'n' does not shuffle
%time_o_rend = fit to bouts by time or renditions
%fits a line to the renditions in each bout and compares the change within
%and between bouts
%b1 = slope, b2 = intercept
%boutfits = structure with fields: (length of structure is equal to number
%of bouts in indCell)
%   coeff = [b1, b2]
%   length = # renditions
%   r2 = rsquared for linear fit
%   res = residuals
%   inboutchange = abs change in pitch (hz) from beginning to end of bout
%   btwnboutchange = abs change in pitch (hz) from end of bout to beginning
%   of next bout
%   st = predicted pitch at bout start
%   end = predicted pitch at bout end


if strcmp(fittype,'runavg')
    boutfits = struct('runavg',[],'length',[]);
    runavg = {};
else
    boutfits = struct('coeff',[],'length',[],'r2',[],'res',[],'inboutchange',[],'btwnboutchange',[],'st',[],'end',[]);
end

for i = 1:length(indCell)
    cmap = hsv(max(indCell{i}));
    boutfit = []; %need to keep separate boutfit that is cleared for each cell, use for measuring change between consecutive bouts
    for ii = 1:max(indCell{i})
        if sum(indCell{i}==ii) < 5 %exclude bouts with less than 5 renditions
            boutfit = [boutfit; [NaN(1,3)]];
            continue
        else
            if strcmp(fittype,'l')
                pitchvals = incell{i}(indCell{i}==ii,2) - mean(incell{i}(indCell{i}==ii,2));%normalize by mean subtraction 
                    
                    if strcmp(shuff_y_n,'y')%shuffling bout to compute slopes by random 
                        pitchvals = pitchvals(randperm(length(pitchvals)));
                    end
                    
                    if strcmp(time_o_rend,'t')%for correlation by time 
                        xvals = incell{i}(indCell{i}==ii,1);
                        xvals = datevec(xvals - xvals(1));
                        xvals = etime(xvals,zeros(size(xvals)));
                    elseif strcmp(time_o_rend,'r');%correlation by renditions
                        xvals = [1:1:sum(indCell{i}==ii)]';
                    end
                    
                b = polyfit(xvals,pitchvals,1);%fits line to renditions in bout
                abschange = polyval(b,sum(indCell{i}==ii)) - polyval(b,1); %change within bout from first rendition to last 
                SStotal = sum((pitchvals - mean(pitchvals)).^2);
                yvals = polyval(b,xvals);
                res = pitchvals - yvals;
                SSresiduals = sum(res.^2);
                r2 = 1 - (SSresiduals/SStotal);

                boutfits.coeff = [boutfits.coeff; b];
                boutfits.length = [boutfits.length; sum(indCell{i} == ii)];
                boutfits.r2 = [boutfits.r2; r2];
                boutfits.res = [boutfits.res; res];
                boutfits.inboutchange = [boutfits.inboutchange; abschange];
                boutfits.st = [boutfits.st; polyval(b,1)];
                boutfits.end = [boutfits.end; polyval(b,sum(indCell{i}==ii))];
                
                boutfit = [boutfit; [b sum(indCell{i}==ii)]]; %line fit coeff and number of renditions in that bout

                if ~isempty(pltit)
                    figure(pltit);hold on;subplot(1,2,subplt);
                    plot(xvals,polyval(b,xvals) - polyval(b,1),'color',cmap(ii,:));%align by beginning
%                     figure(pltit);hold on;subplot(1,2,2);
%                     plot(xvals - xvals(end),polyval(b,xvals)-polyval(b,xvals(end)),'color',cmap(ii,:));%align by end
                end
                    
            elseif strcmp(fittype,'runavg')
                if sum(indCell{i}==ii) < 20 %exclude bouts with less than 20 renditions
                    continue
                end
                    
                pitchvals = incell{i}(indCell{i}==ii,2) - mean(incell{i}(indCell{i}==ii,2));%normalize by mean subtraction 
                    
                if strcmp(shuff_y_n,'y')%shuffling bout to compute slopes by random 
                    pitchvals = pitchvals(randperm(length(pitchvals)));
                end
                
                run = conv(pitchvals,ones(5,1)/5,'same');
                runavg = [runavg; run];
                boutfits.length = [boutfits.length; sum(indCell{i}==ii)];
                
                figure(pltit);hold on;subplot(1,3,subplt);
                plot(run-run(1),'color',cmap(ii,:));
                    
            elseif strcmp(fittype,'e')
                expfun = @(b,x) b(1)*exp(-b(2)*x);
                
                %initial estimates
                ind = find(indCell{i}==ii);
                b2 = (log(incell{i}(ind(1),2)/incell{i}(ind(end),2)))/(sum(indCell{i}==ii)+1);
                b1 = incell{i}(ind(1),2)/exp(-b2);
                
                [beta res] = nlinfit((1:1:sum(indCell{i}==ii))',incell{i}(indCell{i}==ii,2),expfun,[b1 b2]);
                abschange = (beta(1)*exp(-beta(2))) - (beta(1)*exp(-beta(2)*sum(indCell{i}==ii)));
                
                boutfits.coeff = [boutfits.coeff; beta];
                boutfits.length = [boutfits.length; sum(indCell{i} == ii)];
                boutfits.res = [boutfits.res; res];
                boutfits.inboutchange = [boutfits.inboutchange; abschange];
                
                boutfit = [boutfit; [beta sum(indCell{i}==ii)]];
                
                if ~isempty(pltit)
                    xvals = 1:1:sum(indCell{i}==ii);
                    yvals = beta(1)*exp(-beta(2)*xvals);
                    figure(pltit);hold on;subplot(1,2,1);
                    plot(xvals,yvals - yvals(1),'color',cmap(ii,:));%align by beginning
                    figure(pltit);hold on;subplot(1,2,2);
                    plot(xvals - sum(indCell{i}==ii),yvals-yvals(end),'color',cmap(ii,:));%align by end
                end                   
            end
        end
    end
    
    
    if length(boutfit) > 1
        if strcmp(fittype,'l')
            for ii = 1:length(boutfit)-1
                abschange = polyval(boutfit(ii+1,1:end-1),1) - polyval(boutfit(ii,1:end-1),boutfit(ii,end));%change in pitch from beginning of next bout to end of last bout
                boutfits.btwnboutchange = [boutfits.btwnboutchange; abschange];
            end
            boutfits.btwnboutchange = boutfits.btwnboutchange(~isnan(boutfits.btwnboutchange));
        elseif strcmp(fittype,'e')
            for ii = 1:length(boutfit)-1
                    b1 = boutfit(ii+1,1);
                    b2 = boutfit(ii+1,2);
                    abschange = b1*exp(-b2) - b1*exp(-b2*boutfit(ii,3));
                    boutfits.btwnboutchange = [boutfits.btwnboutchange; abschange];
            end
            boutfits.btwnboutchange = boutfits.btwnboutchange(~isnan(boutfits.btwnboutchange));
        end
    end
    
end

if strcmp(fittype,'runavg')
        maxlength = max(boutfits.length);
        runavg2 = cellfun(@(x) [x;NaN(maxlength-length(x),1)],runavg,'UniformOutput',false);
        runavg2 = horzcat(runavg2{:});
        boutfits.runavg = runavg2;
        
        if strcmp(pre_o_post,'pre')
            figure(pltit);hold on;subplot(1,3,3);
            plot(nanmean(runavg2,2),'k');hold on;
            plot(nanmean(runavg2,2)+nanstderr(runavg2,2),'k');hold on;
            plot(nanmean(runavg2,2)-nanstderr(runavg2,2),'k');hold on;
        else
            figure(pltit);hold on;subplot(1,3,3);
            plot(nanmean(runavg2,2),'r');hold on;
            plot(nanmean(runavg2,2)+nanstderr(runavg2,2),'r');hold on;
            plot(nanmean(runavg2,2)-nanstderr(runavg2,2),'r');hold on;
        end
end 
