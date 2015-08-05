% clear;

 
   filename=uigetfile('*','MultiSelect','on');

%  filename=AllChanDecomp2Files

% [sound Fs ChanNo]=readOKRankData('.',filename{1},0);
SaveDir=['./' 'UnDirChanByChanDecomp'];

if ~exist(SaveDir);
    mkdir(SaveDir);
end;

save([SaveDir '/Fs'], 'Fs', 'filename');

%%%%%%%%%%%%%%%%
%Concatenate All Songs
%%%%%%%%%%%%%%%%%%

    data=[]
    for j=1:length(filename)
        SongBout=read_filt([filename{j} '.filt']);
%         ChanNoStr=num2str(i);
        data=[data SongBout'];
    end;
    write_filt([SaveDir '/' 'AllSongs' '.filt'],data,Fs);
    
    
% %%%%%%%%%%%%%%%
% Concatenate All EPhys Channels. 
% %%%%%%%%%%%%%%%%%


for i=1:32
    
    data=[];
    
    for j=1:length(filename)
        [amplifier_data,t_amplifier,Fs,filedata,song]=IntanRHDImportAll('./',filename{j});
        data=[data amplifier_data(i,:)];

    end;
        ChanNoStr=num2str(i);
        save([SaveDir '/' 'AllSongs' 'Chan' ChanNoStr '.mat'],'data');
end;
     

%%%%%%%%%%%%%%%
% Concatenate All Note Files
%%%%%%%%%%%%%%%%%cd ..

data=[]
FullLength=0;
offsets=[]
onsets=[]
labels=[]
Fs=30000;

    for j=1:length(filename)

        NewData=load([filename{j} '.not.mat']);
        offsets=[offsets; NewData.offsets+FullLength]
        onsets=[onsets; NewData.onsets+FullLength]
        labels=[labels NewData.labels];

        bout.offsets{j}=offsets;
        bout.onsets{j}=onsets;
        bout.labels{j}=labels;
        
        [FiltSong Fs]=read_filt([filename{j} '.filt']);
        FullLength=FullLength+(length(FiltSong)*(1/Fs)*1000);

    end;
    min_dur=NewData.min_dur;
    min_int=NewData.min_int;
    sm_win=NewData.sm_win;
    threshold=NewData.threshold;
    
      save([SaveDir '/' 'AllSongs' 'SongChan' '.not.mat'],'offsets','onsets','Fs','labels','min_dur','min_int','sm_win','threshold','filename','bout');
