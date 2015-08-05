function mk_rmdata(batch,onlyebin);
% usage : mk_rmdata(batch,rec_too);
% set rec_too=1 to also delete the .rec files
% set rec_too=0 if want to delete all file endings

% takes in a file with a liost of filenames, and makes a 
% shell script to delete those files
% this is necessary because deleting them from matlab takes forever
% and i have not had a chance to write a perl script to do it 

% type '!csh ./rmdata' in matlab window to remove files


fid = fopen(batch,'r');
fid2 = fopen('rmdata','w');
fprintf(fid2,'#!/bin/sh\n');
while(1)
    fn = fgetl(fid);
    if (~ischar(fn))
        break;
    end
	
    if length(fn>2)
	p = findstr(fn,'.');
	if (length(p)>0)
            if (onlyebin==1)
                cmd = ['rm -f ',fn];
                fprintf(fid2,'%s\n',cmd);
            else
                cmd = ['rm -f ',fn(1:p(end)),'*'];
                fprintf(fid2,'%s\n',cmd);
            end
		else
			cmd=['rm -f ',fn];
			fprintf(fid2,'%s\n',cmd);
		end
	end

end
fclose(fid);fclose(fid2);
eval(['!chmod u+x rmdata']);
return;
