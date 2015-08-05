function out=make_color_map(col_L,do_pure)
%a=hot;
a=jet;
if col_L<=64
   int=floor(length(a)/(col_L));
   col_mat=a(1:int:int*(col_L),:);
else
   n_interp=ceil(col_L/64);
   for x=1:3;
       new_a(:,x)=interp(a(:,x),n_interp);
%        new_a(:,x)=interp(a(:,x),2);
   end
   int=floor(length(new_a)/(col_L));
   col_mat=abs(new_a(1:int:int*(col_L),:));
   col_mat=col_mat/max(max(col_mat));
end

out=col_mat;
out = [[0 0 0];out];

if do_pure
    out = out(


