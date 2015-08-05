[filenames dirname]=uigetfile('*.rec','MultiSelect','on')


for i=1:length(filenames);

        [AllFiles.sound{i,1} Fs,ChanNo]=ReadOKrankData(dirname,filenames{i}(1:end-4),1);    
%         AllFiles.Spect=load([filenames{i}(1:end-4) '.spect']);
        AllFiles.NoteData{i}=load([filenames{i}(1:end-4) '.not.mat']);
        
        for j=2:ChanNo
            [AllFiles.RawData{i,j} Fs]=ReadOKrankData(dirname,filenames{i}(1:end-4),j);           
        end;
end;
    