load ResultFile;
load ChanList;

NumChans=length(Result);
NumTrials=length(Result(2).WarpedSpikeTimes);

gaussFilter = gausswin(5)
gaussFilter = gaussFilter / sum(gaussFilter);

writerObj = VideoWriter('TrialByTrialCorrMovie.avi')
open(writerObj);


 for k = 2:sum(ChanList(:,2))+1; 

    for i=1:NumTrials % (E.G. Do Everything trial by trial);

%         Out=round(Result(k).WarpedSpikeTimes{i})+1;
%         ControlTrace=zeros(1000,1)+1e-10;
%         ControlTrace(Out)=1;        
 
        ControlTrace=Result(k).TrialByTrialPSTH{i}; %PSTH

%         temp=zeros(length(Result(k).PSTH),1);
%         TrialByTrialPSTH{j}=conv(temp(:,j),gaussFilter); 
% 
        %Calculate Matrix of Autocoorelations;
  
           for j=1:NumTrials;

%             Out=round(Result(k).WarpedSpikeTimes{j})+1;
%             TestTrace=zeros(1000,1)+1e-10;
%             TestTrace(Out)=1; 
            
            TestTrace=Result(k).TrialByTrialPSTH{j};

            [xco, lags]=xcorr(ControlTrace,TestTrace,'coeff');
%             xco./max(xco);
            MatrixOut(i,j)=xco(length(ControlTrace));
%             /sum(TestTrace); % e.g. middle; get 0 Lag correlations. 

            if isnan(xco(length(ControlTrace)))
                  MatrixOut(i,j)=1e-05;                
            end;
            
        end;
    end;
        
        figure(10);
        surf(MatrixOut);
        xlabel('Trial #')
        ylabel('Trial #')
        view(0,90);
%         set(gca,'YTick',ChanList(:,1))
%         set(gca,'XTick',ChanList(:,1))
             colorbar;
%         [a]=ylim;
%         ylim([2 a(2)]);
%         xlim([2 a(2)]);
        title(['Trial By Trial Correlations w/in Channel : ' num2str(k)]);
        
        Result(k).AutoCorr=MatrixOut;
        
        SaveMovie(k)=getframe(gcf);
        
        for m=1:10
            writeVideo(writerObj,SaveMovie(k));
        end;
       
 end;
close(writerObj);


% ChMatrixOut=zeros(length(Result));
writerObj = VideoWriter('ChanbyChanCorrMovie.avi')
open(writerObj);

% Cross-Channel Correlations Across All Trials;
for k=1:Result(1).numtrials; %
%      
%     if k==65 
%         keyboard 
%     end;

    for i=2:sum(ChanList(:,2)) % (E.G. Do Everything trial by trial); % Pick a Channel

%         Out=round(Result(i).WarpedSpikeTimes{k})+1;
%         ControlTrace=zeros(1000,1)+1e-10;
%         ControlTrace(Out)=1;        

%         temp=zeros(length(Result(i).PSTH),1);
         ControlTrace=Result(i).TrialByTrialPSTH{k};
        %Calculate Matrix of Autocoorelations;

        for j=2:sum(ChanList(:,2));

%             Out=round(Result(j).WarpedSpikeTimes{k})+1;
%             TestTrace=zeros(1000,1)+1e-10;
%             TestTrace(Out)=1; 
            TestTrace=Result(j).TrialByTrialPSTH{k};

            [xco, lags]=xcorr(ControlTrace,TestTrace,'coeff');
            ChMatrix{k}(i,j)=xco(length(ControlTrace)); % e.g. middle; get 0 Lag correlations. 
            
            if isnan(xco(length(ControlTrace)))
                  ChMatrix{k}(i,j)=1e-05;                
            end;
            
        
        end;

    end;

        figure(11);
        surf(ChMatrix{k});
        
%         ChMatrixOut=ChMatrixOut+ChMatrix;
        xlabel('Channel #')
        ylabel('Channel #')
        title(['X_Correlations across Channels, Trial : ' num2str(k)]);
        view(0,90);
        [a]=ylim;
        set(gca,'xtick',[],'ytick',[]);
        ylim([2 a(2)]);
        xlim([2 a(2)]);
        colorbar;
        SaveMovie(k)=getframe(gcf);
        
        for m=1:10
            writeVideo(writerObj,SaveMovie(k));
        end;
%         savemovieobj=addframe(savemovieobj,SaveMovie(k));
end;

% Averaged Channel By Channel Correlations


ChMatrixOut=ChMatrix{1};

for i=2:length(ChMatrix)
    try
        ChMatrixOut(:,:,i)=ChMatrix{i};
    catch
    end;
end;
ChMatrixOut=ChMatrixOut./length(ChMatrix);
ChMatrixOut=nansum(ChMatrixOut,3)
close('all')
figure;
surf(ChMatrixOut);
title('AvgChCorr');
 ylim([2 a(2)]);
 xlim([2 a(2)]);
 view(0,90);
colorbar;






close(writerObj);