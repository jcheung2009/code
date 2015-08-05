close('all');
clear;
[name path]=uigetfile('','Multiselect','on');


%name=sort(name); % ascending order. 

debug=1;
pulsewidth=[10 10];  
R=[]


for i=1:length(name)
    load([path name{i}]);

    mins(i)=i;
    
%     R(length(R)+1)=output.R;
    
    if strcmp(output.path{1},'HVcOnly')
        [HVcAmp(i,1) HVcPPR(i,1) HVcbase(i,1)]=PPRs(output.HVc.signal{1},pulsewidth(1),debug);       
        
    elseif strcmp(output.path{1},'lMANOnly')
        [lMANAmp(i,1) lMANPPR(i,1) lMANbase(i,1)]=PPRs(output.lMAN.signal{1},pulsewidth(2),debug);
    elseif strcmp(output.path{1},'Both')    % e.g. must be 'Both'. 
         [HVcAmp(i,1) HVcPPR(i,1) HVcbase(i,1)]=PPRs(output.HVc.signal{1},pulsewidth(1),debug);
         [lMANAmp(i,1) lMANPPR(i,1) lMANbase(i,1)]=PPRs(output.lMAN.signal{1},pulsewidth(2),debug);
    end;
    
    
end;


if ~strcmp(output.path{1},'lMANOnly')
    figure; %(1);
         subplot(4,2,1)
         plot(mins,HVcAmp);
         title('Amp');     
         subplot(4,2,2);
         plot(mins,HVcbase);
         title('Baseline (pA)')
         subplot(4,2,3);
         plot(mins,HVcPPR);
         title('Paired Pulse Ratio');
         subplot(4,2,4);
    %      plot(mins,R);
    %      title('Access');
    % %      ylim([0 100]);
end;

if ~strcmp(output.path{1},'HVcOnly')
    
figure; %(2);
     subplot(4,2,1)
     plot(mins,lMANAmp);
     title('Amp');     
     subplot(4,2,2);
     plot(mins,lMANbase);
     title('Baseline (pA)')
     subplot(4,2,3);
     plot(mins,lMANPPR);
     title('Paired Pulse Ratio');
     subplot(4,2,4);
%      plot(mins,R);
%      title('Access');
% %      ylim([0 100]);

end;    