function find_noter2_batch(note,expr,batchname,batchin)

%[count, found_files]=find_noter2(note,expr,batchname)
%until the end of batchfile, find and return songs which contain note that matches expression
%note is a string label for a note
%expr is a string containing an expression that can be interpreted by matlab find command (e.g. '>60') 
%batchname is the name of the batch file that will be created from the
%files satisfying the conditions set in expr
%count retruns the number of INSTANCES expr is satisfied (not the number of
%files in which it is satisfied)

%get name of metafile containing notefile names

count = 0;
found_files=[];
msgs = [];
cnt = 0;


meta_fid=fopen(batchin);

while 1
   %get notefile name
     notefile = fscanf(meta_fid,'%s',1);
   %end when there are no more notefiles 
     if (isempty(notefile))
        disp('End of notefiles')
        break
     end
   
   %if notefile exists, get it
     if exist([notefile])   
       load([notefile]);
     else
       disp(['cannot find ', notefile])
     end
     
     
     %make sure labels is a column vector
   [x,y]=size(labels);
   if y > x
      labels=labels';
   end 
     
   %check to see if this file contains a note of specified type that satisfies expr
     durations =  get_durs(onsets,offsets,labels,note);
     test = eval(['find(durations',expr,')']);
   
     if nnz(test > 0)
        % increment count
        [m,n]=size(test);
        count=count+m;
        cnt = cnt+1;
        msg = (['In ',notefile,': ',note,' ',expr,' at occurance # ',mat2str(test)]);
        msgs{cnt}.txt = char(msg);

        % write name of file to found_files
        indx = strfind(notefile,'.not.mat');
        file_base = char(notefile(1:indx-1));
        found_files=[found_files;char(file_base)];
     end 
end

if count ~= 0
	%create msg file
	indx = strfind(batchname,'.batch');
    msg_name = [char(batchname(1:indx)) 'msg'];
	fid=fopen(msg_name,'w');
	for k = 1:length(msgs)
        fprintf(fid,'%s\n',char(msgs{k}.txt));
       %fprintf(1,'%s\n',char(found_files(k,:))); prints to screen
	end
         fclose(fid);
	
	%create batch file
	fid=fopen(batchname,'w');
	szfndfl = size(found_files);
	for k = 1:szfndfl(1)
        fprintf(fid,'%s\n',char(found_files(k,:)));
       %fprintf(1,'%s\n',char(found_files(k,:))); prints to screen
	end
         fclose(fid);
end
     