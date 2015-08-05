function rand_batch(in_batch,out_batch)

%function rand_batch(in_batch,out_batch)
% this function will take in a batch file (in_batch) and randomize the order of its contents

% open batch file and count number of lines
in_fid=fopen(in_batch);
n_lines=0;
while 1
    new_line = fgetl(in_fid);
    if new_line==-1
        break
    else n_lines = n_lines+1;
    end
end

% generate random order for new file

new_order=randperm(n_lines);

% write out file in the new order

out_fid=fopen(out_batch,'w');

%move pointer to the pertinent row, copy the row, reset the pointer, and repeat

for i=1:n_lines
    frewind(in_fid);
    current_line=new_order(i);
    for j=1:current_line
           line=fgetl(in_fid);
    end
    fprintf(out_fid,'%s\n',line);
end

fclose(in_fid);
fclose(out_fid);