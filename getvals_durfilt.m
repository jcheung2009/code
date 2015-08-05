function vals=getvals_durfilt(fv,NN,mindur,maxdur,varargin)
%vals=getvals_durfilt(fv,NN,mindur,maxdur);
%
% extracts pitch data from fv struct and dicards notes with durations
% < mindur milliseconds and > maxdur millisecons 
%
%

disp(['NN=',num2str(NN)]);
vals=zeros([length(fv),2]);
for ii = 1:length(fv)
    theDur = fv(ii).offs(fv(ii).ind) - fv(ii).ons(fv(ii).ind);
    if(theDur > mindur && theDur < maxdur)
        dn=fn2datenum(fv(ii).fn);
        vals(ii,:)=[dn,fv(ii).mxvals(NN+1)];
    end
end
if (length(varargin)>0)
    vals=[vals,zeros([size(vals,1),length(varargin)])];
    for ii=1:length(varargin)
        if (isfield(fv,varargin{ii}))
            for jj=1:length(fv)

                cmd=['vals(jj,ii+2)=fv(jj).',varargin{ii},';'];
                eval(cmd);
            end
        end
    end
end



return;