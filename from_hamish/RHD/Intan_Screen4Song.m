clear;


tic;
files=dir('*.rhd');

mkdir('Screened');


PreSong=5;
PostSong=5; %in s
PrePad=0;

dt=1/20000;
gap=2000;%ms
gap=((gap/1000)/dt);

     waithand=waitbar(1/length(files),files(1).name);

for i=1:length(files);
    
     waitbar(i/length(files),waithand,files(i).name);
    
     try
%           keyboard
        [data time Fs filedata song]=Import_Intan_RHD2000(files(i).name);
        
       
%                         figure;
%            
%                 [S,F,T,P] = spectrogram(song,256,250,256,Fs);
%                 surf(T,F,10*log10(P),'edgecolor','none'); axis tight; view(0,90);ylim([0 8000]);
%                 
%                 
     catch 
         song=[]
     end;
    
    if ~isempty(song)

            song=[zeros(1,PrePad*Fs) song];
            j=1;

            start=find(song>(1));
            a=find(diff(start)>(2*Fs));
            startidx=[];
            stopidx=[];

            if ~isempty(a)

                    a=[1 a];
                    
                    stopidx=start(a);
                    startidx=start(a+1);

                    stopidx(1)=[];
                    startidx(end)=[];
  
            end;



            for j=1:length(startidx);


                if startidx(j)-(Fs*PreSong) > 0
                    idx=startidx(j)-Fs*PreSong;
                else
                    idx=1;
                end;
                
                if stopidx(j)+(Fs*PostSong) < length(song)
                    endidx=stopidx(j)+(Fs*PostSong);
                else
                    endidx=length(song);
                end;
                

                
                if ((endidx-idx)*Fs) > (Fs*(PreSong+PostSong+0.5)) 
                        SongBout=song(idx:endidx);


                        OutFile=['Screened\' files(i).name(1:end-4) 'Bout'  num2str(j) '.mat']

                        ADCOut=data(:,idx:endidx);
                

                        save(OutFile,'ADCOut', 'Fs', 'filedata', 'SongBout');                
                end;
               
     
              

            end;

            
        end;
        
%         movefile(files(i).name,['CompletedFiles\' files(i).name]);
end;

close(waithand);
toc
disp(length(files));
