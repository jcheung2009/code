function vals=getvals3(fv,NN,varargin);
%vals=getvals(fv,NN,varargin);
%%%use with findwnote5 for datenum


disp(['NN=',num2str(NN)]);
dt=zeros([length(fv),7]);
seconds = zeros(length(fv),1);
for i = 1:length(fv)
    dt(i,:) = [fv(i).yr, fv(i).mn, fv(i).dy, fv(i).hr, fv(i).mnut, fv(i).fnm, 0];
    seconds(i) = fv(i).scnd;
end

[b ii] = unique(dt(:,4:5),'rows','first');

for a = 1:length(ii)
    if ~(a == length(ii))
        sub_second = seconds(ii(a):ii(a+1)-1);
        sub_dt = dt(ii(a):ii(a+1)-1,:);
        sub_dt(:,7) = sub_second;
        UV = [];
        [b sortvec] = sort(sub_dt(:,6));
        UV(sortvec) = ([1;diff(b)] ~= 0);
        x = find(UV == 1);
        %[b x] = unique(sub_dt(:,6),'rows','first');
            if length(x) == 1
                    sub_dt = sub_dt; 
            elseif length(x) > 1
                for c = 2:length(x)
                    if ~(c == length(x))
                     sub_dt(x(c):x(c+1)-1,7) = sub_dt(x(c):x(c+1)-1,7) + sub_dt(x(c)-1,7);
              
                    elseif (c == length(x))
                         if ~(x(c) == 1)
                          sub_dt(x(c):size(sub_dt,1),7) = sub_dt(x(c):size(sub_dt,1),7) + sub_dt(x(c)-1,7);
                        elseif (x(c) == 1)
                            disp('hey')
                        end
                    end
                end
            end
        
            dt(ii(a):ii(a+1)-1,:) = sub_dt;
            
    elseif a == length(ii)
        sub_second = seconds(ii(a):length(dt));
        sub_dt = dt(ii(a):length(dt),:);
        sub_dt(:,7) = sub_second;
        
        [b x] = unique(sub_dt(:,6),'rows','first');
        if length(x) == 1
            sub_dt = sub_dt;
        elseif length(x) > 1
            for c = 2:length(x)
                if ~(c == length(x))
                    sub_dt(x(c):x(c+1)-1,7) = sub_dt(x(c):x(c+1)-1,7) + sub_dt(x(c)-1,7);
                elseif c == length(x)
                    sub_dt(x(c):size(sub_dt,1),7) = sub_dt(x(c):size(sub_dt,1),7) + sub_dt(x(c)-1,7);
                end
            end
        end
        
        dt(ii(a):length(dt),:) = sub_dt;
        
    end
end

vals=zeros([length(fv),2]);
for ii = 1:length(fv)
 	dn=datenum([dt(ii,1), dt(ii,2), dt(ii,3), dt(ii,4), dt(ii,5), dt(ii,7)]);
	vals(ii,:)=[dn,fv(ii).mxvals(NN+1)];
    %vals(ii,:)=[dn,fv(ii).maxvol(1)];
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
