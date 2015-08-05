function vals=getoffsets(fv,NN,varargin);
%vals=getvals(fv,NN,varargin);
%

vals=zeros([length(fv),2]);
for ii = 1:length(fv)
	dn=fn2datenum(fv(ii).fn);
	vals(ii,:)=[dn,fv(ii).mxvals];
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