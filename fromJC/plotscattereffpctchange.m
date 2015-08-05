
function [sumstats]=plotscattereffpctchange(sumdyn)
sumstats.effchangecomb=[];
sumstats.pctchangecomb=[];
sumstats.sdcomb=[];
figure;
for sdvl=1:length(sumdyn)
    cursd=sumdyn(sdvl)
    
    for indvl=2:length(cursd.tms)
        tmdiff=cursd.tms(indvl)-cursd.tms(indvl-1);
        pctchange=cursd.pct(indvl)-cursd.pct(indvl-1);
        sumstats.pctchange2=pctchange/tmdiff;
        if(cursd.contreff(indvl)>0&cursd.contreff(indvl-1)>0)
            eff1=mean([cursd.targeff(indvl-1) cursd.contreff(indvl-1)]);
            eff2=mean([cursd.targeff(indvl) cursd.contreff(indvl)]);
            
        else
            eff1=cursd.targeff(indvl-1);
            eff2=cursd.targeff(indvl);
        end
        effchange=eff2/eff1;
        sumstats.effchange2=effchange^(1/tmdiff);
        sumstats.effchangecomb=[sumstats.effchangecomb sumstats.effchange2];
        sumstats.pctchangecomb=[sumstats.pctchangecomb sumstats.pctchange2];
        sumstats.sdcomb=[sumstats.sdcomb sdvl]
    end
    plot(sumstats.effchangecomb,sumstats.pctchangecomb,'k.');
    hold on;
    
end

