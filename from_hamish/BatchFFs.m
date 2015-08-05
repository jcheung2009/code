

clear;
warning('off')
batchfilename='batch';

FileNames=load_batchfile(batchfilename);
i=1;

 analysis_syllable='a'
  startpercent=0.05;
% 
%  analysis_syllable='b'
%  startpercent=0.4;
 
%  
% analysis_syllable='d';
% startpercent=0.4;

 count=1;

 Resultsdir=[];


for i=1:length(FileNames)

    
%     if exist([FileNames{i} '.SAPFeatures.mat'])~=2
%                CalculateSAPFeatures_SK(FileNames{i},44100);
%     end;
%     
%     load([FileNames{i} '.SAPFeatures.mat']);
%     
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
%          keyboard
        
        
        for j=1:length(syllableidx);
            idx=syllableidx(j);
            %find syllable
            try
            syllable=filtsong(notes.onsets(idx)/dt:notes.offsets(idx)/dt);
            catch
                keyboard
            end
            
%             start=round(length(syllable)*startpercent);
%             sample=syllable(start:start+32);
            
%             figure;
%             
           

%             songsegment=songsegment(length(songsegment)*startpercent:length(songsegment)*endpercent);
%             [S F T P]=spectrogram(songsegment,256,125,256,Fs);
%             figure;
%             contour(T,F,10*log10(abs(P)));
% 
%             FeatSegment=SAPFeatures.FM(notes.onsets(idx)*dt_SAPFeat:notes.offsets(idx)*dt_SAPFeat);
%             FeatSegment=FeatSegment(length(FeatSegment)*startpercent:length(FeatSegment)*endpercent);
%             
%             figure(1); hold on; plot(FeatSegment,'r');
            
% %             plot(SAPFeatures.FM(notes.onsets(idx)*dt_SAPFeat:notes.offsets(idx)*dt_SAPFeat));
% %             plot(filesong(notes.onsets(idx)/dt:notes.offsets(idx)/dt))
%             keyboard;
            
              
             OutFF(count)=ff(syllable,Fs,1); %GetFF(syllable,Fs,startpercent,8);            
            count=count+1;
        end;
    end;
    
end;
OutFF=OutFF'
save('OutFF','OutFF');