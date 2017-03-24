function cleanbatchkeep(batchkeep,syll,expr)
%goes through files in batch list and sorts ones that have labels and those that don't
fid=fopen(batchkeep,'r');
fkeep=fopen([batchkeep,'.keep'],'w');
fdcrd=fopen([batchkeep,'.dcrd'],'w');
if ~isempty(syll)
    while (1)
        fn=fgetl(fid);
        if (~ischar(fn))
            break;
        end
        if (~exist(fn,'file'))
            disp(fn);
        end
       if (~exist(strcat(fn,'.not.mat'),'file'))
               fprintf(fdcrd,'%s\n',fn);
       else
           load(strcat(fn,'.not.mat'));
         a = strfind(labels, syll);
        if sum(a) > 0
                fprintf(fkeep,'%s\n',fn);
        else
            fprintf(fdcrd,'%s\n',fn);
        end
       end
    end
else
      while (1)
        fn=fgetl(fid);
        if (~ischar(fn))
            break;
        end
        if (~exist(fn,'file'))
            disp(fn);
        end
       if (~exist(strcat(fn,'.not.mat'),'file'))
               fprintf(fdcrd,'%s\n',fn);
       else
           load(strcat(fn,'.not.mat'));
         a = regexp(labels, expr);
        if sum(a) > 0
                fprintf(fkeep,'%s\n',fn);
        else
            fprintf(fdcrd,'%s\n',fn);
        end
       end
      end
end
fclose(fid);fclose(fkeep);fclose(fdcrd);
return

