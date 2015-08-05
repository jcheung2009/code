function dirf(argument,outfile,writetype)
%dirf
%pc command for creating batch files
%argument is anystring that can be passed to matlab command 'dir' - includes wildcards
%outfile is batchfile that is created
%writetype ids optional argument: default is to overwite fiel of smae name, 'a' causes append


if nargin < 3
  writetype='w'   
end


eval(['x=dir(','''',argument,'''',');']);
fid=fopen(outfile,writetype);
nout=size(x,1);
for i=1:nout
   fprintf(fid,'%s\n',x(i).name);
   fprintf(1,'%s\n',x(i).name);
end
fclose(fid);
disp(['number of files written = ',num2str(nout)]);