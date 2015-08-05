function [out]=findsongs(optional_batch);
%function [out]=findsongs();
%
%  Scans through a batch file of songs, writing out two lists (as
%  mybatch_songs and mybatch_notsongs, if your batch file was
%  "mybatch").  Uses "isitsong" to categorize.
%


if nargin==1
   path='';
   batch=optional_batch;
else
  [batch,path] = uigetfile('*','Select Batch file to clean');
  pause(.1);
end

fin=fopen([path,batch]);
fout=fopen([path,batch,'_songs'],'wt');
fnot=fopen([path,batch,'_notsongs'],'wt');

out=[];
found=0;
checked=0;
file = fscanf(fin,'%s',1);
while ~isempty(file)
     fullfile=file;
     if ~(file(1)=='/')
          fullfile=[path,file];
     end

     if (fullfile(end-7:end)=='.not.mat')
       fullfile=fullfile(1:end-8);
     end

     if (fullfile(end-4:end)=='.cbin')
       type='obs0r';
     else
       type='w';
     end
     
     [song,fs]=soundin(path,file,type);
     if fs==-1
       fs=32000;
     end
     
     issong=isitsong(song,fs);
     
     out=[out;issong];
     checked=checked+1;
     if issong>0.75
          fprintf(fout,'%s\n',file);
          found=found+1;
     else
          fprintf(fnot,'%s\n',file);
     end
     file = fscanf(fin,'%s',1);
     if((checked<20)||(checked==20*ceil(checked/20)))
       disp(['Found ',num2str(found),' in ',num2str(checked),' files.']);
     end
     
end

fclose(fout);
fclose(fin);

