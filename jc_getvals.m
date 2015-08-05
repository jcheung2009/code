function [vals] =jc_getvals(fv,NN,varargin);
%vals=getvals(fv,NN,varargin);
%

%disp(['NN=',num2str(NN)]);
vals=zeros([length(fv),3]);
%vlsorfn = {};
for ii = 1:length(fv)
%  	dn=datenum([fv(ii).yr fv(ii).mon fv(ii).dy fv(ii).hr fv(ii).min fv(ii).scnd]);
    dn = fv(ii).datenm;
    %vals(ii,:)=[0,mean(diff(fv(ii).mxvals)),fv(ii).ind];
    if length(fv(ii).mxvals) > 1
        vals(ii,:)=[dn,mean(diff(fv(ii).mxvals)),fv(ii).ind];
    else
        vals(ii,:) = [dn,fv(ii).mxvals,fv(ii).ind];
    end
        %vals(ii,:)=[dn,fv(ii).maxvol(1)];
%     vlsorfn{ii} = fv(ii).fn;
end

% if (length(varargin)>0)
%     vals=[vals,zeros([size(vals,1),length(varargin)])];
%     for ii=1:length(varargin)
%         if (isfield(fv,varargin{ii}))
%             for jj=1:length(fv)
% 
%                 cmd=['vals(jj,ii+2)=fv(jj).',varargin{ii},';'];
%                 eval(cmd);
%             end
%         end
%     end
% end
return;
