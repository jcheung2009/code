

function [vals]=getconsec(inarray)
temp=inarray;
df=diff(temp);
pp = find(df~=1);
if (length(pp)==0)
	vals=[1,length(temp)];
else
	vals=zeros([length(pp)+1,2]);
	vals(1,:)=[1,pp(1)];
    ind(1,:)=[1,pp(1)];
    if (length(pp)>1)
        	for ii = 2:length(vals)-1
                ind(ii,:)=[ind(ii-1,2)+1,pp(ii)];
                vals(ii,:)=[temp(ind(ii-1,2)+1),temp(pp(ii))];
             end
        end
        vals(end,:)=[temp(pp(ii)+1),temp(length(temp))];
end

