

clear;
warning('off')
batchfilename='batchfile';

FileNames=load_batchfile(batchfilename);
i=1;
analysis_syllable='a';

startpercent=0.758;
endpercent=0.8377;

 count=1;
%  startpercent=0.75;
%  endpercent=0.9077;
 
  Resultsdir=[];
%  Resultsdir='Results\'


%FileNames{2}='test.20101105.0002.wav';

for i=1:length(FileNames)

    
    if exist([FileNames{i} '.SAPFeatures.mat'])~=2
               CalculateSAPFeatures_SK(FileNames{i},44100);
    end;
    
    load([FileNames{i} '.SAPFeatures.mat']);
    
    notes=load([Resultsdir FileNames{i} '.not.mat']);
    [filtsong, Fs] = read_filt([FileNames{i} '.filt']);
    dt=1/Fs*1000;
    disp(FileNames{i})
    [spect, nfft, spect_win, noverlap, t_min, t_max, f_min, f_max]=read_spect([Resultsdir FileNames{i} '.spect']);
    dt_spect=t_max/length(spect);
%     dt_SAPFeat=SAPFeatures.Time(end)/length(SAPFeatures.AM)*1000;
%     
%     
    if ~strcmp(notes.labels,'0')
        
        syllableidx=strfind(notes.labels,analysis_syllable); % Find the indexes of the syllables to analyze. 
        freq_spect = [f_min, f_max];        
%         keyboard
        
        
        for j=1:length(syllableidx);
            idx=syllableidx(j);
            %find syllable 
            syllable=filtsong(notes.onsets(idx)/dt:notes.offsets(idx)/dt);
            keyboard;

            count=count+1;
        end;
    end;
    
end;
