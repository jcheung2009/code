clear;

filelist=dir('*.rec');

j=1
k=1
catchfile{1}=[];
notcatch{1}=[];

for i=1:length(filelist)
    rd=readrecf(filelist(i).name,0); 
%       keyboard
    if ((rd.iscatch~=0)|(rd.catch~=0));
        catchfile{j}=filelist(i).name;
        j=j+1;        
        disp(filelist(i).name)
    else
        notcatch{k}=filelist(i).name;
        k=k+1;
    end;
    
end;

try mkdir('Catch')
catch
end;

try mkdir('NotCatch')
catch
end;

% keyboard
for i=2:length(catchfile);
      disp(i)
%     try 
      copyfile([catchfile{i}(1:end-4) '.tmp'],'./Catch');
      copyfile([catchfile{i}(1:end-4) '.cbin'],'./Catch');
      copyfile(catchfile{i},'./Catch');
%     catch
%     end;
        
end;
    
% for i=2:length(notcatch);
%     disp(i)
% %     try 
%       copyfile([notcatch{i}(1:end-4) '.tmp'],'./NotCatch');
%       copyfile([notcatch{i}(1:end-4) '.cbin'],'./NotCatch');
%       copyfile(notcatch{i},'./NotCatch');
% %     catch
% %     end;
%         
% end;