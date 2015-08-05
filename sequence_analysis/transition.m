function transition_bck(trns_strct,rptstrct)

%
%
%
outfile = 'plot.dot';

matrix = trns_strct.mtrx;
labels = trns_strct.lbls;
  
if ~isempty(rptstrct)
    rptparams = rptstrct.prms;
    rptlbls = rptstrct.lbls;
end

fid = fopen(outfile, 'wt');
min_transition = 0.05;
[rows, columns] = size(matrix);
if rows ~= columns
    fprintf(fid, '%s\n', 'help');
end

fprintf(fid, '%s\n', 'digraph abstract {');
fprintf(fid, '%s\n', 'size="7.5,10";');
fprintf(fid, '%s\n', 'page="8.5,11";');
fprintf(fid, '%s\n', 'node [fillcolor="yellow"];');;

for i = 1:rows
for j = 1:columns
  if (matrix(i,j) > min_transition)
     if i == j & ~isempty(rptstrct)
        for k = 1:length(rptlbls)
            if char(rptlbls(k)) == labels(i)
                fprintf(fid, '%s->%s [label = "%0.2f %0.2f" weight = "%2.0f"];\n', labels(i), labels(j),rptparams(k,:),exp(10*matrix(i,j)));
            end        
        end
     else
         fprintf(fid, '%s->%s [label = "%0.2f" weight = "%2.0f"];\n', labels(i), labels(j), matrix(i,j),exp(10*matrix(i,j)));
     end    
   end
end
end
fprintf(fid,'%s\n', '}');

fclose(fid);