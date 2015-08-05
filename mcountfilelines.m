function nLines = mcountfilelines(thefile)
%
% numlines = mcountfilelines(fid)
% returns number of lines in a text or dat file, like a batch file
%

fid = fopen(thefile,'rt');
nLines = 0;
while (fgets(fid) ~= -1),
  nLines = nLines+1;
end
fclose(fid);