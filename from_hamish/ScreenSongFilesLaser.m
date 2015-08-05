function [ActualSongFiles, NoSongFiles, ProblemSongFiles] = ScreenSongFiles(DirectoryName,BirdName,FileType)

if (DirectoryName(end) ~= '/')
    DirectoryName(end + 1) = '/';
end

cd(DirectoryName);

% if strmatch(FileType,'evtaf')
%     AllSongFiles = dir(['*',BirdName,'*','.cbin'])
% else
    AllSongFiles = dir(['*',BirdName,'*'])
% end;   

ActualSongFiles = [];
AIndex = 0;
ProblemSongFiles = [];
PIndex = 0;
NoSongFiles = [];
NIndex = 0;
i=0
SongOrNoSong = 3;

i=1

while i < length(AllSongFiles)
%     keyboard;
    i=i+1;
 

    try
         
         PlotSpectrogram(DirectoryName,AllSongFiles(i).name,FileType);
         try
            [Laser Fs]=ReadEvTAFFile([DirectoryName AllSongFiles(i).name],1);           
         catch
             
         end;
%          skeyboard
         
         
         
         if exist('Laser')
             dt=1/Fs;
             t=dt:dt:length(Laser)*dt;
             hold on;
             plot(t,Laser,'b');             
         end;
  
        zoom xon;
        SongOrNoSong = menu(['File #',num2str(i),' of ',num2str(length(AllSongFiles)),': Has Song or Does Not Have Song'],'File has song','File does not have song', 'Play File', 'Quit','Back');
        disp(SongOrNoSong)
      
        if (SongOrNoSong == 1)
            AIndex = AIndex + 1;
            ActualSongFiles{AIndex} = [AllSongFiles(i).name];
            
%             fid = fopen('ActualSongFileNames.txt','a');
%             for j = 1:length(ActualSongFiles{AIndex});
%                 fprintf(fid,'%c',ActualSongFiles{AIndex}(j));
%             end
            fprintf(fid,'\n');
            fclose(fid);
        else
            if (SongOrNoSong == 4)
%                  keyboard;
                 break;
            else
           
        
                if (SongOrNoSong == 3)
                    if strcmp(FileType,'wav')
                        [rawsong Fs] = wavread([DirectoryName AllSongFiles(i).name]);
                    elseif strcmp(FileType,'okrank');                        
                        [rawsong, Fs]= ReadOKrankData(DirectoryName,AllSongFiles(i).name,0);
                    elseif strcmp(FileType,'evtaf');
                        [rawsong, Fs] = ReadEvTAFFile([DirectoryName AllSongFiles(i).name],0);                                                            
                    elseif strcmp(FileType,'intan');                             
                        [rawsong, Fs] = IntanRHDReadSong(DirectoryName,AllSongFiles(i).name);                     
                    elseif strcmp(FileType,'mat');
                        rawsong=load([DirectoryName AllSongFiles(i).name],'SongBout');
                        rawsong=SongBout; clear SongBout;
                    else
                        [rawsong,Fs] = soundin_copy(DirectoryName, AllSongFiles(i).name,'obs0r');
                    end;
                    soundsc(rawsong, Fs);
                    i = i - 1;
                else
                    NIndex = NIndex + 1;
                    NoSongFiles{NIndex} = AllSongFiles(i).name;
                end
            end
        end
    catch
        PIndex = PIndex + 1;
        ProblemSongFiles{PIndex} = AllSongFiles(i).name;
        %fid = fopen('ProblemSongFileNames.txt','a');
        %for j = 1:length(ProblemSongFiles{PIndex});
            %fprintf(fid,'%c',ProblemSongFiles{PIndex}(j));
        %end
        %fprintf(fid,'\n'); 
        %fclose(fid);
    end
    close(gcf);
end

good = ActualSongFiles;
bad = NoSongFiles;
no = ProblemSongFiles;

save('ScreenedFiles.mat','bad','good','no');
