%wrbnitten 9.20.08
%called by mumeta_compar, and by mure_compar

%principal input is a struct
% fields are ps(run_num).birdind
%            ps(run_num).indtoplot
%            ps(run_num).runtype
%            ps(run_num).ntind
             %ps.ax
             %ps.plotextraline

function [ax] = inactivplotcomparsingle(avls,ps,bs)

xspc=1;
xgap=2;

% ax(1)=subplot(131);
% ax(2)=subplot(132);
% ax(3)=subplot(133);

ct(1:3)=0;
for ii=1:length(ps)
    ax=ps(ii).ax;
    run_nm=ii;
    brdind=ps(run_nm).birdind
    rtype=ps(run_nm).runtype;
    ntind=ps(run_nm).ntind
    indplt=ps(run_nm).indtoplot;
    %get the data
    cmd=['cd ' bs(brdind).path 'datasum']
    eval(cmd);
    cmd=['load ' bs(brdind).matfilename]
    eval(cmd);
   
%    %set the axis 
%    if (rtype=='do')
%        axes(ax(1));
%        ctvl=1;
%    elseif(rtype=='up')
%        axes(ax(3));
%        ctvl=3;
%    else
%        axes(ax(2));
%        ctvl=2;
%    end

   %plot the lines.  (arrows in illustrator);
   
       ac=avls.acmean(ntind,indplt);
       mu=avls.mumean(ntind,indplt);
       acerr=avls.acstderr(ntind,indplt);
       muerr=avls.mustderr(ntind,indplt);
       
       %        xvls=ct(ctvl)+xspc:xspc:ct(ctvl)+length(acz)/xspc;
       muvl=mu
       acvl=ac;
       
       [psout]=getstyle2('do');
       ms=[];
       for jj=1:length(ac)
           if (ps.plotextraline)
                bot1=[muvl(jj)-muerr muvl(jj)+muerr]
                bot2=[acvl(jj)-acerr acvl(jj)+acerr]
                [psextra]=getstyle2('ex');
                psextra(2).pts=[.495 muvl(jj) .505 muvl(jj)];
                psextra(1).pts=[.495 acvl(jj) .505 acvl(jj)]
                psextra(2).fillpts=[0.495 bot1(1); 0.505 bot1(1); 0.505 bot1(2); 0.495 bot1(2);]
                psextra(1).fillpts=[0.495 bot2(1); 0.505 bot2(1); 0.505 bot2(2); 0.495 bot2(2)]
                ms=[];
                fillcolor(psextra);
                hold on;
                lineplot(psextra,ms);
                hold on;
           end
           
           psout(1).pts=[0.5 acvl(jj) 0.5 muvl(jj)];
           
           lineplot(psout(1),ms);
           hold on;
       end
          
      
%        ct(ctvl)=ct(ctvl)+length(acz)/xspc+xgap;
end
       